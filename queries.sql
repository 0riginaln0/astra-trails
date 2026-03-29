-- :name get_user
-- :doc Fetch a single user by id
-- :query-one
SELECT * FROM users WHERE id = :id:number

-- :name update_user_name
-- :execute
UPDATE users SET name = :name:string WHERE id = :id:number

-- :name list_active_users
-- :query-all
SELECT * FROM users WHERE active = 1

-- :name create_guestbook_table
-- :execute
CREATE TABLE guestbook (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(30),
  message VARCHAR(200),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- :name drop_guestbook_table
-- :execute
DROP TABLE IF EXISTS guestbook;

-- :name save_message
-- :execute
INSERT INTO guestbook
(name, message)
VALUES (:name:string, :message:string);

-- :name get_messages
-- :query_all
SELECT * FROM guestbook;

-- :name get_messages_by_name
-- :query_all
SELECT id, message, timestamp
FROM guestbook
WHERE name = :name:string
ORDER BY timestamp DESC;