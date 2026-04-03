Routes(server) {
  { GET, "/", function() return { redirect = "/hello" } end },

  scope "/hello" {
    base_middleware = (function (rq, rs, ctx) ctx.greeting = "hello" end),

    { GET, "/world", function(_,_,ctx) return ctx.greeting .. " world!" end },

    { GET, "/", function(_,_,ctx) return ctx.greeting .. "!" end },

    { POST, "/", function(_,_,ctx)
      print("Someone said " .. ctx.greeting .. "!")
      return { redirect = "/" }
    end },
  },
}

