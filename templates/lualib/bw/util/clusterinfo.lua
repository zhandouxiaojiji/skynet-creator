-- 集群节点相关信息
-- 访问方式 clusterinfo.xxx or clusterinfo.get_xxx()
--
local skynet = require "skynet"
local http   = require "bw.http"
local util   = require "bw.util"
local bash   = require "bw.bash"

local M = {}
local _cache = {}
setmetatable(M, {
    __index = function (t, k)
        local v = rawget(t, k)
        if v then
            return v
        end
        local f = rawget(t, '_'..k)
        if f then
            v = _cache[k] or f()
            _cache[k] = v
            return v
        end
        f = rawget(t, 'get_'..k)
        assert(f, "no clusterinfo "..k)
        return f()
    end
})

-- 公网ip
function M._pnet_addr()
    local _, resp = http.get('http://members.3322.org/dyndns/getip')
    local addr = string.gsub(resp, "\n", "")
    return addr
end

-- 内网ip
function M.get_inet_addr()
    local ret = bash.execute "ifconfig eth0"
    return string.match(ret, "inet addr:([^%s]+)") or string.match(ret, "inet ([^%s]+)")
end

function M.get_run_time()
    return skynet.time()
end

-- 进程pid
function M._pid()
    local filename = skynet.getenv "daemon"
    if not filename then
        return
    end
    local pid = bash.execute "cat ${filename}"
    return string.gsub(pid, "\n", "")
end

function M.get_profile()
    local pid = M.pid
    if not pid then return end
    local ret = bash.execute 'ps -p ${pid} u'
    local list = util.split(string.match(ret, '\n(.+)'), ' ')
    return {
        cpu = tonumber(list[3]),
        mem = tonumber(list[6]),
    }
end

function M._clustername()
    return skynet.getenv "clustername"
end



return M
