local bash = require "bash"
return {
    name = "fsm",
    process = function (workdir)
        bash.execute "cp templates/lualib/fsm.lua ${workdir}/lualib"
    end
}