
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


# Comparison with...

## Roda

https://roda.jeremyevans.net/

```ruby
class App < Roda
  route do |r|
    r.root do
      r.redirect "/hello"
    end

    r.on "hello" do
      @greeting = 'Hello'

      r.get "world" do
        "#{@greeting} world!"
      end

      r.is do
        r.get do
          "#{@greeting}!"
        end

        r.post do
          puts "Someone said #{@greeting}!"
          r.redirect
        end
      end
    end
  end
end
```

Trails equivalent (Lua)

```lua
Routes(server) {
  base_middleware = ctx,

  { GET, "/", function(_, rp) rp:redirect_to("/hello") end },

  scope "/hello" {
    base_middleware = function(next_handler)
      return function(rq, rp, ctx)
        ctx.greeting = 'Hello'
        return next_handler(rq, rp, ctx)
      end
    end,

    { GET, "/world", function(_, _, ctx) return ctx.greeting.." world!" end },

    { GET, "", function(_, _, ctx) return ctx.greeting.."!" end },

    { POST, "", function(_, rp, ctx)
      print("Someone said "..ctx.greeting.."!")
      rp:redirect_to("/hello")
    end }
  },
}
```

Trails equivalent (MoonScript/YueScript)

```moonscript
Routes(server) {
  base_middleware: ctx

  { GET, "/", (_, rp) -> rp\redirect_to("/hello") }

  scope("/hello") {
    base_middleware: (next_handler) -> (rq, rp, ctx) ->
      ctx.greeting = "Hello"
      next_handler(rq, rp, ctx)

    { GET, "/world", (_, _, ctx) -> "#{ctx.greeting} world!" }

    { GET, "", (_, _, ctx) -> "#{ctx.greeting}!" }

    { POST, "", (_, rp, ctx) ->
      print "Someone said #{ctx.greeting}!"
      rp\redirect_to("/hello") }
  }
}
```