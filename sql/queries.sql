-- :name create_tables
-- :execute
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  active INTEGER DEFAULT 1
);

CREATE TABLE IF NOT EXISTS guestbook (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  message TEXT NOT NULL,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- :name drop_tables
-- :execute
DROP TABLE IF EXISTS guestbook;
DROP TABLE IF EXISTS users;


-- :name insert_user
-- :execute
INSERT INTO users (name, active) VALUES (:name:string, :active:number);


-- :name get_user
-- :doc Fetch a single user by id
-- :query_one
SELECT * FROM users WHERE id = :id:number;


-- :name update_user_name
-- :execute
UPDATE users SET name = :name:string WHERE id = :id:number;


-- :name list_active_users
-- :query_all
SELECT * FROM users WHERE active = 1;


-- :name save_message
-- :execute
INSERT INTO guestbook (name, message)
VALUES (:name:string, :message:string);


-- :name get_messages_by_name
-- :query_all
SELECT id, message, timestamp
FROM guestbook
WHERE name = :name:string
ORDER BY timestamp DESC;


-- :name get_messages
-- :querry_all
SELECT message, name
FROM guestbook
ORDER BY timestamp DESC;
