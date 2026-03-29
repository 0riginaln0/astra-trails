local server = require("http").server:new()


local routing = require("routing")
local Routes, scope = routing.Routes, routing.scope
local GET, POST = routing.GET, routing.POST


local middleware = require("middleware")
local chain = middleware.chain
local html = middleware.html
local logger = middleware.console_logger


local lustache = require("lustache")


local function read_all(file)
  local f = assert(io.open(file, "rb"), tostring(file).." is not found.")
  local content = f:read("*all")
  f:close()
  return content
end


local homepage = read_all("views/homepage.html")
local function homepage_handler() return homepage end


local tier_list_template = read_all("templates/tier-list.html")
local function handle_tier_list(req)
  local q = req:queries()
  local params = {
    name = q.name,
    s = q.s,
    a = q.a,
    b = q.b,
    c = q.c,
    d = q.d,
    e = q.e,
    f = q.f
  }
  return lustache:render(tier_list_template, params)
end


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

  { GET, "/",       html(homepage_handler) },

  scope {
    base_middleware = html,
    { GET, "/hello",     function() return "hello world" end },
    { GET, "/tier-list", handle_tier_list },
  },

  scope "/api" {
    { POST, "/guestbook", handle_post_guestbook },
    { GET,  "/guestbook", function() return guestbook end },
  },

  { GET, "/health", function() return { status = "UP" } end },

  fallback = chain { html } (function() return "Page not Found" end)
}

require("print-server-info")(server)
server:run()
