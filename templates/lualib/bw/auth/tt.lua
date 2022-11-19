--  头条验证(与微信基本一致)
local wx = require "bw.auth.wx"

local M = {}
function M.request_access_token(appid, secret)
    return wx.request_access_token(appid, secret,
        'https://developer.toutiao.com/api/apps/token')
end

function M.jscode2session(appid, secret, js_code)
    return wx.jscode2session(appid, secret, js_code,
        'https://developer.toutiao.com/api/apps/jscode2session')
end

-- data {score = 100, gold = 300}
function M.set_user_storage(appid, access_token, openid, session_key, data)
    return wx.set_user_storage(appid, access_token, openid, session_key, data,
        'https://developer.toutiao.com/api/apps/set_user_storage')
end

-- key_list {"score", "gold"}
function M.remove_user_storage(appid, access_token, openid, session_key, key_list)
    return wx.remove_user_storage(appid, access_token, openid, session_key, key_list,
        'https://developer.toutiao.com/api/apps/remove_user_storage')
end

return M
