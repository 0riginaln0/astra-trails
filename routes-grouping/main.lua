local inspect = require("inspect").inspect

do
    if pcall(require, 'jit') then
        local x = require 'jit'
        print("Server uses:", _VERSION, x.version)
    else
        print("Server uses:", _VERSION)
    end
end

local server = Astra.http.server:new()


--#region Routes
-- Variables to reduce the use of string literals in the Routes function call.
local GET         = "GET"
local POST        = "POST"
local PUT         = "PUT"
local PATCH       = "PATCH"
local DELETE      = "DELETE"
local OPTIONS     = "OPTIONS"
local TRACE       = "TRACE"
local STATIC_DIR  = "STATIC_DIR"
local STATIC_FILE = "STATIC_FILE"


local routeTypeToAstraFunction = {
    ["GET"] = server.get,
    ["POST"] = server.post,
    ["PUT"] = server.put,
    ["PATCH"] = server.patch,
    ["DELETE"] = server.delete,
    ["OPTIONS"] = server.options,
    ["TRACE"] = server.trace,
    ["STATIC_DIR"] = server.static_dir,
    ["STATIC_FILE"] = server.static_file,
}

---Constructs a set from a list of entries, where each entry is stored as both key and a value in the resulting table.
---@param entries table A list (table) of entries to be included in the set.
---@return table set new table representing the set
local function set(entries)
    local new_set = {}; for _, value in ipairs(entries) do new_set[value] = value end
    return new_set
end

local function validateRouteParams(route, base_middleware)
    local httpRoutes = set { "GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS", "TRACE", }
    local staticRoutes = set { "STATIC_DIR", "STATIC_FILE", }
    local route_type, path, callback_or_serve_path, config = route[1], route[2], route[3], route[4]

    assert(routeTypeToAstraFunction[route_type],
        "Unknown route type `" .. route_type .. "`: " .. inspect(route))
    assert(type(path) == "string",
        "Path must be a string, got `" .. type(path) .. "`: " .. inspect(route))
    assert((type(config) == "table") or (type(config) == "nil"),
        "Config must be a table, got `" .. type(config) .. "`: " .. inspect(route))
    if httpRoutes[route_type] then
        local callback = callback_or_serve_path
        assert(type(callback) == "function",
            "Callback must be a function, got `" .. type(callback) .. "`: " .. inspect(route))
        if base_middleware then
            callback_or_serve_path = base_middleware(callback)
        end
    elseif staticRoutes[route_type] then
        local serve_path = callback_or_serve_path
        assert(type(serve_path) == "string",
            "Serve path must be a string, got `" .. type(serve_path) .. "`: " .. inspect(route))
    end

    return route_type, path, callback_or_serve_path, config
end

local function Routes(routes)
    local base_middleware = routes.base_middleware
    for _, route in ipairs(routes) do
        local route_type, path, callback_or_serve_path, config = validateRouteParams(route, base_middleware)
        routeTypeToAstraFunction[route_type](server, path, callback_or_serve_path, config)
    end
end
--#endregion


local homepage_info = {
    "I'm a homepage"
}

local function homepage()
    return table.concat(homepage_info, "\n")
end

---@param req Request
---@param res Response
local function addHomepageInfo(req, res)
    local new_info = req:queries().info
    if new_info then
        table.insert(homepage_info, new_info)
        return "New info added!"
    end
    return "Failed to add new info"
end

---@param request Request
---@param response Response
local function justHi(request, response)
    local queries = request:queries()
    local name = queries.name
    if name then
        return "Hello " .. name .. "!"
    end
    return "Hello!"
end


Routes {
    { GET,         "/",       homepage },        -- server:get("/", homepage)
    { POST,        "/",       addHomepageInfo }, -- server:post("/", addHomepageInfo)
    { GET,         "/hi",     justHi },          -- server:get("/hi", justHi)
    { STATIC_FILE, "/main",   "main.lua" },      -- server:static_file("/main", "main.lua")
    { STATIC_DIR,  "/public", "public" },        -- server:static_dir("/public", "public")
}

server:run()
