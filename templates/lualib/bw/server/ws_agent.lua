local skynet    = require "skynet"
local socket    = require "skynet.socket"
local websocket = require "http.websocket"
local json      = require "cjson.safe"
local log       = require "bw.log"
local bewater   = require "bw.bewater"
local errcode   = require "def.errcode"

local type = type
local string = string

local fd2role = {}
local role2fd = {}

local protocol, pack, unpack, process, is_binary, onclose

local function default_pack(ret)
    return json.encode(ret)
end

local function default_unpack(str)
    return json.decode(str)
end

local M = {}

local ws = {}
function ws.connect(fd)
    log.debugf("ws connect from: %s", fd)
end

function ws.handshake(fd, header, url)
    local addr = websocket.addrinfo(fd)
    log.debugf("ws handshake from: %s, url:%s, addr:%s", fd, url, addr)
end

function ws.message(fd, msg)
    --log.debugf("on message, fd:%s, msg:%s", fd, msg)
    local req = unpack(msg)
    --log.debug("unpack", req)

    local function response(data)
        if type(data) == "number" then
            data = {err = data}
        end
        data.err = data.err or 0

        websocket.write(fd, pack {
            name = string.gsub(req.name, "c2s", "s2c"),
            session = req.session,
            data = data,
        }, is_binary and "binary" or "text")
    end

    local mod, name = string.match(req.name, "(%w+)%.(.+)$")
    if not process[mod] or not process[mod][name] then
        return response(errcode.PROTOCOL_NOT_FOUND)
    end
    if not bewater.try(function()
        local role = fd2role[fd]
        local func = process[mod][name]
        response(func(role, req.data, fd) or 0)
    end) then
        return response(errcode.TRACEBACK)
    end
end

function ws.ping(fd)
    log.debug("ws ping from: " .. tostring(fd) .. "\n")
end

function ws.pong(fd)
    log.debug("ws pong from: " .. tostring(fd))
end

function ws.close(fd, code, reason)
    log.debug("ws close from: " .. tostring(fd), code, reason)
    M.close(fd)
end

function ws.error(fd)
    print("ws error from: " .. tostring(fd))
    M.close(fd)
end

function M.start(handler)
    protocol  = handler.protocol or "ws"
    pack      = handler.pack or default_pack
    unpack    = handler.unpack or default_unpack
    onclose   = handler.onclose
    is_binary = handler.is_binary
    process   = assert(handler.process)

    skynet.start(function()
        skynet.dispatch("lua", function(_,_, cmd, ...)
            local f = assert(M[cmd], cmd)
            bewater.ret(f(...))
        end)
    end)
end

function M.open(fd, addr)
    log.debug("open", fd, protocol, addr)
    local ok, err = websocket.accept(fd, ws, protocol, addr)
    if not ok then
        log.error(err)
    end
end

function M.close(fd)
    local role = fd2role[fd]
    websocket.close(fd)
    M.unbind_fd_role(fd, role)
    if onclose then
        onclose(role)
    end
end

function M.bind_fd_role(fd, role)
    assert(fd)
    assert(role)

    M.unbind_fd_role(role2fd[role], fd2role[fd])

    fd2role[fd] = role
    role2fd[role] = fd
end

function M.unbind_fd_role(fd, role)
    if fd then
        fd2role[fd] = nil
    end
    if role then
        role2fd[role] = nil
    end
end

function M.send(role, opname, data)
    local fd = role2fd[role]
    if not fd then
        return
    end

    websocket.write(fd, pack {
        name    = opname,
        data    = data,
        session = 0,
    }, is_binary and "binary" or "text")
end

return M
