local http     = require("http")
local server   = http.server:new()

local Routes   = require("trails.routing").Routes
local scope    = require("trails.routing").scope

local context  = require("trails.middleware").ctx
local chain    = require("trails.middleware").chain

local lustache = require("trails.templates.lustache")

--- Homepage
---@param req HTTPServerRequest
---@param res HTTPServerResponse
---@param ctx any
---@return string
local function homepage(req, res, ctx)
    return "Homepage"
end

Routes(server) {
    base_middleware = context,
    { "GET", "/", homepage }
}

require("trails.other-useful-code.print-server-info")(server)
server:run()
