require "globals"
local middleware = require "middleware"
local html = middleware.html
local context = middleware.context
local logger = middleware.logger
local chain = middleware.chain

local server = Astra.http.server:new()

local templates = Astra.new_templating_engine("templates/**/*.html")
templates:context_add("favourite_languages", "Lua, Elixir, C, Rust")
local rendered_static_template = templates:render("static/favlangs.html")

local function favlangs()
    return rendered_static_template
end

local function tier_list(req)
    local q = req:queries()
    for _, param in ipairs {"name", "s", "a", "b", "c", "d", "e", "f"} do
        templates:context_add(param, q[param])
    end
    return templates:render("dynamic/tier-list.html")
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
    { GET, "/favlangs",  html (favlangs) },
    { GET, "/tier-list", chain { logger, html } (tier_list) },
}

server:run()

