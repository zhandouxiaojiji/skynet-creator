package.path = "lualib/?.lua;"..package.path

local argparse = require "argparse"
local bash = require "bash"
local github = require "github"

local function echo(str)
    print(bash.format(str))
end

local function file_exists(str)
    return bash.file_exists(bash.format(str))
end

echo "welcome to skynet creator !"

local parser = argparse("main.lua")
parser:description("skynet creator")
parser:argument("root"):description("root")

local args = parser:parse()
local root = args.root

-- mkdir
echo "workdir: ${root}"
if not file_exists(root) then
    bash.execute "mkdir -p ${root}"
    bash.execute "cd ${root} && git init -b main"
end

if not file_exists("${root}/skynet") then
    echo "add skynet: ${github.skynet}"
    bash.execute "cd ${root} && git submodule add ${github.skynet}"
end