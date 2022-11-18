local api = {}

function api.__call(_, url)
    return api[url]
end

local function not_found(_, k)
    error(string.format("index '%s' is not found"))
end

function api.typedef(protocol)
    api[protocol.url] = protocol

    -- for client event dispatcher
    local name = protocol.name
    if name then
        local ns = api
        for v in string.gmatch(name, "([^.]+)[.]") do
            ns[v] = rawget(ns, v) or setmetatable({}, {__index = not_found})
            ns = ns[v]
        end
        ns[string.match(name, "[%w_]+$")] = protocol.url
    end
end

return setmetatable(api, api)