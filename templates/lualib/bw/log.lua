local skynet = require "skynet"
local util   = require "bw.util"

local tconcat  = table.concat
local tinsert  = table.insert
local sformat  = string.format
local srep     = string.rep
local tostring = tostring
local select   = select
local os       = os

local log = {}

local llevel_desc = {
    [0] = "EMG",
    [1] = "ALT",
    [2] = "CRI",
    [3] = "ERR",
    [4] = "WAR",
    [5] = "NTC",
    [6] = "INF",
    [7] = "DBG",
}

local llevel = {
    NOLOG    = 99,
    DEBUG    = 7,
    INFO     = 6,
    NOTICE   = 5,
    WARNING  = 4,
    ERROR    = 3,
    CRITICAL = 2,
    ALERT    = 1,
    EMERG    = 0,
}


local color = {
    red    = 31,
    green  = 32,
    blue   = 36,
    yellow = 33,
    other  = 37
}

local color_level_map = {
    [4] = "green",
    [5] = "blue",
    [6] = "other",
    [7] = "yellow",
}

local log_src = false
if skynet.getenv("LOG_SRC") == "true" then
    log_src = true
end

local function format_now()
    return os.date("%Y-%m-%d %H:%M:%S", skynet.time()//1)
end

local function highlight(s, level)
    local c = color_level_map[level] or "red"
    return sformat("\x1b[1;%dm%s\x1b[0m", color[c], tostring(s))
end

local function get_log_src(level)
    local info = debug.getinfo(level+1, "Sl")
    local src = info.short_src
    return src .. ":" .. info.currentline .. ":"
end

local function format_log(addr, str)
    return sformat("[:%.8x] [%s] %s", addr, format_now() , str)
end

local function dump_args(...)
    local n = select("#",...)
    local out = {}
    local v_str
    for i=1,n do
        local v = select(i,...)
        if type(v) == "table" then
            v_str = "table:\n" .. log.dump(v)
        else
            v_str = tostring(v)
        end
        tinsert(out, v_str)
    end
    return tconcat(out," ")
end

local function syslog(level, ...)
    local str = dump_args(...)
    if log_src then
        str = sformat("[%s] %s", get_log_src(3), str)
    end
    str = format_log(skynet.self(), str)
    print(highlight(str, level))
end


function log.highlight(...)
    return highlight(...)
end

function log.format_log(addr, ...)
    return format_log(addr, ...)
end

function log.debug(...)
    syslog(llevel.DEBUG, ...)
end

function log.debugf(fmt, ...)
    syslog(llevel.DEBUG, sformat(fmt, ...))
end

function log.info(...)
    syslog(llevel.INFO, ...)
end

function log.infof(fmt, ...)
    syslog(llevel.INFO, sformat(fmt, ...))
end

function log.error(...)
    syslog(llevel.ERROR, ...)
end

function log.errorf(fmt, ...)
    syslog(llevel.ERROR, sformat(fmt, ...))
end

function log.warning(...)
    syslog(llevel.WARNING, ...)
end

function log.warningf(fmt, ...)
    syslog(llevel.WARNING, sformat(fmt, ...))
end

function log.assert(value, ...)
    if not value then
        error(dump_args(...))
    end
end

function log.assertf(value, fmt, ...)
    if not value then
        error(sformat(fmt, ...))
    end
end

function log.syslog(level, str, addr)
    assert(llevel[level], level)
    syslog(level, str)
end

function log.stat(filename, str)
    filename = sformat("%s/%s.log", skynet.getenv "LOG_PATH", filename)
    local file = io.open(filename, "a+")
    file:write(format_now() .. " " .. str .. "\n")
    file:close()
end

function log.statf(filename, fmt, ...)
    log.stat(filename, sformat(fmt, ...))
end

function log.dump(root, depth)
    depth = depth or 10
    local cache = {  [root] = "." }
    local function _dump(t, space, name, d)
        if d <= 0 then
            return ""
        end
        local temp = {}
        for k,v in pairs(t) do
            local key = tostring(k)
            if cache[v] then
                tinsert(temp,"+" .. key .. " {" .. cache[v].."}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                tinsert(temp,"+" .. key .. _dump(v,space .. "|" .. srep(" ",#key), new_key, d - 1))
            else
                tinsert(temp,"+" .. key .. " [" .. tostring(v).."]")
            end
        end
        return tconcat(temp,"\n"..space)
    end
    return (_dump(root, "","", depth))
end

return log
