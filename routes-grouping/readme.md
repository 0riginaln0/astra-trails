This example shows how to create a `Routes` function which will enable alternative way for defining routes:

```lua
Routes {
    { GET,         "/",       homepage },
    { POST,        "/",       add_homepage_info },
    { GET,         "/hi",     justHi },
    { STATIC_FILE, "/main",   "main.lua" },
    { STATIC_DIR,  "/public", "public" },
}
```

Read more about why we can drop parenthesis while calling `Routes` function here: [Writing a DSL in Lua](https://leafo.net/guides/dsl-in-lua.html)