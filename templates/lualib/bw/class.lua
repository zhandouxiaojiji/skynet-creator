return function(mt)
    mt.__index = mt

    function mt.new(...)
        local obj = setmetatable({}, mt)
        if obj.ctor then
            obj:ctor(...)
        end
        return obj
    end
    return mt
end
