local http = require "astra.lua.http"
local server = http.server:new()

local function yield()
    spawn_task(function() end):await()
end

local homepage = 0
server:get("/", function(req,res)
    print("homepage start")
    homepage = homepage + 1
    print("homepage finish")
    return "homepage" .. tostring(homepage)
end)

local ctx = 0
server:get("/ctx", function(req,res)
    print("ctx start")
    print("ctx start thinking")
    -- Simulating a long-running task
    for i = 1, 70000000 do
        -- Suspends execution 70 times
        if i % 1000000 == 0 then
            print("yield #" .. tostring(i/1000000))
            -- Try to comment out the following line and check if "/" requests will be handled while the "/ctx" is running
            yield()
        end
        ctx = ctx + 2
        ctx = ctx - 1
    end
    print("ctx finished thinking")
    print("ctx finish")
    return "ctx" .. tostring(ctx)
end)

server:run()

