local http = require("http")
local server = http.server:new()
local handlers = require("some-handlers")
local h2 = require("lib.some")

server:get("/", function (request, response)
    return "Hello there!!!!"
end)

server:get("/1", handlers.one)

server:get("/2", handlers.two)

server:get("/3", h2.three)

server:get("/4", h2.four)

server:run()
