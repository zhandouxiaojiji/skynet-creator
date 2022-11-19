local skynet   = require "skynet"
local schedule = require "bw.schedule"

local M = {}
-- t:{month=, day=, wday=, hour= , min=} wday
function M.schedule(t, cb)
    assert(type(t) == "table")
    assert(cb)
    skynet.fork(function()
        while true do
            schedule.submit(t)
            cb()
            skynet.sleep(100)
        end
    end)
end
return M
