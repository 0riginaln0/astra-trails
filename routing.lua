local r = {}

local utils = require "utils"
local set = utils.set
local chain = require("middleware").chain

r.GET = "GET"
r.POST = "POST"
r.PUT = "PUT"
r.PATCH = "PATCH"
r.DELETE = "DELETE"
r.OPTIONS = "OPTIONS"
r.TRACE = "TRACE"
r.STATIC_DIR = "STATIC_DIR"
r.STATIC_FILE = "STATIC_FILE"

local http_routes = set { "GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS", "TRACE", }
local static_routes = set { "STATIC_DIR", "STATIC_FILE", }

function r.scope(path_or_block)
  if type(path_or_block) == "string" then
    return function(block)
      local path = path_or_block
      return { _scope = path, block = block }
    end
  end

  if type(path_or_block) == "table" then
    local block = path_or_block
    return { _scope = "", block = block }
  end
end

function r.Routes(block)
  local routes = r.scope(block)
  local mt = {
    ---@param server HTTPServer
    __call = function (self, server)
      local add_route = {
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

      local function process_block(block, current_prefix, current_middleware)
        for _, entry in ipairs(block) do
          if entry._scope then
            -- Nested scope: recursively process its inner block.
            if not entry.block.middleware then
              process_block(entry.block, current_prefix..entry._scope, current_middleware)
            else
              if current_middleware then
                process_block(entry.block, current_prefix..entry._scope, chain({ current_middleware, entry.block.middleware }))
              else
                process_block(entry.block, current_prefix..entry._scope, entry.block.middleware)
              end
            end
          else
            -- Route entry: expects {method, path, handler, <config>}
            local route_type, path, callback_or_serve_path, config = entry[1], entry[2], entry[3], entry[4]
            local route_path = current_prefix..path
            -- Trim the trailing '/' from the path if it has one or more segments
            if route_path ~= "/" and string.sub(path, -1) == "/" then
              route_path = string.sub(route_path, 1, -2)
            end
            print(string.format("%11s %s", route_type, route_path))
            if http_routes[route_type] then
              local callback = callback_or_serve_path
              if current_middleware then
                add_route[route_type](server, route_path, current_middleware(callback), config)
              else
                add_route[route_type](server, route_path, callback, config)
              end
            elseif static_routes[route_type] then
              local serve_path = callback_or_serve_path
              add_route[route_type](server, route_path, serve_path, config)
            end
          end
        end
      end

      process_block(self.block, "", self.block.middleware)

      if self.block.fallback then
        if self.block.middleware then
          server:fallback(self.block.middleware(self.block.fallback))
        else
          server:fallback(self.block.fallback)
        end
      end
    end
  }
  assert(type(routes) == "table")
  setmetatable(routes, mt)
  return routes
end

return r
