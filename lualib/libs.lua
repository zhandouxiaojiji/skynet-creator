local bash = require "bash"

local function echo(str)
    print(bash.format(str))
end

local function file_exists(str)
    return bash.file_exists(bash.format(str))
end

local M = {}
function M.import(root, name)
    echo "import module ${name}"
    local conf = require("modules."..name)
    if conf.submodule then
        bash.execute "mkdir -p ${root}/3rd"
        if not file_exists("${root}/3rd/${name}") then
            bash.execute "cd ${root} && git submodule add ${conf.submodule} 3rd/${name}"
        end
    end

    if conf.make then
        bash.execute "cp -v templates/make/${conf.make} ${root}/make"
        bash.execute "cd ${root} && make"
    end

    if conf.process then
        conf.process(root)
    end
end
return M