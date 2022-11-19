local random  = require "random.core"

local M = {}
local table_insert = table.insert
local table_remove = table.remove

function M.prob(value)
    return random.prob(value * 10)
end

--从数组中选出不重复的数，len为数组大小，num为选出数量，
--返回数组索引
function M.random_unrepeat(len, num)
    local arr = {}
    for i=1,len do
        table_insert(arr, i)
    end

    local ret = {}
    for i=1, num do
        len = #arr
        if len <= 0 then
            return ret
        end

        math.random(len)
        math.random(len)
        local idx = math.random(len)
        table_insert(ret, arr[idx])
        table_remove(arr,idx)

    end

    return ret
end

--根据随机表,返回随机到的物品属性
--基础随机函数，对应函数表格式: tbl = { { resultA, chanceA }, { resultB, chanceB }, ... }
function M.random_item_attr(tbl)
    local t = {}
    for _, v in ipairs(tbl) do
        assert(v[1])
        table.insert(t, v[2])
    end
    --return tbl[1][1]
    local idx = random.range_prob(t)
    assert(tbl[idx], string.format("tbl len:%s, idx:%d", table.concat(t, ','), idx))
    return tbl[idx][1]
end

-- 一维表随机函数
-- tbl = { chanceA, chanceB, ... }
function M.random_item_attr_1d( tbl )
    return random.range_prob(tbl)
end

return M
