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
    return db:query_one([[SELECT * FROM users WHERE id = ?1
  ]], parse_args(args, order))
  end

return M
end
```

which you can call like that:

```lua
local driver = require("database")
local db = driver.new("sqlite", "db.sqlite")
local queries = require("sql.queries")(db)

queries.get_user({id=1})
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

local user = queries.get_user({ id = 1 })
print("User 1:", user.name, "active:", user.active)

queries.update_user_name({ id = 2, name = "Robert" })

local active_users = queries.list_active_users()
for _, u in ipairs(active_users) do
  print("Active user:", u.name)
end

queries.save_message({ name = "Alice", message = "Hello, world!" })
queries.save_message({ name = "Bob",   message = "Hello, hello!" })

local alice_msgs = queries.get_messages_by_name({ name = "Alice" })
for _, msg in ipairs(alice_msgs) do
  print(string.format("[%s] %s", msg.timestamp, msg.message))
end

queries.drop_tables()
```

## Future enhancements

- [ ] ATM it supports only SQLite. Maybe add Postgres support? 