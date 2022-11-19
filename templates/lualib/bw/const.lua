local meta = {
    __newindex = function(_, k)
        error(string.format("readonly:%s", k), 2)
    end,
}

local function const(t)
    setmetatable(t, meta)
    for _, v  in pairs(t) do
        if type(v) == "table" then
            const(v)
        end
    end
    return t
end
return const
