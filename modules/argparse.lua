local bash = require "bash"
return {
    name = "argparse",
    process = function (workdir)
        bash.execute "cp 3rd/argparse/src/argparse.lua ${workdir}/lualib"
    end
}