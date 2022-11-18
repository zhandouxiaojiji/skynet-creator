-- 支付宝支付
local crypto = require "crypto"
local sign   = require "bw.auth.sign"
local cjson  = require "cjson"

local M = {}
function M.create_order(param)
    local order_no      = assert(param.order_no)
    local private_key   = assert(param.private_key)
    local item_desc     = assert(param.item_desc)
    local pay_price     = assert(param.pay_price)
    local appid         = assert(param.appid)
    local url           = assert(param.url)
    assert(param.uid)
    assert(param.item_sn)
    assert(param.pay_channel)
    assert(param.pay_method)

    local args = {
        app_id = appid,
        charset = 'utf-8',
        method = 'alipay.trade.app.pay',
        sign_type = 'RSA2',
        version = '1.0',
        timestamp = os.date('%Y-%m-%d %H:%M:%S', os.time()),
        notify_url = url,
        biz_content = cjson.encode({
            timeout_express = '30m',
            total_amount = pay_price,
            body = item_desc,
            subject = item_desc,
            out_trade_no = order_no,
        })
    }

    local sv = sign.rsa_sha256_sign(args, private_key, false)
    return {
        order_no = order_no,
        order = sign.concat_args(args, false) .. '&sign=' .. sv,
    }
end

function M.notify(public_key, param)
    if param.trade_status ~= "TRADE_SUCCESS" then
        return
    end
    local args = {}
    for k, v in pairs(param) do
        if k ~= "sign" and k ~= "sign_type" then
            args[k] = v
        end
    end

    local src = sign.concat_args(args)
    local bs = crypto.base64_decode(param.sign)
    local pem = public_key
    return crypto.rsa_sha256_verify(src, bs, pem, 2)
end

return M
