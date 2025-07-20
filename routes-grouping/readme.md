This example shows how to create a `Routes` function which enables alternative way for defining routes:

```lua
Routes(server) {
    base_middleware = ctx,
    { "GET",         "/",       homepage },
    { "POST",        "/",       add_homepage_info },
    { "GET",         "/hi",     just_hi },
    { "STATIC_FILE", "/main",   "main.lua" },
    { "STATIC_DIR",  "/public", "public" },

    scope "/api" {
        { "GET", "", api_description },
        
        scope "/v1" {
            { "GET", "/favlangs", favlangs },
        },

        scope "/v2" {
            base_middleware = html,
            { "GET", "/favlangs", favlangs2 },
        },
    },
}

```

Read more about why we can drop parenthesis while calling `Routes` and `scope` functions here: [Writing a DSL in Lua](https://leafo.net/guides/dsl-in-lua.html)
