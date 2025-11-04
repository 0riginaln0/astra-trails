local http   = require("astra.lua.http")
local server = http.server:new()


local middleware     = require "middleware"
local html           = middleware.html
local ctx            = middleware.ctx
local chain          = middleware.chain
local file_logger    = middleware.file_logger
local console_logger = middleware.console_logger


local routing = require "routing"
local Routes  = routing.Routes
local scope   = routing.scope


local function homepage()
    return "I'm a homepage"
end


local file_handler, err = io.open("logs.txt", "a"); if not file_handler then error(err) end
local file_logger = file_logger(file_handler)


Routes(server) {
    base_middleware = chain { file_logger, console_logger },
    { "GET", "/", homepage },
}


require "print-server-info" (server)
server:run()
