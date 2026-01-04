# Astra Trails
Examples, hacks &amp; tricks around [Astra](https://github.com/ArkForgeLabs/Astra) - a web server runtime for Lua.
- [Middleware](middleware): Introducing pattern for middleware.
```lua
server:get("/sunny-day", logger(html(sunny_day)))
server:get("/normal-day", chain { logger, html } (normal_day))
server:get("/favourite-day", chain { ctx, logger, insert_datetime, html } (favourite_day))
```
- [Routes grouping](routes-grouping): DSL to register a group of routes in one place.
```lua
Routes(server) {
    base_middleware = ctx,
    { "GET",         "/",       homepage },
    { "POST",        "/",       add_homepage_info },
    { "GET",         "/hi",     just_hi },
    { "STATIC_FILE", "/main",   "main.lua" },
    { "STATIC_DIR",  "/public", "public" },
    scope "/api" {            
        scope "/v1" {
            { "GET", "/favlangs", favlangs },
        },
        scope "/v2" {
            base_middleware = html,
            { "GET", "/favlangs", favlangs2 },
        },
    },
    fallback = function(req, res)
        return "Sorry, It's 404"
    end
}
```
- [Hot reload](hot-reload): A way to hot reload your code! Very convenient during development.
- [Templating with Lustache](templating-lua): Full overview of Mustache templates in pure Lua.
- [Runtime utils](runtime-utils): Explicit cooperative multitasking.
- [Other useful code](other-useful-code): It is what it is.

---

- [Quickstart](quickstart): The Trails project template. The archived template can be downloaded directly from the [releases](https://github.com/0riginaln0/astra-trails/releases/)
