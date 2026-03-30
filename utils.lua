local utils = {}

---Constructs a set from a list of entries.
---@param entries table A list (table) of entries to be included in the set.
---@return table set new table representing the set
function utils.set(entries)
  local new_set = {}; for _, value in ipairs(entries) do new_set[value] = true end
  return new_set
end

function table:to_string(t)
  local function v_to_string(v)
    local str
    if type(v) == "string" then
      str = "'"..v.."'"
    elseif type(v) == "table" then
      str = table:to_string(v)
    else
      str = tostring(v)
    end
    return str
  end

  local num_keys, hash_keys = {}, {}
  for k in pairs(t) do
    if type(k) == "number" then
      num_keys[#num_keys + 1] = k
    else
      hash_keys[#hash_keys + 1] = k
    end
  end
  table.sort(num_keys)
  table.sort(hash_keys, function(a, b) return tostring(a) < tostring(b) end)

  local num_part = {}
  for i = 1, #num_keys do num_part[i] = v_to_string(t[num_keys[i]]) end

  local hash_part = {}
  for i = 1, #hash_keys do
    local k = hash_keys[i]
    hash_part[i] = tostring(k).." = "..v_to_string(t[k])
  end

  local num_str = table.concat(num_part, ", ")
  local hash_str = table.concat(hash_part, ", ")

  if num_str ~= "" and hash_str ~= "" then
    return "{ "..num_str.." | "..hash_str.." }"
  else
    return "{ "..num_str..hash_str.." }"
  end
end

function pp(...args)
  local n = #args
  for i, v in ipairs(args) do
    io.write(type(v) == "table" and table:to_string(v) or tostring(v))
    if i ~= n then io.write("\t") end
  end
  io.write("\n")
end

local html_escape_characters = {
  ["&"] = "&amp;",
  ["<"] = "&lt;",
  [">"] = "&gt;",
  ['"'] = "&quot;",
  ["'"] = "&#39;",
  ["/"] = "&#x2F;"
}

function utils.escape_html(str)
  return string.gsub(str, '[&<>"\'/]', function(s) return html_escape_characters[s] end)
end

return utils
