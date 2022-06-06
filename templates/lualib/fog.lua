local DISPEL = 0 -- 全驱散
local MIX = 1 -- 混合
local FOG = 2 -- 全迷雾

local slen = string.len
local ssub = string.sub
local type = type

local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local n2c = {}
local c2n = {}

for i = 1, 64 do
    local c = ssub(b64chars, i, i)
    local n = i - 1
    n2c[n] = c
    c2n[c] = n
end

local function create_node(parent, tag, min, max)
    return {
        tag = tag,
        parent = parent,
        min = min,
        max = max,
    }
end

local M = {
    DISPEL = DISPEL,
    FOG = FOG,
    MIX = MIX,
}
function M.create(size, tag)
    local map = {
        size = size,
    }
    map.root = create_node(nil, tag or FOG, 0, size - 1)
    return map
end

local function encode_node(node, arr)
    if not node then
        return
    end
    arr[#arr+1] = node.tag
    encode_node(node.left, arr)
    encode_node(node.right, arr)
end

function M.encode(map)
    local arr = {}
    encode_node(map.root, arr)
    local num = 0
    local str = ""
    for i = 0, #arr - 1 do
        local mod = i % 3
        if mod == 0 and i > 0 then
            str = str .. n2c[num]
            num = 0
        end
        local n = arr[i+1]
        n = n << 2 * mod
        num = num | n
    end
    str = str .. n2c[num]
    return str
end

function M.decode(str, size)
    local len = slen(str)
    local chars = {}
    for i = 1, len do
        local c = ssub(str, i, i)
        chars[i - 1] = c
    end
    local idx = 0
    local function pop_tag()
        local c = chars[idx//3]
        local mod = idx % 3
        local tag = c2n[c] >> 2 * mod & 3
        assert(tag <= FOG, tag)
        idx = idx + 1
        return tag
    end
    local function pop_create_node(parent, min, max)
        local node = {
            parent = parent,
            tag = pop_tag(),
            min = min,
            max = max,
        }
        if node.tag == MIX then
            local center = min + (max - min) // 2
            node.left = pop_create_node(node, min, center)
            node.right = pop_create_node(node, center + 1 < max and center + 1 or max, max)
        end
        return node
    end
    local map = {
        size = size,
    }
    map.root = pop_create_node(nil, 0, size - 1)
    return map
end

local function set_tag(map, pos, tag)
    local function revert_parent(node)
        if not node then
            return
        end
        if node.left.tag == node.right.tag then
            node.tag = node.left.tag
            node.left = nil
            node.right = nil
            revert_parent(node.parent)
        end
    end
    local function find_and_insert(node)
        if node.tag == tag then
            return
        end
        if node.min == node.max then
            node.tag = tag
            revert_parent(node.parent)
            return
        end
        local center = node.min + (node.max - node.min) // 2
        if not node.left then
            node.left = create_node(node, node.tag, node.min, center)
            node.right = create_node(node, node.tag, center + 1 < node.max and center + 1 or node.max, node.max)
            node.tag = MIX
        end

        if pos <= center then
            find_and_insert(node.left)
        else
            find_and_insert(node.right)
        end
    end
    find_and_insert(map.root)
end

function M.dispel(map, pos)
    set_tag(map, pos, DISPEL)
end

function M.fog(map, pos)
    set_tag(map, pos, FOG)
end

local function find(node, pos)
    if pos <= node.max and pos >= node.min and node.tag ~= MIX then
        return node.tag
    end
    local center = node.min + (node.max - node.min) // 2
    if pos <= center then
        return find(node.left, pos)
    else
        return find(node.right, pos)
    end
end
function M.is_fog(map, pos)
    return find(map.root, pos) == FOG
end
function M.is_dispel(map, pos)
    return find(map.root, pos) == DISPEL
end

local function clone_node(node, parent)
    if not node then
        return
    end
    local new = {
        parent = parent,
        tag = node.tag,
        max = node.max,
        min = node.min,
    }
    new.left = clone_node(node.left, new)
    new.right = clone_node(node.right, new)
    return new
end

function M.union(map1, map2)
    assert(map1.size == map2.size)
    local map = {
        size = map1.size
    }
    local function union(node1, node2, parent)
        if node1.tag == MIX and node2.tag == MIX then
            local node = {
                parent = parent,
                tag = MIX,
                min = node1.min,
                max = node2.max,
            }
            node.left = union(node1.left, node2.left, node)
            node.right = union(node1.right, node2.right, node)
            if node.left.tag == node.right.tag and node.left.tag ~= MIX then
                node.tag = node.left.tag
                node.left = nil
                node.right = nil
            end
            return node
        elseif node1.tag == node2.tag or node1.tag < node2.tag then
            return clone_node(node1, parent)
        elseif node2.tag < node1.tag then
            return clone_node(node2, parent)
        end
    end
    map.root = union(map1.root, map2.root)
    return map
end

function M.cmp(old_map, new_map)
    assert(old_map.size == new_map.size)
    local new_fog_list, new_dispel_list = {}, {}
    local function cmp(old, new)
        local old_tag = type(old) == "number" and old or old.tag
        local new_tag = type(new) == "number" and new or new.tag
        if old_tag == new_tag then
            if old_tag == MIX then
                cmp(old.left, new.left)
                cmp(old.right, new.right)
            else
                return
            end
        elseif old_tag == MIX then
            cmp(old.left, new_tag)
            cmp(old.right, new_tag)
        elseif new_tag == MIX then
            cmp(old_tag, new.left)
            cmp(old_tag, new.right)
        else
            local node = type(old) == "table" and old or new
            for pos = node.min, node.max do
                if new_tag == FOG then
                    new_fog_list[#new_fog_list+1] = pos
                else
                    new_dispel_list[#new_dispel_list+1] = pos
                end
            end
        end
    end
    cmp(old_map.root, new_map.root)
    return new_fog_list, new_dispel_list
end

return M
