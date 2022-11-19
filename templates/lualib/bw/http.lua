-- Http 请求 get post
--
local skynet = require "skynet"
local json   = require "cjson.safe"
local log    = require "bw.log"
local bw     = require "bw.bw"

local M = {}
function M.get(url, get, header, no_reply)
    if no_reply then
        return bw.noret.webclient.request(url, get, nil, header, no_reply)
    else
        return bw.webclient.request(url, get, nil, header, no_reply)
    end
end

function M.post(url, post, header, no_reply)
    if no_reply then
        return bw.noret.webclient.request(url, nil, post, header, no_reply)
    else
        return bw.webclient.request(url, nil, post, header, no_reply)
    end
end

function M.encode_uri(s)
    assert(s)
    s = string.gsub(s, "([^A-Za-z0-9])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
    return s
end

function M.decode_uri(s)
    s = string.gsub(s, '%%(%x%x)', function(h)
        return string.char(tonumber(h, 16))
    end)
    return s
end


function M.parse_uri(s)
    assert(s)
    local data = {}
    for ss in string.gmatch(s, "([^&]+)") do
        local k, v = string.match(ss, "(.+)=(.+)")
        data[k] = v
    end
    return data
end


--[[
{
    "code":0,
    "data":{
        "ip":"202.104.71.210",
        "country":"中国",
        "area":"",
        "region":"广东",
        "city":"广州",
        "county":"XX",
        "isp":"电信",
        "country_id":"CN",
        "area_id":"",
        "region_id":"440000",
        "city_id":"440100",
        "county_id":"xx",
        "isp_id":"100017"
    }
}
]]
function M.ip_info(ip)
    assert(ip)
    local _, resp = M.get("http://ip.taobao.com/service/getIpInfo.php", {ip = ip})
    resp = json.decode(resp)
    if not resp then
        log.error("get ip_info error", ip, resp)
        resp = {}
    end
    return resp.data or {}
end

return M
