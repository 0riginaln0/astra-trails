# LugSQL

For example, you have `sql/queries.sql` file
```sql
-- :name get_user
-- :doc  Fetch a single user by id
--
-- Type of sql driver function to call the query with.
-- Can be one of `execute`, `query_all`, `query_one`
-- :query_one
--
-- named and typed parameter for the query. Supported types are `number`, `string`, `boolean`
SELECT * FROM users WHERE id = :id:number;
```

running
```lua
require("lugsql")("sql/queries.sql")
```

will generate `sql/queries.lua` file:
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
require("lugsql")("sql/queries.sql")
local driver = require("database")
local db = driver.new("sqlite", "db.sqlite")
local queries = require("sql.queries")(db)

queries.get_user({id=1})
```

---

Inspired by
- hugsql https://hugsql.org/
- pugsql https://pugsql.org/
- sqlc   https://sqlc.dev/