-- 苹果支付
local json = require "cjson.safe"
local log  = require "bw.log"
local http = require "bw.http"

local M = {}
function M.verify_receipt(receipt, product_id)
    local is_sandbox = false
    local receipt_data = json.encode({["receipt-data"] = receipt})
    local ret, resp_str = http.post("https://buy.itunes.apple.com/verifyReceipt", receipt_data)
    local resp = json.decode(resp_str)
    if not ret then
        log.errorf("verify_receipt error, post:buy, product_id:%s, receipt:%s",
            product_id, receipt)
        return
    end
    if not resp or resp.status ~= 0 then
        log.debug("try sandbox")
        ret, resp_str = http.post("https://sandbox.itunes.apple.com/verifyReceipt", receipt_data)
        resp = json.decode(resp_str)
        is_sandbox = true
    end
    if not ret or not resp or resp.status ~= 0 then
        log.errorf("verify_receipt error, ret:%s, resp:%s", ret, resp_str)
        return
    end
    if not product_id then
        return resp.receipt.in_app[1].original_transaction_id, is_sandbox
    end
    for i, v in pairs(resp.receipt.in_app) do
        if v.product_id == product_id then
            return v.original_transaction_id, is_sandbox
        end
    end
    log.errorf("verify_receipt error, product_id is wrong, product_id:%s, ret:%s, resp_str:%s",
        product_id, ret, resp_str)
end
return M

