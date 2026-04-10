local routing = require("routing")
local Routes = routing.Routes
local GET, POST = routing.GET, routing.POST

local middleware = require("middleware")
local html = middleware.html

local lustache = require("lustache")
local cache_dir = require("cache-dir")

local views = cache_dir("views", { hotreload = true })
local template = views["guess-number.html"]

local SECRET_NUMBER = 42

local function render_page(message, attempts, game_won, path)
  local view = {
    message = message,
    attempts = attempts or 0,
    game_won = game_won or false,
    path = path,
    secret_number = SECRET_NUMBER
  }
  return lustache:render(template, view)
end

local guess_number_game = Routes {
  middleware = html,

  -- GET: initial state
  { GET, "/", function(rq, rp)
    return render_page(nil, 0, false, rq:uri())
  end },

  -- POST: process guess
  { POST, "/", function(rq, rp)
    local form = rq:form()
    local guess_str = form.guess
    local attempts = tonumber(form.attempts) or 0

    -- Validate input
    if not guess_str or guess_str == "" then
      return render_page("❌ Please enter a number.", attempts, false, rq:uri())
    end

    local guess_num = tonumber(guess_str)
    if not guess_num then
      return render_page("❌ Invalid input. Please enter a numeric value.", attempts, false, rq:uri())
    end

    attempts = attempts + 1

    if guess_num == SECRET_NUMBER then
      local msg = string.format("🎉 Correct! The number was %d. You got it in %d attempt(s). 🎉",
                                SECRET_NUMBER, attempts)
      return render_page(msg, attempts, true, rq:uri())
    elseif guess_num < SECRET_NUMBER then
      local msg = string.format("📉 Too low! Guess #%d - try a higher number.", attempts)
      return render_page(msg, attempts, false, rq:uri())
    else
      local msg = string.format("📈 Too high! Guess #%d - try a lower number.", attempts)
      return render_page(msg, attempts, false, rq:uri())
    end
  end }
}

return guess_number_game
