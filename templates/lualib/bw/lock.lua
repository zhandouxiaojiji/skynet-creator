-- 协程锁，在协程挂起时，防止重入
local skynet = require "skynet"

local mt = {}
mt.__index = mt

function mt:_lock(co)
    assert(self.locked == false)
    self.locked = co
    self.lock_count = 1
end

function mt:lock()
    local co = coroutine.running()
    if self.locked == co then
        self.lock_count = self.lock_count + 1
        return
    end

    if not self.locked then
        self:_lock(co)
        return
    end
    table.insert(self.lock_waiter, co)
    skynet.wait()
    assert(self.locked == co)
end

function mt:unlock()
    local co = coroutine.running()
    assert(self.locked == co)
    self.lock_count = self.lock_count - 1
    if self.lock_count > 0 then
        return
    end
    self.locked = false
    self.lock_count = nil

    co = table.remove(self.lock_waiter, 1)
    if co then
        self:_lock(co)
        skynet.wakeup(co)
    end
end

function mt:lock_func(func, ...)
    self:lock()
    local ret = { xpcall(func, debug.traceback, ...) }
    self:unlock()
    assert(ret[1], "in lock:" .. tostring(ret[2]))
    return table.unpack(ret, 2)
end

local M = {}

function M.new()
    local obj = {
        locked = false,
        lock_count = nil,
        lock_waiter = {}
    }
    return setmetatable(obj, mt)
end

return M

