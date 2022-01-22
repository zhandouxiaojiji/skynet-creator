package.path = "lualib/?.lua;"..package.path

local argparse = require "argparse"

print "welcome to skynet creator !"

local parser = argparse("main.lua")
parser:description("skynet creator")
parser:argument("workdir"):description("workdir")

local args = parser:parse()
print("workdir", args.workdir)