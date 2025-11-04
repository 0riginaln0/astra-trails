local function yield()
    spawn_task(function() end):await()
end

return yield