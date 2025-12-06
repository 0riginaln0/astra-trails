local http = require("http")
local server = http.server:new()
local handlers = require("some-handlers")

server:get("/", function (request, response)
    return "Hello there!!"
end)

server:get("/1", handlers.one)

server:get("/2", handlers.two)

server:run()