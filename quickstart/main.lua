require "globals"
local middleware = require "middleware"
local chain, context, logger, html = middleware.chain, middleware.context, middleware.logger, middleware.html

local server = Astra.http.server:new()


local templates = Astra.new_templating_engine("templates/**/*.html")
templates:context_add("favourite_languages", "Lua, Elixir, C, Rust")
local rendered_static_template = templates:render("static/favlangs.html")

local function favlangs()
    return rendered_static_template
end

local function tierList(req)
    local q = req:queries()
    templates:context_add("name", q.name)
    templates:context_add("s", q.s)
    templates:context_add("a", q.a)
    templates:context_add("b", q.b)
    templates:context_add("c", q.c)
    templates:context_add("d", q.d)
    templates:context_add("e", q.e)
    templates:context_add("f", q.f)

    return templates:render("dynamic/tier-list.html")
end

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

Routes(server) {
    base_middleware = chain { context, logger },
    { GET,         "/",       homepage },
    { POST,        "/",       addHomepageInfo },
    { GET,         "/hi",     justHi },
    { STATIC_FILE, "/main",   "main.lua" },
    { STATIC_DIR,  "/public", "public" },
}

Routes(server) {
    base_middleware = chain { logger, html },
    { GET, "/tier-list", tierList },
    { GET, "/favlangs",  favlangs },
}

server:run()
