local bash = require "bash"
return {
    name = "behavior3",
    process = function (workdir)
        bash.execute "cp -r templates/lualib/behavior3 ${workdir}/lualib"
    end
}