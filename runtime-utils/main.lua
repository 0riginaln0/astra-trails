local http = require "http"
local server = http.server:new()
local yield = require "runtime".yield
local wait = require "runtime".wait
local clock = os.clock

local homepage = 0
server:get("/", function(_req, _res)
    print("homepage start")
    homepage = homepage + 1
    print("homepage finish")
    return "homepage" .. tostring(homepage)
end)

local lmao = 0
server:get("/lmao", function ()
    print("lmao start lmaoing")

    local t0 = clock()
    -- Do nothing for 10 seconds
    while clock() - t0 <= 10 do
        -- We want our server to not be blocked by long-running code sections.
        -- So we call yield() to signal the runtime that it can handle other requests
        yield()
        -- Try to comment out the above line and check if `/` requests are gonna be handled
        -- during "lmaoing"
    end

    print("lmao finished lmaoing")
    lmao = lmao + 1
    return ":) " .. lmao
end)

server:run()

