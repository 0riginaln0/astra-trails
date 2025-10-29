local http = require("astra.lua.http")
local datetime = require("astra.lua.datetime")
local server = http.server:new()
local chain = http.middleware.chain

local function sunny_day(_request, _response)
    return "What a great sunny day!"
end

local function normal_day(_request, _response)
    return "It's a normal day... I guess..."
end

---@param ctx { datetime: DateTime }
local function favourite_day(_request, _response, ctx)
    local today = string.format(
        "%d/%d/%d",
        ctx.datetime:get_day(),
        ctx.datetime:get_month(),
        ctx.datetime:get_year()
    )
    return "My favourite day is " .. today
end

--- `on Entry:`
--- Creates a new `ctx` table and passes it as a third argument into the `next_handler`
local function ctx(next_handler)
    return function(request, response)
        local ctx = {}
        return next_handler(request, response, ctx)
    end
end

--- `on Entry:`
--- Inserts `datetime.new()` into `ctx.datetime`
---
--- `Depends on:`
--- `ctx`
local function insert_datetime(next_handler)
    return function(request, response, ctx)
        ctx.datetime = datetime.new()
        return next_handler(request, response, ctx)
    end
end

--- `on Leave:`
--- sets `"Content-Type": "text/html"` response header
local function html(next_handler)
    return function(request, response, ctx)
        local result = next_handler(request, response, ctx)
        response:set_header("Content-Type", "text/html")
        return result
    end
end

--- `on Entry:`
--- Logs request method and uri into the file
---@param file_handler file* A file handler opened with an append mode `io.open("filepath", "a")`
---@param flush_interval number? The number of log entries after which the file handler will be flushed
local function file_logger(file_handler, flush_interval)
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
local file_handler, err = io.open("logs.txt", "a")
if not file_handler then error(err) end
local logger = file_logger(file_handler)

server:get("/sunny-day", logger(html(sunny_day)))
server:get("/normal-day", chain { logger, html } (normal_day))
server:get("/favourite-day", chain { ctx, logger, insert_datetime, html } (favourite_day))

server:run()