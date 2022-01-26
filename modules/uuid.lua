local bash = require "bash"
return {
    name = "uuid",
    process = function (workdir)
        bash.execute("cp templates/lualib/uuid.lua ${workdir}/lualib")
    end
}