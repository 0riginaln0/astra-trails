local fs = require("fs")


--- Caches files in a directory and optionally hot-reloads them when modified
---@param dir_path string
---@param opts {hotreload: boolean}
---@return table cache table for accessing file contents.
local function cache_dir(dir_path, opts)
  local hotreload = opts.hotreload
  local cache = {}
  local file_metadata = {}

  local function read_and_cache(file_path)
    local content = fs.read_file(file_path)
    file_metadata[file_path] = fs.get_metadata(file_path):last_modified()
    cache[file_path] = content
    return content
  end

  local proxy = {}
  setmetatable(proxy, {
    __index = function(_, file_name)
      local file_path = dir_path..fs.get_separator()..file_name
      if not fs.exists(file_path) then error("File not found: "..file_path) end

      if not cache[file_path] or
          (hotreload and
            fs.get_metadata(file_path):last_modified() ~= file_metadata[file_path]) then
        return read_and_cache(file_path)
      end

      return cache[file_path]
    end
  })

  return proxy
end

return cache_dir
