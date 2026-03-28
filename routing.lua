local r = {}

require "utils"
unpack = unpack or table.unpack -- For Compatibility with all Lua versions
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

---Constructs a set from a list of entries, where each entry is mapped to key value pair: `[entry] = true`.
---@param entries table A list (table) of entries to be included in the set.
---@return table set new table representing the set
local function set(entries)
  local new_set = {}; for _, value in ipairs(entries) do new_set[value] = true end
  return new_set
end

local http_routes = set { "GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS", "TRACE", }
local static_routes = set { "STATIC_DIR", "STATIC_FILE", }

-- The `scope` function: takes a path prefix, returns a function that
-- captures a nested block and wraps it in a marker table.
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

  -- Recursive function that registers routes with proper prefix and middleware.
  local function process_block(block, current_prefix, current_middleware)
    -- `block` is the table from the DSL. Its unnamed entries (the array part)
    -- are either route tables {method, path, handler} or scope‑marker tables.
    for _, entry in ipairs(block) do
      if entry._scope then
        -- Nested scope: recursively process its inner block.
        if entry.block.base_middleware then
          process_block(entry.block, current_prefix .. entry._scope,
            chain({ current_middleware, entry.block.base_middleware }))
        else
          process_block(entry.block, current_prefix .. entry._scope, current_middleware)
        end
      else
        -- Route entry: expects {method, path, handler, <config>}
        local route_type, path, callback_or_serve_path, config = entry[1], entry[2], entry[3], entry[4]
        print(string.format("%11s %s", route_type, path))
        if http_routes[route_type] then
          local callback = callback_or_serve_path
          add_route[route_type](server, current_prefix .. path, current_middleware(callback), config)
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
      local base_middleware = block.base_middleware
      -- Start with empty prefix and the base middleware (if any)
      process_block(block, "", base_middleware)
    end
  })
  return callable
end

return r
