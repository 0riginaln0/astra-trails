local inspect = require("inspect").inspect

local m = {}

function m.context(next_handler)
    ---@param request Request
    ---@param response Response
    return function(request, response)
        local ctx = {}
        ctx.data_for_next_handler = 42
        local result = next_handler(request, response, ctx)
        return result
    end
end

function m.logger(next_handler)
    ---@param request Request
    ---@param response Response
    ---@param ctx table
    return function(request, response, ctx)
        -- Entry part
        print("Request:", request:method(), request:uri(), inspect(request:queries()))
        local result = next_handler(request, response, ctx)
        -- Leave part
        return result
    end
end

---Chains route middleware
function m.chain(chain)
    return function(handler)
        assert(type(handler) == "function",
            "Handler must be a function, got " .. type(handler))
        assert(#chain >= 2, "Chain must have at least 2 middlewares")
        for i = #chain, 1, -1 do
            local middleware = chain[i]
            assert(type(middleware) == "function",
                "Middleware must be a function, got " .. type(middleware))
            handler = middleware(handler)
        end
        return handler
    end
end

function m.html(next_handler)
    ---@param request Request
    ---@param response Response
    return function(request, response, ctx)
        response:set_header("Content-Type", "text/html")
        return next_handler(request, response, ctx)
    end
end

return m
