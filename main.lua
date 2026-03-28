local server = require("http").server:new()

local Routes = require("routing").Routes
local scope = require("routing").scope
local GET = require("routing").GET
local POST = require("routing").POST

local logger = require("middleware").console_logger

local guestbook = {
  { name = "Alice", message = "Hello, world!" },
  { name = "Bob",   message = "Nice to be here!" }
}

---@param rq HTTPServerRequest
---@param rp HTTPServerResponse
local function handle_post_guestbook(rq, rp)
  local b = rq:body():json()

  if b.message == nil or b.message == "" then
    rp:set_status_code(400)
    return { error = "Message can't be empty" }
  end
  if type(b.message) ~= "string" then
    rp:set_status_code(400)
    return { error = "Message must be a string" }
  end

  if b.name == nil then
    b.name = "Anonymous"
  elseif type(b.name) ~= "string" then
    b.name = tostring(b.name)
  end

  local record = {
    name = b.name,
    message = b.message,
  }
  table.insert(guestbook, record)

  return { status = "success" }
end

Routes(server) {
  base_middleware = logger,
  { GET, "/", function() return "hello world" end },
  scope "/api" {
    { GET,  "/guestbook", function() return guestbook end },
    { POST, "/guestbook", handle_post_guestbook },
  }
}

require("print-server-info")(server)
server:run()
