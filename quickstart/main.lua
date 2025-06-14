require "globals"
local middleware = require "middleware"
local html = middleware.html
local context = middleware.context
local logger = middleware.logger
local chain = middleware.chain

local lustache = require("lustache")

local function read_all(file)
    local f = assert(io.open(file, "rb"), tostring(file) .. " is not found.")
    local content = f:read("*all")
    f:close()
    return content
end

local favlangs_template = read_all("templates/static/favlangs.html")
local rendered_favlangs = lustache:render(favlangs_template, {favourite_languages = "Lua, Elixir, C, Rust"})
local tier_list_template = read_all("templates/dynamic/tier-list.html")

local server = Astra.http.server:new()

local function favlangs()
	return rendered_favlangs
end

local function tier_list(req, res)
	res:set_header("Content-Type", "text/html")
	local q = req:queries()
	local params = { name = q.name, s = q.s, a = q.a, b = q.b, c = q.c, d = q.d, e = q.e, f = q.f }
	return lustache:render(tier_list_template, params)
end

local homepage_info = { "I'm a homepage" }

local function homepage()
    return table.concat(homepage_info, "\n")
end

local function add_homepage_info(req, res)
    local new_info = req:queries().info
    if new_info then
        table.insert(homepage_info, new_info)
        return "New info added!"
    end
    return "Failed to add new info"
end

local function just_hi(request, response)
    local name = request:queries().name
    if name then
        return "Hello " .. name .. "!"
    end
    return "Hello!"
end

Routes(server) {
    base_middleware = chain { context, logger },
    { GET,         "/",       homepage },
    { POST,        "/",       add_homepage_info },
    { GET,         "/hi",     just_hi },
    { STATIC_FILE, "/main",   "main.lua" },
    { STATIC_DIR,  "/public", "public" },
}

Routes(server) {
    base_middleware = html,
    { GET, "/favlangs",  favlangs },
    { GET, "/tier-list", logger(tier_list) },
}

server:run()

