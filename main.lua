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
parser:option("--force"):default("false"):description("force remove if workdir is exist")
parser:argument("workdir"):description("the path of skynet project you want to create.")

local args = parser:parse()
local root = args.workdir

-- mkdir
echo "workdir: ${root}"
if args.force == "true" then
    bash.execute "rm -rf ${root}"
else
    if file_exists(root) then
        echo "${root} is already create!"
        return
    end
end
bash.execute "mkdir -p ${root}"
bash.execute "cd ${root} && git init -b main"

-- skynet
if not file_exists("${root}/skynet") then
    echo "add skynet: ${github.skynet}"
    bash.execute "cd ${root} && git submodule add ${github.skynet}"
end

bash.execute "mkdir -p ${root}/lualib"
bash.execute "cp templates/lualib/* ${root}/lualib/"

bash.execute "mkdir -p ${root}/service"
bash.execute "cp templates/service/* ${root}/service/"

bash.execute "mkdir -p ${root}/etc"
bash.execute "cp templates/etc/* ${root}/etc/"
