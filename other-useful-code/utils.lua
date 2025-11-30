local utils = {}

---Constructs a set from a list of entries, where each entry is stored as both key and a value in the resulting table.
---@param entries table A list (table) of entries to be included in the set.
---@return table set new table representing the set
function utils.set(entries)
    local new_set = {}; for _, value in ipairs(entries) do new_set[value] = value end
    return new_set
end

local function escape_pattern(text)
    -- Escape all special pattern-matching characters
    return string.gsub(text, "([%^%$%(%)%%%.%[%]*%+%-%?])", "%%%1")
end

-- Monkey patching string table
function string.contains(str, str_to_find)
    -- Escape the pattern and then search for it in the string
    local escapedPattern = escape_pattern(str_to_find)
    return string.find(str, escapedPattern) ~= nil
end

return utils
