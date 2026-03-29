# Astra Trails
Examples, hacks &amp; tricks around [Astra](https://github.com/ArkForgeLabs/Astra) - a web server runtime for Lua.


- [Middleware](middleware.md): Introducing pattern for middleware.
- [Routes grouping](routing.md): DSL to register a group of routes in one place.
- [Templating with Lustache](lustache.md): Full overview of Mustache templates in pure Lua.


Check out [main.lua](main.lua) for the app example.

Run it with:

```sh
$ astra run main.lua 
        GET /
        GET /hello
        GET /tier-list
       POST /api/guestbook
        GET /api/guestbook
        GET /health
Server uses:    Lua 5.5
Running on http://127.0.0.1:8080
```

Short snippet:

```lua
Routes(server) {
  base_middleware = logger,

  { GET, "/", html(homepage_handler)},

  scope {
    base_middleware = html,
    { GET, "/hello", function() return "hello world" end },
    { GET, "/tier-list", handle_tier_list },
  },

  scope "/api" {
    { POST, "/guestbook", handle_post_guestbook },
    { GET,  "/guestbook", function() return guestbook end },
  },

  { GET, "/health", function() return { status = "UP" } end },

  fallback = chain {html} (function() return "Page not Found" end)
}

require("print-server-info")(server)
server:run()
```
