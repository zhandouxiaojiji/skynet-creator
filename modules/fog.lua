local bash = require "bash"
return {
    name = "fog",
    process = function (workdir)
        bash.execute "cp -r templates/lualib/fog.lua ${workdir}/lualib"
    end
}