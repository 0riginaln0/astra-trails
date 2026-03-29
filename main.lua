local server = require("http").server:new()
local sc = require("http").status_codes


local routing = require("routing")
local Routes, scope = routing.Routes, routing.scope
local GET, POST = routing.GET, routing.POST


local middleware = require("middleware")
local chain = middleware.chain
local html = middleware.html
local logger = middleware.console_logger
local ctx = middleware.context


local lustache = require("lustache")


require("lugsql")("sql/queries.sql", "sqlite")

local driver = require("database")
local db = driver.new("sqlite", "db.sqlite")

local queries = require("sql.queries")(db)
queries.drop_tables()
queries.create_tables()


local function read_all(file)
  local f = assert(io.open(file, "rb"), tostring(file).." is not found.")
  local content = f:read("*all")
  f:close()
  return content
end


local homepage_html = read_all("views/homepage.html")
local function homepage() return homepage_html end


local tier_list_template = read_all("templates/tier-list.html")
local function tier_list(req)
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
local function post_api_guestbook(rq, rp)
  local b = rq:body():json()

  if b.message == nil or b.message == "" then
    rp:set_status_code(sc.BAD_REQUEST)
    return { error = "Message can't be empty" }
  end
  if type(b.message) ~= "string" then
    rp:set_status_code(sc.BAD_REQUEST)
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
  local ok, result = queries.save_message(record)
  if not ok then
    rp:set_status_code(sc.BAD_REQUEST)
    return { error = result }
  end
  return { status = "success" }
end


local function get_api_guestbook(rq, rp)
  local ok, result = queries.get_messages()
  if not ok then 
    rp:set_status_code(sc.BAD_REQUEST)
    return { error = result }
  end
  return result
end

local guestbook_html = read_all("views/guestbook.html")

local function guestbook_page(req)
  local ok, messages = queries.get_messages()
  if not ok then
    return "<h1>Error loading guestbook</h1><p>" .. tostring(messages) .. "</p>"
  end
  local view = {
    messages = messages,   -- list of { name, message }
    no_messages = #messages == 0
  }
  return lustache:render(guestbook_html, view)
end

---@param rq HTTPServerRequest
---@param rp HTTPServerResponse
local function post_guestbook_form(rq, rp)
  local form = rq:form()

  local name = form.name
  if name == nil or name == "" then
    name = "Anonymous"
  end

  local message = form.message
  if message == nil or message == "" then
    rp:set_status_code(sc.BAD_REQUEST)
    return "<h1>Error</h1><p>Message cannot be empty.</p><a href='/guestbook'>Go back</a>"
  end

  local record = { name = name, message = message }

  local ok, err = queries.save_message(record)
  if not ok then
    rp:set_status_code(sc.BAD_REQUEST)
    return "<h1>Error</h1><p>" .. tostring(err) .. "</p><a href='/guestbook'>Go back</a>"
  end

  rp:set_status_code(sc.SEE_OTHER)
  rp:set_header("Location", "/guestbook")
  return ""
end

Routes(server) {
  base_middleware = chain {ctx, logger},

  { GET, "/",       html(homepage) },

  scope {
    base_middleware = html,
    { GET, "/hello",     function() return "hello world" end },
    { GET, "/tier-list", tier_list },
  },


  { GET, "/guestbook", html(guestbook_page) },
  { POST, "/guestbook", post_guestbook_form },

  scope "/api" {
    { POST, "/guestbook", post_api_guestbook },
    { GET,  "/guestbook", get_api_guestbook },
  },

  { GET, "/health", function() return { status = "UP" } end },

  fallback = chain { html } (function() return "Page not Found" end)
}

require("print-server-info")(server)
server:run()
