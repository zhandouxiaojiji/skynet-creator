local skynet  = require "skynet.manager"
local mongo   = require "skynet.db.mongo"
local bewater = require "bw.bewater"
local util    = require "bw.util"
local log     = require "bw.log"

local db

local M = {}
function M.find_one(name, query, selector)
    local data = db[name]:findOne(query, selector)
    return util.str2num(data)
end

function M.find_one_with_default(name, query, default, selector)
    local data = db[name]:findOne(query, selector)
    if not data then
        M.insert(name, default)
        return default
    end
    return util.str2num(data)
end

-- todo 此方法返回可能大于消息长度
function M.find(name, query, selector)
    local ret = db[name]:find(query, selector)
    local data = {}
    while ret:hasNext() do
        table.insert(data, ret:next())
    end
    return util.str2num(data)
end

function M.update(name, query_tbl, update_tbl)
    update_tbl = util.num2str(update_tbl)
    local ok, err, r = db[name]:findAndModify({query = query_tbl, update = update_tbl})
    if not ok then
        log.error("mongo update error", r)
        error(err)
    end
    return true
end

function M.insert(name, tbl)
    tbl = util.num2str(tbl)
    local ok, err, r = db[name]:safe_insert(tbl)
    if not ok then
        log.error("mongo update error", r)
        error(err)
    end
    return true
end

function M.delete(name, query_tbl)
    db[name]:delete(query_tbl)
    return true
end

function M.drop(name)
    return db[name]:drop()
end

function M.get(key, default, key_str)
    local ret = db.global:findOne({key = key})
    if ret then
        if key_str then
            return ret.value
        else
            return util.str2num(ret.value)
        end
    else
        db.global:safe_insert({key = key, value = default})
        return default
    end
end

function M.set(key, value, keep_str)
    if not keep_str then
        value = util.num2str(value)
    end
    db.global:findAndModify({
        query = {key = key},
        update = {key = key, value = value},
    })
end

return function(conf)
    skynet.start(function()
        assert(conf.host and conf.port and conf.name)
        db = mongo.client({
            host = conf.host,
            port = conf.port,
        })[conf.name]

        if conf.collections then
            for cname, collection in pairs(conf.collections) do
                local obj = db[cname]
                for _, v in ipairs(collection.indexes or {}) do
                    local ret = obj:ensureIndex(v.key, v.option or {})
                    if ret.ok then
                        if ret.numIndexesBefore ~= ret.numIndexesAfter then
                            log.info("create_index", v.key, ret)
                        end
                    else
                        log.error("create_index error", ret)
                    end
                end
            end
        end

        skynet.dispatch("lua", function(_, _, cmd, ...)
            local f = assert(M[cmd], cmd)
            bewater.ret(f(...))
        end)
    end)
end
