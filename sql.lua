require("utils")
local driver = require("database")
local db = driver.new("sqlite", "db.sqlite")

---@param str string SQL template with named placeholders like :name
---@return fun(args: table): string, table
local function SQL(str)
  local order = {}
  local seen = {}
  for name in str:gmatch(":(%w+)") do
    if not seen[name] then
      seen[name] = true
      order[#order + 1] = name
    end
  end

  local pos = {}
  for i, name in ipairs(order) do pos[name] = i end

  local sql = str:gsub(":(%w+)", function(name) return "?" .. pos[name] end)

  return function(args)
    local params = {}
    for i, name in ipairs(order) do params[i] = args[name] end
    return sql, params
  end
end

local create_guestbook_table = SQL[[
CREATE TABLE guestbook (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(30),
  message VARCHAR(200),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
]]

---@type fun(args: table): string, table
local drop_guestbook_table = SQL[[
DROP TABLE IF EXISTS guestbook;
]]

---@type fun(args: {name: string, message: string}): string, table
local save_message = SQL[[
INSERT INTO guestbook
(name, message)
VALUES (:name, :message);
]]

---@type fun(args: table): string, table
local get_messages = SQL[[
SELECT * FROM guestbook;
]]

---@type fun(args: {name: string}): string, table
local get_messages_by_name = SQL[[
SELECT id, message, timestamp
FROM guestbook
WHERE name = :name
ORDER BY timestamp DESC;
]]

db:execute(create_guestbook_table{})
pprint(db:query_all(save_message{ name = "Name", message = "Message" }))
pprint(db:query_all(get_messages{}))
pprint(db:query_all(get_messages_by_name{name="Name"}))
