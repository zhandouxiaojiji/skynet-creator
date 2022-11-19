local M = {}
-- 不带属性的key-value, CDATA标签用于说明数据不被XML解析器解析
function M.encode(k, v, cdata)
    local str = '<'..k..'>'
    if type(v) == "table" then
        for kk, vv in pairs(v) do
            str = str .. '\n' .. M.encode(kk, vv, cdata)
        end
    else
        if cdata then
            str = str .. '<![CDATA['..v..']]>'
        else
            str = str .. v
        end
    end
    str = str..'</'..k..'>'
    return str
end

-- 带属性的key-value
function M.attr_encode()
    -- todo
end
return M
