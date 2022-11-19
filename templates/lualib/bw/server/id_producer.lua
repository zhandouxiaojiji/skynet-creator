local lock = require "bw.lock"
local bewater = require "bw.bewater"

local reserve_id
local id

local reserve_count -- 预分配数
local initial_id    -- 初始id
local load_id, save_id -- load & save function

local lock_create = lock.new()

local M = {}
function M.start(handler)
    load_id = assert(handler.load_id)
    save_id = assert(handler.save_id)
    reserve_count = handler.reserve_count or 100
    initial_id = handler.initial_id or 10000000
    id = load_id()
    if not id then
        id = initial_id
    end
    reserve_id = id + reserve_count
    save_id(reserve_id)
end

function M.save()
    save_id(id)
end

function M.create(count)
    local start_id
    lock_create:lock()
    bewater.try(function()
        count = count or 1
        start_id = id
        id = id + count
        if id > reserve_id then
            reserve_id = id + reserve_count
            save_id(reserve_id)
        end
    end)
    lock_create:unlock()
    return start_id, count
end

return M
