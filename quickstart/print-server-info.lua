local function print_server_info(server)
    if pcall(require, 'jit') then
        local x = require('jit'); print("Server uses:", _VERSION, x.version)
    else
        print("Server uses:", _VERSION)
    end
    print("Running on http://" .. server.hostname .. ":" .. server.port)
end

return print_server_info