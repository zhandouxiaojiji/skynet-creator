local log   = require "bw.log"
local uuid  = require "uuid"

local string_gsub = string.gsub
local uid2auth = {}
local auth2uid = {}

local M = {}
function M.create(uid)
    local auth = uid2auth[uid]
    if auth then
        auth2uid[auth] = nil
    end
    while true do
        auth = string_gsub(uuid(), '-', '')
        if not auth2uid[auth] then
            break
        end
    end
    uid2auth[uid] = auth
    auth2uid[auth] = uid
    log.infof("create auth: %d %s", uid, auth)
    return auth
end

function M.remove(uid)
    local auth = uid2auth[uid]
    if auth then
        auth2uid[auth] = nil
    end
    uid2auth[uid] = nil
    log.infof("remove auth: %d %s", uid, auth)
end

function M.get_uid(auth)
    return auth2uid[auth]
end

function M.get_auth(uid)
    return uid2auth[uid] or M.create(uid)
end

return M
