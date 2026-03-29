# LugSQL

LugSQL turns annotated SQL queries into Lua functions with named & typed parameters.

Inspired by
- hugsql https://hugsql.org/
- pugsql https://pugsql.org/
- sqlc   https://sqlc.dev/

## Overview

For example, you have `sql/queries.sql` file
```sql
-- :name get_user
-- :doc  Fetch a single user by id
--
-- Type of sql driver function to call the query with.
-- Can be one of `execute`, `query_all`, `query_one`
-- :query_one
--
-- Parameters must be named and typed. Supported types are `number`, `string`
SELECT * FROM users WHERE id = :id:number;
```

running
```lua
require("lugsql")("sql/queries.sql")
```

will generate an `sql/queries.lua` file:
```lua
return function(db)
  local M = {}
  
  --- Fetch a single user by id
  ---@param args { id: number }
  function M.get_user(args)
    local order = { 'id' }
    local ok, result = pcall(db.query_one, db, [[SELECT * FROM users WHERE id = ?1;
]], parse_args(args, order))
    return ok, result
  end
  
  return M
end
```

which you can call like that:

```lua
local driver = require("database")
local db = driver.new("sqlite", "db.sqlite")
local queries = require("sql.queries")(db)

local ok, result = queries.get_user({id=1})
```

## Full example:

`astra run test.lua`

```lua
-- test.lua
require("lugsql")("sql/queries.sql")

local driver = require("database")
local db = driver.new("sqlite", "db.sqlite")

local queries = require("sql.queries")(db)

queries.create_tables()

queries.insert_user({ name = "Alice", active = 1 })
queries.insert_user({ name = "Bob",   active = 0 })

local _ok, user = queries.get_user({ id = 1 })
print("User 1:", user.name, "active:", user.active) -- User 1: Alice   active: 1

local ok, result = queries.get_user({id=44})
if not ok then
    print(result) --[[
    runtime error: Error executing the query: RowNotFound
    stack traceback:
        [C]: in local 'poll'
        [string "?"]:28: in main chunk
        [C]: in global 'pcall'
        [string "sql/queries.lua"]:53: in field 'get_user'
        [string "test.lua"]:17: in main chunk
    ]]
end

queries.update_user_name({ id = 1, name = "Robert" })

local _ok, active_users = queries.list_active_users()

for _, u in ipairs(active_users) do
  print("Active user:", u.name) -- Active user:    Robert
end

queries.save_message({ name = "Alice", message = "Hello, world!" })
queries.save_message({ name = "Bob",   message = "Hello, hello!" })

local ok, alice_msgs = queries.get_messages_by_name({ name = "Alice" })
for _, msg in ipairs(alice_msgs) do
  print(string.format("[%s] %s", msg.timestamp, msg.message)) -- [2026-03-29 10:06:34] Hello, world!
end

queries.drop_tables()
```

## Future enhancements

- [ ] ATM it supports only SQLite. Maybe add Postgres support? 
