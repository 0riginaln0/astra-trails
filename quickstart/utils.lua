local m = {}

---Constructs a set from a list of entries, where each entry is stored as both key and a value in the resulting table.
---@param entries table A list (table) of entries to be included in the set.
---@return table set new table representing the set
function m.set(entries)
    local new_set = {}; for _, value in ipairs(entries) do new_set[value] = value end
    return new_set
end

return m
