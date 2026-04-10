# Astra Trails
Examples, hacks, and tricks for [Astra](https://github.com/ArkForgeLabs/Astra) - a web server runtime for Lua.

- [Middleware](trails/middleware.md): Introduces patterns for middleware.
- [Routes Grouping](trails/routing.md): A DSL for registering a group of routes in one place.
- [Templating with Lustache](trails/lustache.md): A full overview of Mustache templates in pure Lua.
- [LugSQL](trails/lugsql.md): Converts parameterized SQL into Lua functions.
- [Preman](trails/preman.md): A simple API client embedded within the app.

Check out [main.lua](main.lua) for an example app.

```sh
$ astra export
```

```sh
$ astra run main.lua 
Generated sql/queries.lua with 9 queries.
        GET /
        GET /hello
        GET /tier-list
        GET /hype
       POST /hype/like
        GET /guestbook
       POST /guestbook
        GET /api/guestbook
       POST /api/guestbook
        GET /health
STATIC_FILE /preman
 STATIC_DIR /static
        GET /today
        GET /games/guess_number
       POST /games/guess_number
Server uses:    Lua 5.5
Running on http://127.0.0.1:8080
```

A (not so) short snippet:

```lua
local today_app = Routes {
  { GET, "/today", function() return "Today is "..os.date() end}
}

local app = Routes {
  middleware = chain { ctx, logger },

  { GET, "/", html(homepage) },

  scope {
    middleware = html,
    { GET,  "/hello",     function() return "hello world" end },
    { GET,  "/tier-list", tier_list },
    { GET,  "/hype",      hype_handler },
    { POST, "/hype/like", hype_like }
  },

  { GET,  "/guestbook", html(guestbook_page) },
  { POST, "/guestbook", post_guestbook_form },

  scope "/api" {
    { GET,  "/guestbook", get_api_guestbook },
    { POST, "/guestbook", post_api_guestbook },
  },

  { GET, "/health", function() return { status = "UP" } end },

  { STATIC_FILE, "/preman", "trails/preman.html" },
  { STATIC_DIR,  "/static", "static" },

  today_app,

  scope "/games" {
    scope "/guess_number" {
      require("guess_number_game")
    }
  },


  fallback = chain { html } (function() return "Page not Found" end)
}

app(server)

require("print-server-info")(server)
server:run()
```
