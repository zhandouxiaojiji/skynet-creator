-- 警报系统
local skynet      = require "skynet"
local json        = require "cjson.safe"
local clusterinfo = require "bw.util.clusterinfo"
local bewater     = require "bw.bewater"
local log         = require "bw.log"
local util        = require "bw.util"
local http        = require "bw.http"

local pid     = clusterinfo.pid
local appname = skynet.getenv 'APPNAME'
local desc    = skynet.getenv 'DESC'

local sample_html = [[
<!DOCTYPE html>
<html>

<style>
    .title {
        font-size: large;
        display: inline;
        color: red;
    }

    .log {
        white-space: pre-wrap;
        display: inline;
        color:gray;
    }
</style>

<body>
<div>
    <div class="item">节点:%s</div>
    <div class="item">备注:%s</div>
    <div class="item">进程:%s</div>
    <div class="log">日志:%s</div>
</body>
</html>
]]


local sformat = string.format
local max_count = 10
local count = 0
local logs = ""

local function format_html(msg)
    return sformat(sample_html, appname, desc, pid, msg)
end

local M = {}
function M.traceback(err)
    if count >= max_count then
        return
    end
    logs = logs .. err .. '\n'
    count = count + 1
end

function M.start(handler)
    skynet.register ".alert"

    local send_func = assert(handler.send)
    local interval = handler.interval or 60
    skynet.fork(function()
        while true do
            if logs ~= "" then
                send_func(format_html(logs))
                logs = ""
                count = 0
            end
            skynet.sleep(interval*100)
        end
    end)
end

return M
