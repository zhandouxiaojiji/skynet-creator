local bash = require "bash"
return {
    name = "uuid",
    process = function (workdir)
        bash.execute("cp 3rd/uuid/src/uuid.lua ${workdir}/lualib")
    end
}