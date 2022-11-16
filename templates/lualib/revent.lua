local skynet = require "skynet"
local cluster = require "skynet.cluster"

local tinsert = table.insert
local tunpack = table.unpack

local M = {}

local function agent_call(agent, ...)
    if agent.cluster_name then
        return cluster.call(agent.cluster_name, agent.service, ...)
    else
        return skynet.call(agent.service, "lua", ...)
    end
end

local function agent_send(agent, ...)
    if agent.cluster_name then
        return cluster.send(agent.cluster_name, agent.service, ...)
    else
        return skynet.send(agent.service, "lua", ...)
    end
end

-- 订阅方
function M.sub(cluster_name, service, event, callback_func)
    assert(callback_func)
    local agent = {
        id = nil,
        service = service,
        cluster_name = cluster_name,
        event = event,
        watching = true,
    }
    agent.id = agent_call(agent, "register", event)
    skynet.fork(function ()
        while agent.watching do
            local args = agent_call(agent, "wait", agent.id)
            if not agent.watching then
                break
            end
            for _, arg in ipairs(args) do
                xpcall(callback_func, debug.traceback, tunpack(arg))
            end
        end
    end)
    return agent
end

function M.unsub(agent)
    agent.watching = false
    agent_send(agent, "unregister", agent.id)
end


-- 派发方
local event2agents = {}
local id2agent = {}
local auto_id = 0
local function get_agents(event)
    local agents = event2agents[event] or {}
    event2agents[event] = agents
    return agents
end
function M.register(event)
    assert(event)
    local agents = get_agents(event)
    auto_id = auto_id + 1
    local agent = {
        id = auto_id,
        event = event,
        args = {},
    }
    agents[agent.id] = agent
    id2agent[agent.id] = agent
    skynet.retpack(agent.id)
end

function M.unregister(id)
    local agent = assert(id2agent[id], id)
    id2agent[id] = nil
    local agents = event2agents[agent.event]
    agents[id] = nil
    Skynet.wakeup(agent.co)
end

function M.wait(id)
    local agent = assert(id2agent[id], id)
    if #agent.args > 0 then
        skynet.retpack(agent.args)
        return
    end
    agent.co = coroutine.running()
    skynet.wait()
    skynet.retpack(agent.args)
    agent.args = {}
    agent.co = nil
end

function M.pub(event, ...)
    local agents = event2agents[event]
    if not agents then
        return
    end
    for _, agent in pairs(agents) do
        tinsert(agent.args, {...})
        if agent.co then
            skynet.wakeup(agent.co)
        end
    end
end

function M.pub_to_agent(agent, ...)
    tinsert(agent.args, {...})
    Skynet.wakeup(agent.co)
end

return M
