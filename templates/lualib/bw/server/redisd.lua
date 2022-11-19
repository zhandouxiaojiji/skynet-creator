local skynet    = require "skynet.manager"
local redis     = require "skynet.db.redis"

local db
local M = {}
return function(conf)
    skynet.start(function()
        db = redis.connect(conf)
        skynet.dispatch("lua", function(_, _, cmd, ...)
            skynet.ret(db[cmd](db, ...))
        end)
    end)
end

