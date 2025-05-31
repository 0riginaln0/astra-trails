local server = Astra.http.server:new()

local templates = Astra.new_templating_engine("templates/**/*.html")
templates:context_add("favourite_languages", "Lua, Elixir, C, Rust")
local rendered_static_template = templates:render("static/favlangs.html")

server:get("/favlangs", function(request, response)
    response:set_header("Content-Type", "text/html")
    return rendered_static_template
end)

server:get("/tier-list", function(req, res)
    res:set_header("Content-Type", "text/html")

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
end)

server:run()
