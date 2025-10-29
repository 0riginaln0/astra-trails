local r = {}

local inspect = require("inspect").inspect
unpack = unpack or table.unpack -- For Compatibility with all Lua versions


---Constructs a set from a list of entries, where each entry is mapped to key value pair: `[entry] = true`.
---@param entries table A list (table) of entries to be included in the set.
---@return table set new table representing the set
local function set(entries)
    local new_set = {}; for _, value in ipairs(entries) do new_set[value] = true end
    return new_set
end

local http_routes = set { "GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS", "TRACE", }
local static_routes = set { "STATIC_DIR", "STATIC_FILE", }

--- 
--- Usage:
--- 
---    Routes(server) {
---        { "GET",         "/path",   callback  },
---        { "POST",        "/path2",  callback2 },
---        { "STATIC_FILE", "/main",   "main.lua" },
---        { "STATIC_DIR",  "/public", "public" },
---    }
---
---@param server HTTPServer
---@return function
function r.Routes(server)
    local route_type_to_astra_function = {
        ["GET"] = server.get,
        ["POST"] = server.post,
        ["PUT"] = server.put,
        ["PATCH"] = server.patch,
        ["DELETE"] = server.delete,
        ["OPTIONS"] = server.options,
        ["TRACE"] = server.trace,
        ["STATIC_DIR"] = server.static_dir,
        ["STATIC_FILE"] = server.static_file,
    }

    local function validate_route_params(route, base_middleware)
        local route_type, path, callback_or_serve_path, config = route[1], route[2], route[3], route[4]

        assert(route_type_to_astra_function[route_type],
            "Unknown route type `" .. route_type .. "`: " .. inspect(route))
        assert(type(path) == "string",
            "Path must be a string, got `" .. type(path) .. "`: " .. inspect(route))
        assert((type(config) == "table") or (type(config) == "nil"),
            "Config must be a table, got `" .. type(config) .. "`: " .. inspect(route))
        if http_routes[route_type] then
            local callback = callback_or_serve_path
            assert(type(callback) == "function",
                "Callback must be a function, got `" .. type(callback) .. "`: " .. inspect(route))
            if base_middleware then
                callback_or_serve_path = base_middleware(callback)
            end
        elseif static_routes[route_type] then
            local serve_path = callback_or_serve_path
            assert(type(serve_path) == "string",
                "Serve path must be a string, got `" .. type(serve_path) .. "`: " .. inspect(route))
        end
        print(string.format("%11s %s", route_type, path))   -- printing result endpoints 
                                                            --[[
                                                                    GET /
                                                                   POST /
                                                                    GET /hi
                                                            STATIC_FILE /main
                                                             STATIC_DIR /public
                                                                    GET /api
                                                                    GET /api/v1/favlangs
                                                                    GET /api/v2/favlangs
                                                            ]]
        return route_type, path, callback_or_serve_path, config
    end

    return function(routes)
        local base_middleware = routes.base_middleware
        for _, route in ipairs(routes) do
            local route_type, path, callback_or_serve_path, config = validate_route_params(route, base_middleware)
            route_type_to_astra_function[route_type](server, path, callback_or_serve_path, config)
        end
    end
end

---@param path string
---@return function
function r.scope(path)
    return function(routes)
        local scoped_routes = {}

        for _, route in ipairs(routes) do
            route[2] = path .. route[2]
            if http_routes[route[1]] and routes.base_middleware then
                route[3] = routes.base_middleware(route[3])
            end
            table.insert(scoped_routes, route)
        end

        return unpack(scoped_routes)
    end
end

return r
