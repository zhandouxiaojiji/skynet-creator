local skynet    = require "skynet"
local bewater   = require "bw.bewater"
local log       = require "bw.log"

local M = {}

local function status(v)
    return v ~= nil and 'OK' or 'NO'
end

local function lookup_service(t, name, is_send)
    local svr
    if skynet.localname('.' .. name) then
        svr = bewater.proxy('.' .. name, is_send)
        -- log.debugf("[%s] lookup local service: .%s", status(svr), name)
    else
        svr = bewater.proxy(name, is_send)
        -- log.debugf("[%s] lookup remote service: %s", status(svr), name)
    end
    t[name] = svr
    return svr
end

local function create_route(t, name, ri, is_send)
    local svrs = {}
    local idx = 0
    local slaves = ri.slaves
    local policy = ri.policy
    for i = 1, slaves do
        svrs[i] = lookup_service({}, name .. i, is_send)
    end
    t[name] = setmetatable({}, {
        __index = function (_, fn)
            return function (arg, ...)
                local svr
                if policy == 'hash' then
                    svr = svrs[arg % slaves + 1]
                else
                    svr = svrs[idx % slaves + 1]
                    idx = idx + 1
                end
                return svr[fn](arg, ...)
            end
        end,
    })
    return t[name]
end

local function lookup_call_service(t, name)
    local ri = bewater.route[name]
    if ri and ri.slaves > 1 then
        return create_route(t, name, ri, false)
    else
        return lookup_service(t, name, false)
    end
end

local function lookup_send_service(t, name)
    local ri = bewater.route[name]
    if ri and ri.slaves > 1 then
        return create_route(t, name, ri, true)
    else
        return lookup_service(t, name, true)
    end
end

M.noret = setmetatable({}, {__index = lookup_send_service})

return setmetatable(M, {__index = lookup_call_service})