local m = {}

--- `on Entry:`
--- Include *on Entry* description if the middleware does something before calling *next_handler*
---
--- `on Leave:`
--- Include *on Leave* description if the middleware does something after calling *next_handler*
---
--- `Depends on:`
--- Include *Depends on* description if the middleware depends on other middlewares
---
---@param next_handler function
local function middleware_template(next_handler)
    --- Next_handler is a function which represents a middleware or a handler

    --- Each middleware must return a function which accepts 3 arguments,
    --- and passes them to the next_handler
    ---@param request HTTPServerRequest
    ---@param response HTTPServerResponse
    ---@param ctx { key_inserted_by_middleware_I_depend_on: string }
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

---------------
-- Utilities --
---------------

--- Chains middlewares together in order
---@param chain table A list of middlewares
---@return function middleware Composed middleware
---
--- Functionally
--- ```lua
--- chain {context, html, logger} (handler)
--- ```
--- equals to
--- ```lua
--- context(html(logger(handler)))
--- ```
---
--- and
--- ```lua
--- chain {context, html, logger}
--- ```
--- equals to
--- ```lua
--- (function(handler)
---     handler = context(html(logger(handler)))
---     return handler
--- end)
--- ```
function m.chain(chain)
    return function(handler)
        assert(type(handler) == "function",
            "Handler must be a function, got " .. type(handler))
        for i = #chain, 1, -1 do
            local middleware = chain[i]
            assert(type(middleware) == "function",
                "Middleware must be a function, got " .. type(middleware))
            handler = middleware(handler)
        end
        return handler
    end
end

--- `on Entry:`
--- Creates a new `ctx` table and passes it as a third argument into the `next_handler`
function m.ctx(next_handler)
    return function(request, response)
        local ctx = {}
        return next_handler(request, response, ctx)
    end
end

--- `on Leave:`
--- sets `"Content-Type": "text/html; charset=utf-8"` response header
function m.html(next_handler)
    return function(request, response, ctx)
        local result = next_handler(request, response, ctx)
        response:set_header("Content-Type", "text/html; charset=utf-8")
        return result
    end
end

--- `on Entry:`
--- Logs request method and uri into the file
---@param file_handler file* A file handler opened with an append mode `io.open("filepath", "a")`
---@param flush_interval number? The number of log entries after which the file handler will be flushed
function m.file_logger(file_handler, flush_interval)
    local flush_interval = flush_interval or 1
    local flush_countdown = flush_interval
    return function(next_handler)
        return function(request, response, ctx)
            local str = string.format("[New Request %s] %s %s\n", os.date(), request:method(), request:uri())
            file_handler:write(str)

            flush_countdown = flush_countdown - 1
            if flush_countdown == 0 then
                file_handler:flush()
                flush_countdown = flush_interval
            end
            return next_handler(request, response, ctx)
        end
    end
end

function m.console_logger(next_handler)
    return function(request, response, ctx)
        print(string.format("[New Request %s] %s %s", os.date(), request:method(), request:uri()))
        return next_handler(request, response, ctx)
    end
end

return m
