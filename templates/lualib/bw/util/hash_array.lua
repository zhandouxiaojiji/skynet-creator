local mt = {}
mt.__index = mt

function mt:add(obj)
    if self._hash[obj] then
        return
    end
    self._array[#self._array + 1] = obj
    self._hash[obj] = #self._array
end

function mt:remove(obj)
    local idx = self._hash[obj]
    if not idx then
        return idx
    end
    local tail_obj = self._array[#self._array]
    if not tail_obj then
        return
    end
    self._array[idx] = tail_obj
    self._array[#self._array] = nil
    self._hash[obj] = nil
    self._hash[tail_obj] = idx
end

function mt:has(obj)
    return self._hash[obj] ~= nil
end

function mt:random_one()
    return self._array[math.random(1, #self._array)]
end

function mt:random_index()
    return math.random(1, #self._array)
end

function mt:index(idx)
    return self._array[idx]
end

function mt:len()
    return #self._array
end

function mt:clear()
    self._array = {}
    self._hash = {}
end

local M = {}
function M.new()
    local obj = {
        _array = {},
        _hash  = {},
    }
    return setmetatable(obj, mt)
end
return M
