local _dbg = require("vendor.debugger")


require "setup"


local server = require("http").server:new()
local sc = require("http").status_codes
local validation = require("validation")
local serde = require("serde")

local routing = require("trails.routing")
local Routes, scope = routing.Routes, routing.scope
local GET, POST, STATIC_FILE, STATIC_DIR = routing.GET, routing.POST, routing.STATIC_FILE, routing.STATIC_DIR


local middleware = require("trails.middleware")
local chain = middleware.chain
local html = middleware.html
local logger = middleware.console_logger
local ctx = middleware.context


local lustache = require("vendor.lustache")
local escape_html = require("trails.utils").escape_html


require("trails.lugsql")("sql/queries.sql", "sqlite")

local queries = require("sql.queries")(Registry.db)
-- queries.drop_tables()
queries.create_tables()


local views = require("trails.cache-dir")("views", {hotreload = true})


local function homepage() return views["homepage.html"] end


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
  return lustache:render(views["tier-list.html"], params)
end

local likes = 0

local function hype_handler()
  return lustache:render(views['layout.html'], {
    title = "Hypermedia",
    body = lustache:render(views['hype.html'], {likes = likes})
  })
end

local function hype_like()
  likes = likes + 1
  return tostring(likes)
end


---@param rq HTTPServerRequest
---@param rp HTTPServerResponse
local function post_api_guestbook(rq, rp)
  local b = rq:body():json()

  local ok, err = validation.validate_table(b, {
    message = "string",
    name = { "string", required = false },
  })
  if not ok then
    rp:set_status_code(sc.BAD_REQUEST)
    return { error = err }
  end

  if b.name == nil then b.name = "Anonymous" end

  local ok, result = queries.save_message { name = b.name, message = b.message, }
  if not ok then
    rp:set_status_code(sc.BAD_REQUEST)
    return { error = result }
  end

  return { status = "success" }
end


---@param rq HTTPServerRequest
---@param rp HTTPServerResponse
local function get_api_guestbook(rq, rp)
  local ok, result = queries.get_messages()
  if not ok then
    rp:set_status_code(sc.BAD_REQUEST)
    return { error = result }
  end
  rp:set_header('content-type', 'application/json')
  return serde.json.encode(result)
end


local function guestbook_page(req)
  local ok, messages = queries.get_messages()
  if not ok then
    return "<h1>Error loading guestbook</h1><p>" .. escape_html(messages) .. "</p>"
  end
  local view = {
    messages = messages, -- list of { name = "str", message = "str"}
    no_messages = #messages == 0
  }
  return lustache:render(views["guestbook.html"], view)
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

  local ok, err = queries.save_message({ name = name, message = message })
  if not ok then
    rp:set_status_code(sc.BAD_REQUEST)
    return "<h1>Error</h1><p>" .. escape_html(err) .. "</p><a href='/guestbook'>Go back</a>"
  end

  rp:set_status_code(sc.SEE_OTHER)
  rp:set_header("Location", "/guestbook")
  return ""
end

local today_app = Routes {
  { GET, "/today", function() return "Today is "..os.date() end}
}

local app = Routes {
  middleware = chain { ctx, logger },

  { GET, "/", html(homepage) },
  { GET, "/hello", function() return "hello world" end },

  scope {
    middleware = html,
    { GET,  "/tier-list", tier_list },
    { GET,  "/hype",      hype_handler },
    { POST, "/hype/like", hype_like }
  },

  { GET,  "/guestbook", html(guestbook_page) },
  { POST, "/guestbook", post_guestbook_form },

  scope "/api" {
    { GET,  "/guestbook", get_api_guestbook },
    { POST, "/guestbook", post_api_guestbook },
  },

  { GET, "/health", function() return { status = "UP" } end },

  { STATIC_FILE, "/preman", "vendor/preman.html" },
  { STATIC_DIR,  "/static", "static" },

  today_app,

  scope "/games" {
    scope "/guess_number" {
      require("guess_number_game")
    }
  },

  fallback = chain { html } (function() return "Page not Found" end)
}

app(server)

require("print-server-info")(server)
server:run()
