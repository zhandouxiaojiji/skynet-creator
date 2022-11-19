local skynet = require "skynet"
local socket = require "skynet.socket"
local bewater = require "bw.bewater"
local log = require "bw.log"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
local urllib = require "http.url"
local json = require "cjson.safe"
local errcode = require "def.errcode"
local api = require "bw.api"

local string = string

local M = {}

function M.start(handler, agentname, port, num_agents)
    skynet.start(function()
        local agents = {}
        for i = 1, num_agents or 10 do
            agents[i] = skynet.newservice(agentname)
        end

        if type(port) == 'string' then
            port = tonumber(skynet.getenv(port))
        end

        local curr = 1
        local fd = socket.listen("0.0.0.0", port)
        log.infof("%s listen 0.0.0.0:%d", agentname, port)
        socket.start(fd, function(...)
            skynet.send(agents[curr], "lua", ...)
            curr = curr + 1
            if curr > #agents then curr = 1 end
        end)
        if handler then
            skynet.dispatch("lua", function(_,_, cmd, ...)
                local f = assert(handler[cmd], cmd)
                skynet.ret(f(...))
            end)
            if handler.start then
                handler.start()
            end
        end
    end)
end

-- handler message
local map = {}

local function default_pack(ret)
    if type(ret) == "table" then
        ret.err = ret.err or 0
        return json.encode(ret)
    else
        return json.encode({err = ret})
    end
end

local function default_unpack(str) return json.decode(str) end

local function default_auth(p) error("auth function not provide") end

local function response(fd, ...)
    local writefunc = sockethelper.writefunc(fd)
    local ok, err = httpd.write_response(writefunc, ...)
    if not ok then
        -- if err == sockethelper.socket_error , that means socket closed.
        log.errorf("fd = %d, %s", fd, err)
    end
end

local function check_data(def, data)
    if not data then return errcode.ARGS_ERROR, "data nil" end
    for k, t in pairs(def) do
        if t and t ~= '?' then
            local tn, opt = string.match(t, '(%w+)(%?*)')
            local tv = type(data[k])
            if tv ~= tn and (opt ~= '?' or tv ~= 'nil') then
                return errcode.ARGS_ERROR,
                       string.format("args error, %s must %s", k, t)
            end
        end
    end
    return errcode.OK
end

local function on_message(process, args, body, header)
    local url = process.url
    local pack = process.pack or default_pack
    local unpack = process.unpack or default_unpack

    local authorization = header.authorization

    local function errf(err, fmt, ...)
        return pack {err = err, desc = string.format(fmt, ...), url = url}
    end

    local ret, req = bewater.try(function() return unpack(body, url) end)
    if not ret then return errf(errcode.BODY_ERROR, "body error") end
    local uid
    if process.auth and default_auth then
        uid = default_auth(authorization)
        if not uid then
            return errf(errcode.AUTH_FAIL, "authorization fail")
        end
    end
    if process.request then
        local err, errmsg = check_data(process.request, req)
        if err ~= errcode.OK then errf(err, errmsg) end
    end
    local res = {}
    if not bewater.try(function()
        local func = process.handler
        res = process.handler(req, uid, header) or {}
        if type(res) == "number" then
            res = {err = res}
            if res.err ~= errcode.OK then
                res.errmsg = errcode.describe(res.err)
            end
        end
        assert(type(res) == "table")
        res.err = res.err or errcode.OK
        assert(process.response, res)
    end) then return errf(errcode.TRACEBACK, "server traceback") end

    return pack(res)
end

local function resp_options(fd, header)
    response(fd, 200, nil, {
        ['Access-Control-Allow-Origin'] = header['origin'],
        ['Access-Control-Allow-Methons'] = 'PUT, POST, GET, OPTIONS, DELETE',
        ['Access-Control-Allow-Headers'] = header['access-control-request-headers']
    })
    socket.close(fd)
end

local function trim_lf(str) return string.gsub(str, '[\n\r]', '') end

local function trim_body(str)
    if not str then
        return ''
    elseif #str < 200 then
        return trim_lf(str)
    else
        return trim_lf(str:sub(1, 200) .. '...')
    end
end

--[[
    host=dev.coding1024.com
    connection=close
    x-forwarded-for=113.109.247.71
    content-type=application/x-www-form-urlencoded
    x-real-ip=113.109.247.71
    user-agent=Dalvik/2.1.0 (Linux; U; Android 10; PCAM00 Build/QKQ1.190918.001)
    remote-host=113.109.247.71
    content-length=92
    accept-encoding=identity
]]
local header_filter = {
    ["connection"] = true,
    ["x-forwarded-for"] = true,
    ["user-agent"] = true,
    ["remote-host"] = true,
    ["accept-encoding"] = true
}
local function trim_header(header)
    if not header then
        return ''
    else
        local t = {}
        for k, v in pairs(header) do
            if not header_filter[k] then
                t[#t + 1] = string.format('%s=%s', k, v)
            end
        end
        return table.concat(t, ', ')
    end
end

function M.start_agent(handler)
    skynet.start(function()
        handler = handler or {}
        -- 如果是非字符串，handler需要提供pack和unpack方法
        default_pack = handler.pack or default_pack
        default_unpack = handler.unpack or default_unpack
        default_auth = handler.auth or default_auth
        on_message = handler.on_message or on_message

        skynet.dispatch("lua", function(_, _, fd, ip)
            socket.start(fd)
            -- limit request body size to 8192 (you can pass nil to unlimit)
            local code, url, method, header, body = httpd.read_request(
                sockethelper.readfunc(fd),nil)
            log.infof('http request(fd:%d):%s %s 200 header:[%s] request:[%s]',
                fd, method, url, trim_header(header), trim_body(body))
            local process = map[url]
            code = process and code or 404
            if (code == 200 or code == 404) and method ~= "OPTIONS" then
                local data
                local _, query = urllib.parse(url)
                if query then data = urllib.parse_query(query) end
                if not header['x-real-ip'] then
                    header['x-real-ip'] = string.match(ip, "[^:]+")
                end
                local resp_body, resp_header
                if code == 200 then
                    resp_body, resp_header =
                        on_message(process, data, body, header)
                else
                    code = 200
                    resp_body = default_pack({err = errcode.API_NOT_FOUND})
                end
                log.debugf('http response(fd:%d):%s %s 200 request:[%s] respose:[%s]',
                    fd, method, url, trim_body(body), trim_body(resp_body))
                response(fd, code, resp_body, resp_header or {
                    ['Access-Control-Allow-Origin'] = header['origin'],
                    ['Access-Control-Allow-Methons'] = 'PUT, POST, GET, OPTIONS, DELETE',
                    ['Access-Control-Allow-Headers'] = header['access-control-request-headers']
                })
            else
                if url == sockethelper.socket_error then
                    log.debug("socket closed")
                end
                if method == "OPTIONS" then
                    return resp_options(fd, header)
                else
                    response(fd, code)
                end
            end
            socket.close(fd)
        end)
    end)
end

function M.register(protocol, handler)
    if type(protocol) == 'string' then
        protocol = assert(api(protocol), 'no api protocol define: ' .. protocol)
    end
    local url = assert(protocol.url)
    assert(protocol.response, protocol.url)
    map[url] = setmetatable({
        handler = assert(handler, 'no http handler: ' .. url)
    }, {__index = protocol})
end

function M.def(def, handler)
    api.typedef(def)
    M.register(def.url, handler)
end

return M
