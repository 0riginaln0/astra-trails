local set     = require("utils").set
local inspect = require("inspect").inspect

-- Variables to reduce the use of string literals in the Routes function call.
GET           = "GET"
POST          = "POST"
PUT           = "PUT"
PATCH         = "PATCH"
DELETE        = "DELETE"
OPTIONS       = "OPTIONS"
TRACE         = "TRACE"
STATIC_DIR    = "STATIC_DIR"
STATIC_FILE   = "STATIC_FILE"

function Routes(server)
    local routeTypeToAstraFunction = {
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
    local httpRoutes = set { "GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS", "TRACE", }
    local staticRoutes = set { "STATIC_DIR", "STATIC_FILE", }

    local function validateRouteParams(route, base_middleware)
        local route_type, path, callback_or_serve_path, config = route[1], route[2], route[3], route[4]

        assert(routeTypeToAstraFunction[route_type],
            "Unknown route type `" .. route_type .. "`: " .. inspect(route))
        assert(type(path) == "string",
            "Path must be a string, got `" .. type(path) .. "`: " .. inspect(route))
        assert((type(config) == "table") or (type(config) == "nil"),
            "Config must be a table, got `" .. type(config) .. "`: " .. inspect(route))
        if httpRoutes[route_type] then
            local callback = callback_or_serve_path
            assert(type(callback) == "function",
                "Callback must be a function, got `" .. type(callback) .. "`: " .. inspect(route))
            if base_middleware then
                callback_or_serve_path = base_middleware(callback)
            end
        elseif staticRoutes[route_type] then
            local serve_path = callback_or_serve_path
            assert(type(serve_path) == "string",
                "Serve path must be a string, got `" .. type(serve_path) .. "`: " .. inspect(route))
        end

        return route_type, path, callback_or_serve_path, config
    end

    return function(routes)
        local base_middleware = routes.base_middleware
        for _, route in ipairs(routes) do
            local route_type, path, callback_or_serve_path, config = validateRouteParams(route, base_middleware)
            routeTypeToAstraFunction[route_type](server, path, callback_or_serve_path, config)
        end
    end
end
