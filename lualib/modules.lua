local bash = require "bash"

local modules = {
    {
        name = "lua-cjson",
        submodule = "https://github.com/cloudwu/lua-cjson.git",
        make = "lua-cjson.mk",
    }
}

local function echo(str)
    print(bash.format(str))
end

local function file_exists(str)
    return bash.file_exists(bash.format(str))
end

local function get_module_conf(name)
    for _, module in pairs(modules) do
        if module.name == name then
            return module
        end
    end
end

local M = {}
function M.import(root, name)
    echo "import module ${name}"
    local conf = assert(get_module_conf(name), "not found module "..name)
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
end
return M