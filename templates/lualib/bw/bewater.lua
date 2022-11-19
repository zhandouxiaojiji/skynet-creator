local skynet = require "skynet.manager"
local log    = require "bw.log"

local M = {}

M.route = {}

local function __TRACEBACK__(errmsg)
    local track_text = debug.traceback(tostring(errmsg), 2)
    log.error("---------------------------------------- TRACKBACK ----------------------------------------")
    log.error(track_text)
    if skynet.getenv "ALERT_ENABLE" == "true" then
        skynet.send(".alert", "lua", "traceback", track_text)
    end
    log.error("---------------------------------------- TRACKBACK ----------------------------------------")
    return false
end

local skynet_start = skynet.start
local started = false
function skynet.start(...)
    if started then
        error("do not call skynet.start many times")
    end
    started = true
    return skynet_start(...)
end

-- 尝试调一个function, 如果被调用的函数有异常,返回false，
function M.try(func, ...)
    return xpcall(func, __TRACEBACK__, ...)
end

-- 给一个服务注入一段代码
-- return ok, output
function M.inject(addr, source)
    return skynet.call(addr, "debug", "RUN", source)
    --return skynet.call(addr, "code", source)
    --return skynet.call(addr, "debug", "INJECTCODE", source, filename)
    --local injectcode = require "skynet.injectcode"
    --return injectcode(source)
end

function M.timeout_call(ti, ...)
    local co = coroutine.running()
    local ret

    skynet.fork(function(...)
        ret = table.pack(pcall(skynet.call, ...))
        if co then
            skynet.wakeup(co)
            co = nil
        end
    end, ...)

    skynet.sleep(ti/10)

    if co then
        co = nil
        log.warning("call timeout:", ...)
        return false
    else
        if ret[1] then
            return table.unpack(ret, 1, ret.n)
        else
            error(ret[2])
        end
    end
end

function M.locals(f)
    f = f or 2
    local variables = {}
    local idx = 1
    while true do
        local ln, lv = debug.getlocal(f, idx)
        if ln ~= nil then
            variables[ln] = lv
        else
            break
        end
        idx = 1 + idx
    end
    return variables
end

function M.traceback(start_level, max_level)
    start_level = start_level or 2
    max_level = max_level or 20

    for level = start_level, max_level do

        local info = debug.getinfo( level, "nSl")
        if info == nil then break end
        print( string.format("[ line : %-4d]  %-20s :: %s",
            info.currentline, info.name or "", info.source or "" ) )

        local index = 1
        while true do
            local name, value = debug.getlocal(level, index)
            if name == nil then break end
            print( string.format( "\t%s = %s", name, value ) )
            index = index + 1
        end
    end
end

function M.protect(tbl, depth)
    setmetatable(tbl, {
        __index = function(t, k)
            error(string.format("key '%s' not found", k))
        end,
        __newindex = function(t, k, v)
            error(string.format("readonly table, write key '%s' error", k))
        end
    })
    if depth and depth > 0 then
        for k, v in pairs(tbl) do
            if type(v) == "table" then
                M.protect(v, depth - 1)
            end
        end
    end
    return tbl
end

function M.proxy(addr, is_send)
    assert(addr)
    return setmetatable({}, {
        __index = function(_, k)
            return function(...)
                if is_send then
                    skynet.send(addr, "lua", k, ...)
                else
                    return skynet.call(addr, "lua", k, ...)
                end
            end
        end,
    })
end

function M.start(command)
    assert(command)
    skynet.start(function()
        skynet.dispatch("lua", function(_,_, cmd, ...)
            local f = assert(command[cmd], cmd)
            skynet.ret(f(...))
        end)
        if command.start then
            command.start()
        end
    end)
end

function M.set_route(route)
    for _, v in pairs(route) do
        v.slaves = v.slaves or 1
        if v.slaves > 1 and not v.policy then
            v.policy = 'rr'
        end
    end
    M.route = M.protect(route, 1)
    return M.route
end

function M.newservice(conf, ...)
    if type(conf) == 'string' then
        return skynet.newservice(conf, ...)
    else
        local slaves = conf.slaves or 1
        local arr = {}
        local name = assert(conf.name, 'no service name')
        for i = 1, slaves do
            local s = skynet.newservice(conf.service, ...)
            arr[i] = s
            if slaves == 1 then
                skynet.name(name, s)
            else
                skynet.name(name .. i, s)
            end
        end
        return slaves == 1 and arr[1] or arr
    end
end

return M

