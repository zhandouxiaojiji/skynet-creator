local bash = require "bash"
return {
    name = "behavior3",
    process = function (workdir)
        bash.execute "cp -r templates/lualib/revent.lua ${workdir}/lualib"
    end
}