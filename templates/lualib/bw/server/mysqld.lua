local skynet    = require "skynet.manager"
local mysql     = require "skynet.db.mysql"
local bewater   = require "bw.bewater"
local util      = require "bw.util"

local db
return function(conf)
    skynet.start(function()
        local function on_connect(_db)
            _db:query("set charset utf8")
        end
        db=mysql.connect({
            host            = conf.host,
            port            = conf.port,
            database        = conf.name,
            user            = conf.user,
            password        = conf.pswd,
            max_packet_size = conf.max_packet_size or 1024 * 1024,
            on_connect      = on_connect
        })
        skynet.dispatch("lua", function(_, _, cmd, ...)
            local f = assert(db[cmd])
            local ret = f(db, ...)
            assert(not ret.err,string.format("mysql error:%s\n%s", table.pack(...)[1], util.dump(ret)))
            bewater.ret(ret)
        end)
    end)
end

