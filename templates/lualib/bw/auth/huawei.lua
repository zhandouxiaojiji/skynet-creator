local json      = require "cjson.safe"
local crypto    = require "crypto"
local sign      = require "bw.auth.sign"
local log       = require "bw.log"
local util      = require "bw.util"
local http      = require "bw.http"

local table_insert  = table.insert
local table_sort    = table.sort
local table_concat  = table.concat

local API = 'https://gss-cn.game.hicloud.com/gameservice/api/gbClientApi'

local function encode_uri(s)
    assert(s)
    s = string.gsub(s, "([^A-Za-z0-9])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
    return s
end

local M = {}
function M.gen_token(params, private_key)
    local method = 'methodexternal.hms.gs.checkPlayerSign'
    local args = {
        method      = 'external.hms.gs.checkPlayerSign',
        appId       = encode_uri(params.app_id),
        cpId        = encode_uri(params.cp_id),
        ts          = encode_uri(params.ts),
        playerId    = encode_uri(params.player_id),
        playerLevel = encode_uri(params.player_level),
        playerSSign = encode_uri(params.player_ssign),
    }
    local data = sign.concat_args(args)
    local sign_str = crypto.rsa_sha256_sign(data, private_key)
    sign_str = crypto.base64_encode(sign_str)
    args.cpSign = encode_uri(sign_str)
    local ret, resp_str = http.post(API, sign.concat_args(args))
    if not ret then
        log.error('cannot request huawei api')
        return
    end
    local resp = json.decode(resp_str)
    if not resp or not resp.rtnSign then
        log.error('huawei api decode error, resp:'
            ..resp_str..' params:'..util.dump(params))
        return
    end
    return resp.rtnSign
end

return M
