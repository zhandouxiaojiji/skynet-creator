local skynet = require "skynet.manager"

local util = {}

function util.shell(cmd, ...)
    cmd = string.format(cmd, ...)
    return io.popen(cmd):read("*all")
end

function util.run_cluster(clustername)
    local conf = require "conf"
    local cmd = string.format("cd %s/shell && sh start.sh %s", conf.workspace, clustername)
    os.execute(cmd)
end

function util.gc()
    if skynet.getenv "DEBUG" then
        collectgarbage("collect")
        return collectgarbage("count")
    end
end

-- 字符串分割
function util.split(s, delimiter, t)
    assert(string.len(delimiter) == 1)

    local arr = {}
    local idx = 1

    for value in string.gmatch(s, "[^" .. delimiter .. "]+") do
        if t == "number" then
            value = tonumber(value)
        end
        arr[idx] = value
        idx = idx + 1
    end

    return arr
end

function util.dump(root, ...)
    local tbl = {}
    local filter = {[root] = tostring(root)}
    for _, v in ipairs({...}) do
        filter[v] = tostring(v)
    end
    local function _to_key(k)
        if tonumber(k) then
            return '[' .. k .. ']'
        else
            return '["' .. k .. '"]'
        end
    end
    local function _dump(t, name, space)
        space = space .. "  "
        for k, v in pairs(t) do
            if filter[v] then
                table.insert(tbl, space .. _to_key(k) .. " = " .. filter[v])
            elseif filter[v] or type(v) ~= "table" then
                local val = tostring(v)
                if type(v) == "string" then
                    val = '"' .. tostring(v) .. '"'
                end
                table.insert(tbl, space .. _to_key(k) .. " = " .. val ..",")
            else
                filter[v] = name .. "." .. _to_key(k)
                table.insert(tbl, space .. _to_key(k) .. " = {")
                _dump(v, name .. "." .. _to_key(k),  space)
                table.insert(tbl, space .. "},")
            end
        end
    end

    table.insert(tbl, "{")
    _dump(root, "", "")
    table.insert(tbl, "}")

    return table.concat(tbl, "\n")
end

function util.is_in_list(list, obj)
    for _, o in pairs(list) do
        if o == obj then
            return true
        end
    end
    return false
end

-- 把table中类型为string的数字key转换成number
function util.str2num(tbl)
    if type(tbl) ~= "table" then return tbl end
    local data = {}
    for k,v in pairs(tbl) do
        k = tonumber(k) or k
        v = type(v) == "table" and util.str2num(v) or v
        data[k] = v
    end
    return data
end

function util.num2str(tbl)
    if type(tbl) ~= "table" then return tbl end
    local data = {}
    for k,v in pairs(tbl) do
        k = tostring(k)
        v = type(v) == "table" and util.num2str(v) or v
        data[k] = v
    end
    return data
end

local function new_module(modname)
    skynet.cache.clear()
    local module = package.loaded[modname]
    if module then
        package.loaded[modname] = nil
    end
    local new_mod = require(modname)
    package.loaded[modname] = module
    return new_mod
end

function util.reload_module(modname)
    if not package.loaded[modname] then
        require(modname)
        return require(modname)
    end
    local old_mod = require(modname)
    local new_mod = new_module(modname)

    for k,v in pairs(new_mod) do
        if type(k) == "function" then
            old_mod[k] = v
        end
    end
    return old_mod
end

function util.clone(_obj, _deep)
    local lookup = {}
    local function _clone(obj, deep)
        if type(obj) ~= "table" then
            return obj
        elseif lookup[obj] then
            return lookup[obj]
        end

        local new = {}
        lookup[obj] = new
        for key, value in pairs(obj) do
            if deep then
                new[_clone(key, deep)] = _clone(value, deep)
            else
                new[key] = value
            end
        end

        return setmetatable(new, getmetatable(obj))
    end

    return _clone(_obj, _deep)
end

-- t2是不是t1的内容一样
function util.cmp_table(t1, t2)
    for k,v1 in pairs(t1) do
        local v2 = t2[k]
        if type(v1)=="table" and type(v2)=="table" then
            if not util.cmp_table(v1, v2) then
                return false
            end
        elseif v1~=v2 then
            return false
        end
    end

    for k, _ in pairs(t2) do
        if t1[k]==nil then
            return false
        end
    end
    return true
end


function util.short_name(name)
    return string.match(name, "_(%S+)") or name
end

function util.merge_list(list1, list2)
    local list = {}
    for _, v in ipairs(list1) do
        table.insert(list, v)
    end
    for _, v in ipairs(list2) do
        table.insert(list, v)
    end
    return list
end

local function tostring_ex(value)
    if type(value)=='table' then
        return util.tbl2str(value)
    elseif type(value)=='string' then
        return "\'"..value.."\'"
    else
        return tostring(value)
    end
end

function util.tbl2str(t)
    if t == nil then return "" end
    local retstr= "{"

    local i = 1
    for key,value in pairs(t) do
        local signal = ","
        if i==1 then
            signal = ""
        end

        if key == i then
            retstr = retstr..signal..tostring_ex(value)
        else
            if type(key)=='number' or type(key) == 'string' then
                retstr = retstr..signal..'['..tostring_ex(key).."]="..tostring_ex(value)
            else
                if type(key)=='userdata' then
                    retstr = retstr..signal.."*s"..util.tbl2str(getmetatable(key)).."*e".."="..tostring_ex(value)
                else
                    retstr = retstr..signal..key.."="..tostring_ex(value)
                end
            end
        end

        i = i+1
    end

    retstr = retstr.."}"
    return retstr
end

function util.str2tbl(str)
    if str == nil or type(str) ~= "string" then
        return
    end
    return load("return " .. str)()
end

-- todo 格式化json, 临时用，字符串中不能包含单双引号，否则出错
function util.format_json(str)
    local depth = 0
    local mark
    return string.gsub(str, '([,{}\'\"])', function(c)
        if mark then
            if mark == c then
                mark = nil
                return c
            else
                return c
            end
        end
        if c == '{' then
            depth = depth + 1
            return '{\n'..string.rep(' ', depth*4)
        elseif c == '}' then
            depth = depth - 1
            return '\n'..string.rep(' ', depth*4)..'}'
        elseif c == ',' then
            return ',\n'..string.rep(' ', depth*4)
        elseif c == '\"' or c == '\'' then
            mark = c
            return c
        end
    end)
end

-- 方法本身
function util.callee()
    return debug.getinfo(2, "f").func
end

function util.printbuff(buff)
    local str = ""
    for i=1,#buff do
        str = str .. string.format("%x", string.byte(buff, i))
    end
    print(str)
end

-- 获取节点内的protobuf
function util.get_protobuf(proto_service)
    local protobuf_env = skynet.call(proto_service, "lua", "get_protobuf_env")
    assert(type(protobuf_env) == "userdata")
    assert(not package.loaded["protobuf"])
    debug.getregistry().PROTOBUF_ENV = protobuf_env
    return require "bw.protobuf"
end

return util
