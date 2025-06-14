local lustache = require("lustache")
local read_all
read_all = function(file)
	local f = assert(io.open(file, "rb"), tostring(file) .. " is not found.")
	local content = f:read("*all")
	f:close()
	return content
end
local server = Astra.http.server:new()
local favlangs_template = read_all("templates/static/favlangs.html")
local rendered_static_template = lustache:render(favlangs_template, {
	favourite_languages = "Lua, Elixir, C, Rust"
})
server:get("/favlangs", function(request, response)
	response:set_header("Content-Type", "text/html")
	return rendered_static_template
end)
local tier_list_template = read_all("templates/dynamic/tier-list.html")
server:get("/tier-list", function(req, res)
	res:set_header("Content-Type", "text/html")
	local q = req:queries()
	local params = {
		name = q.name,
		s = q.s,
		a = q.a,
		b = q.b,
		c = q.c,
		d = q.d,
		e = q.e,
		f = q.f
	}
	return lustache:render(tier_list_template, params)
end)
return server:run()
