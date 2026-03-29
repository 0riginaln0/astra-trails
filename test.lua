require("lugsql")("sql/queries.sql")

local driver = require("database")

local db = driver.new("sqlite", "db.sqlite")

local queries = require("sql.queries")(db)


queries.get_user({id=1})
