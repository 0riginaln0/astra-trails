
```lua
Routes(server) {
  middleware = ctx,
  { "GET", "/", homepage },
  scope "/api" {
    { "GET",  "/todos", todos },
    { "POST", "/todos", post_todo },
  }
  scope {
     middleware = auth,
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
  middleware = ctx,

  { GET, "/", function(_, rp) rp:redirect_to("/hello") end },

  scope "/hello" {
    middleware = function(next_handler)
      return function(rq, rp, ctx)
        ctx.greeting = 'Hello'
        return next_handler(rq, rp, ctx)
      end
    end,

    { GET, "/world", function(_, _, ctx) return ctx.greeting.." world!" end },

    { GET, "", function(_, _, ctx) return ctx.greeting.."!" end },

    { POST, "", function(_, rp, ctx)
      print("Someone said "..ctx.greeting.."!")
      rp:redirect_to(rq:uri())
    end }
  },
}
```

Trails equivalent (MoonScript/YueScript)

```moonscript
Routes(server) {
  middleware: ctx

  { GET, "/", (_, rp) -> rp\redirect_to("/hello") }

  scope("/hello") {
    middleware: (next_handler) -> (rq, rp, ctx) ->
      ctx.greeting = "Hello"
      next_handler(rq, rp, ctx)

    { GET, "/world", (_, _, ctx) -> "#{ctx.greeting} world!" }

    { GET, "", (_, _, ctx) -> "#{ctx.greeting}!" }

    { POST, "", (_, rp, ctx) ->
      print "Someone said #{ctx.greeting}!"
      rp\redirect_to(rq\uri()) }
  }
}
```

Roda 2

```ruby
Roda.route do |r|
  access_check!(r.ip)
  r.on "employee", Integer do |employee_id|
    next unless employee = Employee[employee_id]

    r.is "name" do
      r.get do
        "Hello #{employee.name}"
      end

      r.post do
        employee.update(name: r.params['name'])
        r.redireect
      end
    end
end
```

Trails
```moonscript
server = require("http").server.new!
:Routes, :scope, :GET, :POST = require("routing")
context: ctx, :chain = require("middleware")

not_found = (next_handler) -> (rq, rp, ctx) ->
  ok, result = pcall(next_handler, rq, rp, ctx)
  if ok
    return result
  if result.status == 404
    rp\set_status_code(404)
    result.message

Employee = {
  [1]: {name: "Bob"}
  [2]: {name: "Boba"}
  [3]: {name: "Bobab"}
}

Routes(server) {
  middleware: chain [ctx, not_found]

  scope("/employee/{employee_id}") {
    middleware: (next_handler) -> (rq, rp, ctx) ->
      employee_id = rq\params().employee_id

      if type(employee_id) ~= "number"
        error status: 404, message: "Employee not found. id is not a number"

      ctx.employee = Employee[employee_id]
      
      unless ctx.employee
        error status: 404, message: "Employee not found"
      
      next_handler(rq, rp, ctx)
       
    { GET, "/name", (_, _, ctx) -> "Hello #{ctx.employee.name}" }

    { POST, "/name", (rq, rp, ctx) ->
      ctx.employee.name = rq\queries()['name']
      rp\redirect_to(rq\uri()) }
  }
}

server\run!
```
