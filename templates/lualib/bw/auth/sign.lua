local md5       = require "md5"
local openssl   = require "openssl"

local string_format = string.format
local string_upper  = string.upper
local table_sort    = table.sort
local table_concat  = table.concat

local function encode_uri(s)
    s = string.gsub(s, "([^A-Za-z0-9])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
    return s
end

local M = {}
-- mark 参数是否加引号
function M.concat_args(args, mark)
    local list = {}
    for k, v in pairs(args) do
        if v ~= '' then
            list[#list+1] = string_format(mark and '%s="%s"' or '%s=%s', k, v)
        end
    end
    table_sort(list, function(a, b)
        return a < b
    end)
    return table_concat(list, "&")
end

function M.md5_args(args, key, mark)
    local str = M.concat_args(args, mark)
    if key then
        str = str .. (#str > 0 and "&key=" or "key=") .. key
    end
    return string_upper(md5.sumhexa(str))
end

local function rsa_sign(args, private_key, mark, sign_type)
    local evp = openssl.pkey.read(private_key, true)
    local str = M.concat_args(args, mark)
    return encode_uri(openssl.base64(evp:sign(str, sign_type)))
end

function M.rsa_sign(args, private_key, mark)
    return rsa_sign(args, private_key, mark, "sha1")
end

function M.rsa_sha256_sign(args, private_key, mark)
    return rsa_sign(args, private_key, mark, "sha256")
end

return M
