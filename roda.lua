local server = require("http").server:new()

local routing = require("routing")
local Routes, scope = routing.Routes, routing.scope
local GET, POST, STATIC_FILE = routing.GET, routing.POST, routing.STATIC_FILE

local ctx = require("middleware").context
local logger = require("middleware").console_logger
local chain = require("middleware").chain

Routes(server) {
  middleware = ctx,

  { GET, "/", function(rq, rp) rp:redirect_to("/hello") end },

  scope "/hello" {
    middleware = function(next_handler)
      return function(rq, rp, ctx)
        ctx.greeting = 'Hello'
        return next_handler(rq, rp, ctx)
      end
    end,

    { GET, "/world", function(_, _, ctx) return ctx.greeting.." world!" end },

    { GET, "",       function(_, _, ctx) return ctx.greeting.."!" end },

    { POST, "", function(_, rp, ctx)
      print("Someone said "..ctx.greeting.."!")
      rp:redirect_to("/hello")
    end }
  },

  { STATIC_FILE, "/preman", "preman.html" },

}

server:run()
