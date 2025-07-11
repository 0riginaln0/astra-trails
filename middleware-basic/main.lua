local inspect = require("inspect").inspect

local server = Astra.http.server:new()

--#region Middleware

local function my_middleware(next_handler)
    ---@param request HTTPServerRequest
    ---@param response HTTPServerResponse
    return function(request, response, ctx)
        -- Pre-handler logic
        if "something wrong" then
            return "Waaait a minute."
        end
        local result = next_handler(request, response, ctx)
        -- Post-handler logic
        if "you came up with a use case" then
            local things = "Do some on-Leave logic"
        end
        return result
    end
end

local function context(next_handler)
    ---@param request HTTPServerRequest
    ---@param response HTTPServerResponse
    return function(request, response)
        local ctx = {}
        ctx.data_for_next_handler = 42
        local result = next_handler(request, response, ctx)
        return result
    end
end

local function logger(next_handler)
    ---@param request HTTPServerRequest
    ---@param response HTTPServerResponse
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
local function chain(chain)
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
--#endregion

---@param req HTTPServerRequest
---@param res HTTPServerResponse
local function homepage(req, res)
    res:set_header("Content-Type", "text/html")
    return "Hi there!"
end

---@param req HTTPServerRequest
---@param res HTTPServerResponse
---@param ctx table
local function someHandler(req, res, ctx)
    return "I got `" .. tostring(ctx.data_for_next_handler) .. "` from context"
end


server:get("/", logger(homepage))
server:get("/ctx", chain { context, logger } (someHandler)) -- same as context(logger(someHandler))

server:run()
