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

---@param server HTTPServer
function r.Routes(server)
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
        if not entry.block.base_middleware then
          process_block(entry.block, current_prefix .. entry._scope, current_middleware)
        else
          if current_middleware then
            process_block(entry.block, current_prefix .. entry._scope, chain({ current_middleware, entry.block.base_middleware }))
          else
            process_block(entry.block, current_prefix .. entry._scope, entry.block.base_middleware)
          end
        end
      else
        -- Route entry: expects {method, path, handler, <config>}
        local route_type, path, callback_or_serve_path, config = entry[1], entry[2], entry[3], entry[4]
        print(string.format("%11s %s", route_type, path))
        if http_routes[route_type] then
          local callback = callback_or_serve_path
          if current_middleware then
            add_route[route_type](server, current_prefix .. path, current_middleware(callback), config)
          else
            add_route[route_type](server, current_prefix .. path, callback, config)
          end
        elseif static_routes[route_type] then
          local serve_path = callback_or_serve_path
          add_route[route_type](server, current_prefix .. path, serve_path, config)
        end
      end
    end
  end

  -- The callable that receives the top‑level DSL block.
  local callable = setmetatable({}, {
    __call = function(_, block)
      -- Start with empty prefix and the base middleware (if any)
      process_block(block, "", block.base_middleware)

      if block.fallback then
        if block.base_middleware then
          server:fallback(block.base_middleware(block.fallback))
        else
          server:fallback(block.fallback)
        end
      end
    end
  })

  return callable
end

return r
