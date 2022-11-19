return function(dst, dir, name)
    local src = require(string.format("%s.%s_mt", dir, name))
    for k,v in pairs(src) do
        assert(not dst[k], k)
        dst[k] = v
    end
end
