local bash = require "bash"
return {
    name = "argparse",
    process = function (workdir)
        bash.execute "cp templates/lualib/argparse.lua ${workdir}/lualib"
    end
}