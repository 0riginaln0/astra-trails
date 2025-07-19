if pcall(require, 'jit') then
    local x = require('jit'); print("Server uses:", _VERSION, x.version)
else
    print("Server uses:", _VERSION)
end

local server = Astra.http.server:new()

local middleware = Astra.http.middleware
local html = middleware.html
local ctx = middleware.context

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
local function addHomepageInfo(req)
    local new_info = req:queries().info
    if new_info then
        table.insert(homepage_info, new_info)
        return "New info added!"
    end
    return "Failed to add new info"
end

---@param request HTTPServerRequest
local function justHi(request)
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
    return { "Lua, Elixir, Rust, Odin" }
end

Routes(server) {
    base_middleware = ctx,
    { "GET",         "/",       homepage },
    { "POST",        "/",       addHomepageInfo },
    { "GET",         "/hi",     justHi },
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
