-- vivo 支付
local crypto = require "crypto"
local sign   = require "bw.auth.sign"

local md5 = crypto.md5_encode

local M = {}
function M.create_order(param)
    assert(param.appid)
    assert(param.order_no)
    local url = param.url

    local args = {
        appId = param.appid,
        cpOrderNumber = param.order_no,
        orderAmount = param.pay_price,
        productName = param.item_desc,
        productDesc = param.item_desc,
        notifyUrl = url,
    }

    local str1 = sign.concat_args(args)
    local str2 = string.lower(md5(param.appsecret))
    local str = string.lower(md5(str1 .. "&" .. str2))

    return {
        appid         = param.appid,
        order_no      = param.order_no,
        notify_url    = param.url,
        product_price = param.pay_price,
        product_name  = param.item_desc,
        product_des   = param.item_desc,
        sign          = str,
    }
end

function M.notify(param, app_secret)
    local args = {}
    for k, v in pairs(param) do
        if k ~= "signature" and k ~= "signMethod" then
            args[k] = v
        end
    end

    local str1 = sign.concat_args(args)
    local str2 = string.lower(md5(app_secret))
    local str = string.lower(md5(str1 .. "&" .. str2))

    return str == param.signature and param.tradeStatus == '0000'
        and param.respCode == '200'
end

return M
