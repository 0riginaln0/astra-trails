local r = {}

function r.yield()
    spawn_task(function() end):await()
end

local clock = os.clock
-- Do nothing for N seconds
function r.wait(n)
    local t0 = clock()
    while clock() - t0 <= n do
        r.yield()
    end
end

return r