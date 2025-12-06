local fs = require("fs")
local wait = require("runtime").wait
local http = require("http")

-- Init hot reloadable files list
local hot_reloadable_files = {
    { path = "app.lua", last_modified = nil }
}
for _, hot_reloabled_file in ipairs(hot_reloadable_files) do
    hot_reloabled_file.last_modified = fs.get_metadata(hot_reloabled_file.path):last_modified()
end

-- Load the app first time
local app, err_load = loadfile("app.lua"); if not app then error("Something gone wrong: " .. err_load) end
server = http.server:new()
app()
local running_app_task = spawn_task(function() server:run() end)

local do_reload = false
local check_files_for_modification_ms = 1000

Times_Reloaded = 0
spawn_interval(function()
    for _, hot_reloabled_file in ipairs(hot_reloadable_files) do
        local last_modified = fs.get_metadata(hot_reloabled_file.path):last_modified()
        if hot_reloabled_file.last_modified ~= last_modified then
            hot_reloabled_file.last_modified = last_modified;
            do_reload = true
        end
    end

    if do_reload then
        do_reload = false
        app, err_load = loadfile("app.lua");
        if not app then
            print("Error loading file: " .. err_load)
            print("Hot reload rejected")
            return
        end

        -- The order matters. Firstly abort the task
        running_app_task:abort()
        -- Then shutdown the server
        server:shutdown()
        wait(1) -- Wait a sec for a server to free the address

        server = http.server:new()
        app()
        running_app_task = spawn_task(function() server:run() end)
        print("Reloaded")
        Times_Reloaded = Times_Reloaded + 1
    end
end, check_files_for_modification_ms):await()
