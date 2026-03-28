# Astra Trails
Examples, hacks &amp; tricks around [Astra](https://github.com/ArkForgeLabs/Astra) - a web server runtime for Lua.

```sh
astra run main.lua
```

- [Middleware](middleware.md): Introducing pattern for middleware.
- [Routes grouping](routing.md): DSL to register a group of routes in one place.
- [Templating with Lustache](lustache.md): Full overview of Mustache templates in pure Lua.

```lua
local server = require("http").server:new()

local Routes = require("routing").Routes
local scope = require("routing").scope
local GET = require("routing").GET
local POST = require("routing").POST

local logger = require("middleware").console_logger

Routes(server) {
  base_middleware = logger,
  { GET, "/", function() return "hello world" end },
  scope "/api" {
    { GET,  "/guestbook", function() return guestbook end },
    { POST, "/guestbook", handle_post_guestbook },
  }
}

server:run()
```