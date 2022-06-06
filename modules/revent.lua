local bash = require "bash"
return {
    name = "revent",
    process = function (workdir)
        bash.execute "cp -r templates/lualib/revent.lua ${workdir}/lualib"
    end
}