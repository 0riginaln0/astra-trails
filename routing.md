
```lua
Routes(server) {
  base_middleware = ctx,
  { "GET", "/", homepage },
  scope "/api" {
    { "GET",  "/todos", todos },
    { "POST", "/todos", post_todo },
  }
  scope {
     base_middleware = auth,
     { "GET", "/admin", dashboard },
  }
}
```
Read more about why we can drop parenthesis while calling `Routes` and `scope` functions here: [Writing a DSL in Lua](https://leafo.net/guides/dsl-in-lua.html)
