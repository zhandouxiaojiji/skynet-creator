local skynet = require "skynet"
local bewater = require "bw.bewater"
local websocket = require "http.websocket"
local json = require "cjson.safe"
local log = require "bw.log"

local fd2user = {}

local protocol, pack, unpack, process, is_binary, onclose, errcode

local function default_pack(ret)
    return json.encode(ret)
end

local function default_unpack(str)
    return json.decode(str)
end

local function create_user(fd, ip)
    local user = {
        fd = fd,
        ip = ip,
        session = nil,
    }
    fd2user[fd] = user
    return user
end

local function get_user(fd)
    return fd2user[fd]
end

local function destroy_user(fd)
    local user = fd2user[fd]
    if user then
        onclose(user)
        fd2user[fd] = nil
    end
end

local CMD = {}

local ws = {}
function ws.connect(fd)
    log.debugf("ws connect from: %s", fd)
end

function ws.handshake(fd, header, url)
    local addr = websocket.addrinfo(fd)
    log.debugf("ws handshake from: %s, url:%s, addr:%s", fd, url, addr)
end

function ws.message(fd, msg)
    -- log.debugf("on message, fd:%s, msg:%s", fd, msg)
    local req = unpack(msg)
    local user = get_user(fd)
    local resp = {
        op = req.op + 1,
        session = req.session,
        data = process(user, req.op, req.data)
    }
    user.session = req.session
    if resp.data then
        websocket.write(fd, pack(resp), is_binary and "binary" or "text")
    end
end

function ws.ping(fd)
    log.debug("ws ping from: " .. tostring(fd) .. "\n")
end

function ws.pong(fd)
    log.debug("ws pong from: " .. tostring(fd))
end

function ws.close(fd, code, reason)
    log.debug("ws close from: " .. tostring(fd), code, reason)
    CMD.close(fd)
end

function ws.error(fd)
    log.debug("ws error from: " .. tostring(fd))
    CMD.close(fd)
end

function CMD.open(fd, addr)
    log.debug("open", fd, protocol, addr)
    local user = create_user(fd, addr)
    fd2user[fd] = user
    local ok, err = websocket.accept(fd, ws, protocol, addr)
    -- log.debug("open result", ok, err)
    if not ok then
        log.error(err)
    else
        fd2user[fd] = nil
    end
end

function CMD.close(fd)
    destroy_user(fd)
    websocket.close(fd)
end


function CMD.send(fd, op, data, session)
    assert(fd)
    assert(op)

    log.debug("send", fd, op, data, session)

    websocket.write(fd, pack {
        op = op,
        data = data or {},
        session = session or 0,
    }, is_binary and "binary" or "text")
end

local M = {
    open = CMD.open,
    close = CMD.close,
}
function M.start(conf)
    protocol = conf.protocol or "ws"
    pack = conf.pack or default_pack
    unpack = conf.unpack or default_unpack
    onclose = conf.onclose
    is_binary = conf.is_binary
    process = assert(conf.process)
    local start_func = conf.start_func

    local command = assert(conf.command)
    for k, v in pairs(CMD) do
        command[k] = command[k] or v
    end

    skynet.start(function()
        skynet.dispatch("lua", function(_,_, cmd, ...)
            local f = assert(command[cmd], cmd)
            skynet.retpack(f(...))
        end)

        if start_func then
            start_func()
        end
    end)
end

function M.send(fd, op, data)
    assert(fd)
    local resp = {
        op = assert(op),
        session = 0,
        data = data
    }

    local ok, errmsg = xpcall(function ()
        websocket.write(fd, pack(resp), is_binary and "binary" or "text")
    end, debug.traceback)
    if not ok then
        log.warningf("send 0x%x error", op)
        log.warning("send data", data)
        log.warning(errmsg)
    end
end

return M