-- 错误码规范
-- 0x0000 ~ 0x0fff 通用错误码
-- 0x1000 ~ 0xffff 项目自定错误码

local errcode = {}
local code2describe = {}
local name2errcode = {}

local function REG(code, err_name, describe)
    assert(not code2describe[code], string.format("errcode 0x%x exist", code))
    assert(not name2errcode[err_name], string.format("errcode '%s' exist", err_name))
    name2errcode[err_name] = code
    code2describe[code] = string.format("0x%x:%s【%s】", code, err_name, describe)
end
errcode.REG = REG

function errcode.describe(code)
    return code2describe[code]
end

function errcode.get_name2errcode()
    return name2errcode
end

function errcode.pack(code)
    return {err = code}
end

setmetatable(errcode, {__index = function (_, name)
    return assert(name2errcode[name], name)
end})

return errcode