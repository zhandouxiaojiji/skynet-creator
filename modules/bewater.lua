local bash = require "bash"
return {
    name = "bewater",
    process = function (workdir)
        bash.execute "cp -r templates/lualib/bw ${workdir}/lualib"
        bash.execute "cp -r templates/lualib/def ${workdir}/lualib"
    end
}