if pcall(require, 'jit') then
    local x = require('jit'); print("Server uses:", _VERSION, x.version)
else
    print("Server uses:", _VERSION)
end

local http = require "http"
local server = http.server:new()

local routing = require("routing")
local Routes = routing.Routes
local scope = routing.scope

local homepage_info = {
    "I'm a homepage"
}

local function homepage()
    return table.concat(homepage_info, "\n")
end

---@param req HTTPServerRequest
local function add_homepage_info(req)
    local new_info = req:queries().info
    if new_info then
        table.insert(homepage_info, new_info)
        return "New info added!"
    end
    return "Failed to add new info"
end

---@param request HTTPServerRequest
local function just_hi(request)
    local queries = request:queries()
    local name = queries.name
    if name then
        return "Hello " .. name .. "!"
    end
    return "Hello!"
end

local function api_description()
    return "We have api v1 and v2"
end

local function favlangs()
    return { "Lua, Elixir, Rust, C" }
end

local function favlangs2()
    return { "Lua, Elixir, Odin" }
end

--- `on Leave:`
--- sets `"Content-Type": "text/html"` response header
local function html(next_handler)
    return function(request, response, ctx)
        local result = next_handler(request, response, ctx)
        response:set_header("Content-Type", "text/html")
        return result
    end
end

--- `on Entry:`
--- Creates a new `ctx` table and passes it as a third argument into the `next_handler`
local function context(next_handler)
    return function(request, response)
        local ctx = {}
        return next_handler(request, response, ctx)
    end
end

Routes(server) {
    base_middleware = context,
    { "GET",         "/",       homepage },
    { "POST",        "/",       add_homepage_info },
    { "GET",         "/hi",     just_hi },
    { "STATIC_FILE", "/main",   "main.lua" },
    { "STATIC_DIR",  "/public", "public" },

    scope "/api" {
        { "GET", "", api_description },

        scope "/v1" {
            { "GET", "/favlangs", favlangs },
        },

        scope "/v2" {
            base_middleware = html,
            { "GET", "/favlangs", favlangs2 },
        },
    },
}
server:run()
