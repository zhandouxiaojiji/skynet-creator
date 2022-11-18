local skynet = require "skynet"
local http   = require "bw.http"
local log    = require "bw.log"
local json   = require "cjson.safe"
local crypto = require "crypto"

local function encodeBase64(source_str)
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local s64 = ''
    local str = source_str

    while #str > 0 do
        local bytes_num = 0
        local buf = 0

        for byte_cnt=1,3 do
            buf = (buf * 256)
            if #str > 0 then
                buf = buf + string.byte(str, 1, 1)
                str = string.sub(str, 2)
                bytes_num = bytes_num + 1
            end
        end

        for group_cnt=1,(bytes_num+1) do
            local b64char = math.fmod(math.floor(buf/262144), 64) + 1
            s64 = s64 .. string.sub(b64chars, b64char, b64char)
            buf = buf * 64
        end

        for fill_cnt=1,(3-bytes_num) do
            s64 = s64 .. '='
        end
    end

    return s64
end

local function post(url, data, auth)
    local ret, res = http.post(url, json.encode(data), {
        ["Content-Type"] = "application/json",
        ["Authorization"] = auth,
    })
    if ret then
        return json.decode(res)
    end
end

local M = {}
function M.auth(appkey, secret)
    return "Basic "..encodeBase64(appkey..":"..secret)
end

function M.get_mobile(login_token, pem, auth)
    local res = post('https://api.verification.jpush.cn/v1/web/loginTokenVerify', {
        loginToken = login_token,
    }, auth)
    if res and res.code == 8000 then
        local bs = crypto.base64_decode(res.phone)
        return crypto.rsa_private_decrypto(bs, pem)
    end
end

function M.send_code(mobile, sign_id, temp_id, auth)
    local res = post("https://api.sms.jpush.cn/v1/codes", {
        mobile = mobile,
        sign_id = sign_id,
        temp_id = temp_id,
    }, auth)
    return res and res.msg_id or nil
end

function M.verify_code(msg_id, code, auth)
    local url = string.format('https://api.sms.jpush.cn/v1/codes/%s/valid', msg_id)
    local res = post(url, {
        code = code,
    }, auth)
    return res and res.is_valid
end

return M
