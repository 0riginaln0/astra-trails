local driver = require("database")
local db = driver.new("sqlite", "db")
local queries = require("sql")(db)
queries.get_user {id=3}