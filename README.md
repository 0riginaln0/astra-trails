# Astra Trails
Examples, hacks &amp; tricks around [Astra](https://github.com/ArkForgeLabs/Astra) - a web server runtime for Lua.


- [Middleware](middleware.md): Introducing pattern for middleware.
- [Routes grouping](routing.md): DSL to register a group of routes in one place.
- [Templating with Lustache](lustache.md): Full overview of Mustache templates in pure Lua.
- [LugSQL](lugsql.md): Turns parameterized SQL into Lua functions.
- [Preman](preman.md): Single‑file HTML API client. Grug‑approved.

Check out [main.lua](main.lua) for an app example.

Run it with:

```sh
$ astra run main.lua 
Generated sql/queries.lua with 9 queries.
        GET /
        GET /hello
        GET /tier-list
        GET /guestbook
       POST /guestbook
        GET /api/guestbook
       POST /api/guestbook
        GET /health
Server uses:    Lua 5.5
Running on http://127.0.0.1:8080
```

Short snippet:

```lua
Routes(server) {
  base_middleware = chain { ctx, logger },

  { GET,  "/",          html(homepage) },

  scope {
    base_middleware = html,
    { GET, "/hello",     function() return "hello world" end },
    { GET, "/tier-list", tier_list },
  },

  { GET,  "/guestbook", html(guestbook_page) },
  { POST, "/guestbook", post_guestbook_form },

  scope "/api" {
    { GET,  "/guestbook", get_api_guestbook },
    { POST, "/guestbook", post_api_guestbook },
  },

  { GET, "/health", function() return { status = "UP" } end },

  fallback = chain { html } (function() return "Page not Found" end)
}

require("print-server-info")(server)
server:run()
```
