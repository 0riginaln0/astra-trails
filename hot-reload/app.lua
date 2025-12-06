local handlers; if Hot_Reload_Enabled then handlers = dofile("some-handlers.lua") else handlers = require("some-handlers") end

server:get("/", function (request, response)
    return "Hello there. I was reloaded "..Times_Reloaded.." times!"
end)

server:get("/1", handlers.one)

server:get("/2", handlers.two)
