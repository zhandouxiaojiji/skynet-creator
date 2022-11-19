local skynet    = require "skynet"
local service   = require "skynet.service"
local log       = require "bw.log"

local schedule = {}
local service_addr

-- { month=, day=, wday=, hour= , min= }
function schedule.submit(ti)
    assert(ti)
    return skynet.call(service_addr, "lua", ti)
end

function schedule.changetime(ti)
    local tmp = {}
    for k,v in pairs(ti) do
        tmp[k] = v
    end
    tmp.changetime = true
    return skynet.call(service_addr, "lua", tmp)
end

-- curtime
function schedule.time()
    local difftime = skynet.call(service_addr, "lua")
    return skynet.time() + difftime
end

skynet.init(function()
    local schedule_service = function()
-- schedule service

local skynet = require "skynet"

local task = { session = 0, difftime = 0 }

local function next_time(now, ti)
    local nt = {
        year = now.year ,
        month = now.month ,
        day = now.day,
        hour = ti.hour or 0,
        min = ti.min or 0,
        sec = ti.sec or 0,
    }
    if ti.wday then
        -- set week
        assert(ti.day == nil and ti.month == nil)
        nt.day = nt.day + ti.wday - now.wday
        local t = os.time(nt)
        if t < now.time then
            nt.day = nt.day + 7
        end
    else
        -- set day, no week day
        if ti.day then
            nt.day = ti.day
        end
        if ti.month then
            nt.month = ti.month
        end
        local t = os.time(nt)
        if t < now.time then
            if ti.month then
                nt.year = nt.year + 1   -- next year
            elseif ti.day then
                nt.month = nt.month + 1 -- next month
            else
                nt.day = nt.day + 1     -- next day
            end
        end
    end

    return os.time(nt)
end

local function changetime(ti)
    local ct = math.floor(skynet.time())
    local current = os.date("*t", ct)
    current.time = ct
    ti.hour = ti.hour or current.hour
    ti.min = ti.min or current.min
    ti.sec = ti.sec or current.sec
    local nt = next_time(current, ti)
    log.debug("change time to %s", os.date(nil, nt))
    task.difftime = os.difftime(nt,ct)
    for k,v in pairs(task) do
        if type(v) == "table" then
            skynet.wakeup(v.co)
        end
    end
    skynet.ret(skynet.pack(nt))
end

local function submit(_, addr, ti)
    if not ti then
        return skynet.ret(skynet.pack(task.difftime))
    end
    if ti.changetime then
        return changetime(ti)
    end
    local session = task.session + 1
    task.session = session
    repeat
        local ct = math.floor(skynet.time()) + task.difftime
        local current = os.date("*t", ct)
        current.time = ct
        local nt = next_time(current, ti)
        task[session] = { time = nt, co = coroutine.running(), address = addr }
        local diff = os.difftime(nt , ct)
        --print("sleep", diff)
    until skynet.sleep(diff * 100) ~= "BREAK"
    task[session] = nil
    skynet.ret()
end

skynet.start(function()
    skynet.dispatch("lua", submit)
    skynet.info_func(function()
        local info = {}
        for k, v in pairs(task) do
            if type(v) == "table" then
                table.insert( info, {
                    time = os.date(nil, v.time),
                    address = skynet.address(v.address),
                })
                return info
            end
        end
    end)
end)

-- end of schedule service
    end

    service_addr = service.new("schedule", schedule_service)
end)

return schedule
