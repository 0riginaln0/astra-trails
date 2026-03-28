# Astra Trails
Examples, hacks &amp; tricks around [Astra](https://github.com/ArkForgeLabs/Astra) - a web server runtime for Lua.


- [Middleware](middleware.md): Introducing pattern for middleware.
- [Routes grouping](routing.md): DSL to register a group of routes in one place.
- [Templating with Lustache](lustache.md): Full overview of Mustache templates in pure Lua.


Check out [main.lua](main.lua) for the app example.

Run it with:

```sh
astra run main.lua
```

Short snippet:

```lua
Routes(server) {
  base_middleware = logger,

  scope {
    base_middleware = html,
    { GET, "/",          function() return "hello world" end },
    { GET, "/tier-list", handle_tier_list },
  },

  scope "/api" {
    { POST, "/guestbook", handle_post_guestbook },
    { GET,  "/guestbook", function() return guestbook end },
  },

  { GET, "/health", function() return { status = "UP" } end },

  fallback = chain {html} (function() return "Page not Found" end)
}

server:run()
```