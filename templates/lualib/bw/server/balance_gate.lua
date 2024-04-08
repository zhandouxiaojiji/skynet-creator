local skynet = require "skynet"
local socket = require "skynet.socket"
local log = require "bw.log"

local gateserver = {}
local agents = {}

local CMD = {}
function CMD.call_agent(...)
    return skynet.call(agents[1], "lua", ...)
end

function CMD.call_all_agent(...)
    for _, agent in pairs(agents) do
        skynet.pcall(agent, "lua", ...)
    end
end

function gateserver.start(conf, ...)
    local agentname = assert(conf.agentname)
    local port = assert(conf.port)
    local preload = assert(conf.preload or 10)
    local command = assert(conf.command)
    local start_func = conf.start_func
    log.infof("gateserver start, agentname:%s, port:%d, preload:%d", agentname, port, preload)

    for k, v in pairs(CMD) do
        command[k] = command[k] or v
    end

    local args = {...}
    skynet.start(function()
        for i= 1, preload or 10 do
            agents[i] = skynet.newservice(agentname, table.unpack(args))
        end
        local balance = 1
        local fd = socket.listen("0.0.0.0", port)
        log.infof("listen port:%s", port)
        socket.start(fd , function(in_fd, ip)
            --log.debugf("%s connected, pass it to agent :%08x", _fd, agents[balance])
            skynet.send(agents[balance], "lua", "open", in_fd, ip)
            balance = balance + 1
            if balance > #agents then
                balance = 1
            end
        end)

        skynet.dispatch("lua", function(_, _, cmd, ...)
            local f = assert(command[cmd], cmd)
            skynet.retpack(f(...))
        end)
        if start_func then
            start_func()
        end
    end)
end

return gateserver