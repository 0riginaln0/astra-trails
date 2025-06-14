local server = Astra.http.server:new()

local templates = Astra.new_templating_engine("templates/**/*.html")
-- atm, the path argument of MiniJinja render function
-- must have a “\” separator if you are using Windows.
local rendered_static_template = templates:render("static\\favlangs.html", {
    favourite_languages = "Lua, Elixir, C, Rust",
})

server:get("/favlangs", function(request, response)
    response:set_header("Content-Type", "text/html")
    return rendered_static_template
end)

server:get("/tier-list", function(req, res)
    res:set_header("Content-Type", "text/html")
    local q = req:queries()    
    return templates:render("dynamic\\tier-list.html", {
        ["name"] = q.name,
        ["s"] = q.s,
        ["a"] = q.a,
        ["b"] = q.b,
        ["c"] = q.c,
        ["d"] = q.d,
        ["e"] = q.e,
        ["f"] = q.f,
    })
end)

server:run()
