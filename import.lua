package.path = "lualib/?.lua;"..package.path

local argparse = require "argparse"
local bash = require "bash"
local github = require "github"
local modules = require "modules"

local function echo(str)
    print(bash.format(str))
end

local function file_exists(str)
    return bash.file_exists(bash.format(str))
end

echo "welcome to skynet creator !"

local parser = argparse("main.lua")
parser:description("skynet creator import tool")
parser:option("--force"):default("false"):description("force remove if workdir is exist")
parser:argument("workdir"):description("the path of skynet project you want to import.")
parser:argument("modules"){args = "*"}:description("the modules you want to import.")

local args = parser:parse()

local root = args.workdir
if not file_exists(root) then
    echo "workdir ${root} is not exist"
    return
end

for _, name in pairs(args.modules) do
    modules.import(root, name)
end