package.path = table.concat({
                              "?.lua",
                              "./trails/?.lua",
                              "./vendor/?.lua",
                              "./vendor/?/init.lua",
                              "./vendor/?/?.lua",
                              package.path
                            }, ";")

local db = require("database").new("sqlite", "db.sqlite")
db:execute "PRAGMA journal_mode = WAL"
db:execute "PRAGMA synchronous  = NORMAL"
db:execute "PRAGMA foreign_keys = ON"
db:execute "PRAGMA busy_timeout = 5000"

Registry = {}
Registry.db = db
