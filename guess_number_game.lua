-- AI generated, sorry sorry. I'm too exited to get subapps work. But it looks decent tho.

local routing = require("routing")
local Routes, scope = routing.Routes, routing.scope
local GET, POST = routing.GET, routing.POST

local middleware = require("middleware")
local chain = middleware.chain
local html = middleware.html

local escape_html = require("utils").escape_html

-- Helper function to render the guess number game page
local function render_guess_page(message, attempts, game_won, path)
  local secret_number = 42 -- hardcoded secret number
  local attempts_display = attempts or 0
  local message_html = message and ("<div class='message'>" .. escape_html(message) .. "</div>") or ""
  local game_content = ""

  if game_won then
    game_content = string.format([[
      <div class="win">
        <h2>🎉 You won! 🎉</h2>
        <p>You guessed the secret number %d in %d attempts.</p>
        <a href="%s" class="button">Play again</a>
      </div>
    ]], secret_number, attempts_display, path)
  else
    game_content = [[
      <form method="post" action="]]..path..[[">
        <input type="hidden" name="attempts" value="]]..tostring(attempts_display)..[[" />
        <label for="guess">Your guess (1-100): </label>
        <input type="number" id="guess" name="guess" required min="1" max="100" step="1" autofocus />
        <button type="submit">Submit Guess</button>
      </form>
      <p>Attempts so far: ]]..tostring(attempts_display)..[[</p>
    ]]
  end

  return [[
  <!DOCTYPE html>
  <html>
  <head>
    <title>Guess the Number Game</title>
    <style>
      body {
        font-family: system-ui, -apple-system, sans-serif;
        max-width: 550px;
        margin: 50px auto;
        padding: 20px;
        text-align: center;
        background: #f8f9fa;
      }
      .container {
        background: white;
        border-radius: 16px;
        padding: 30px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
      }
      h1 {
        color: #2c3e50;
        margin-top: 0;
      }
      .message {
        margin: 20px 0;
        padding: 12px;
        border-radius: 8px;
        background: #e9ecef;
        color: #495057;
        font-weight: 500;
      }
      input, button {
        padding: 10px 16px;
        margin: 8px;
        font-size: 16px;
        border-radius: 8px;
        border: 1px solid #ced4da;
      }
      input {
        width: 120px;
        text-align: center;
      }
      button {
        background: #007bff;
        color: white;
        border: none;
        cursor: pointer;
        transition: background 0.2s;
      }
      button:hover {
        background: #0056b3;
      }
      .win {
        background: #d4edda;
        padding: 20px;
        border-radius: 12px;
        margin: 15px 0;
      }
      .win h2 {
        color: #155724;
        margin-top: 0;
      }
      a.button {
        display: inline-block;
        margin-top: 15px;
        padding: 8px 20px;
        background: #28a745;
        color: white;
        text-decoration: none;
        border-radius: 8px;
        font-weight: 500;
      }
      a.button:hover {
        background: #218838;
      }
      hr {
        margin: 25px 0 15px;
        border: none;
        border-top: 1px solid #dee2e6;
      }
      .reset-link {
        color: #6c757d;
        text-decoration: none;
        font-size: 14px;
      }
      .reset-link:hover {
        text-decoration: underline;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <h1>🔢 Guess the Number</h1>
      <p>I'm thinking of a number between <strong>1</strong> and <strong>100</strong>.<br>Can you guess what it is?</p>
      ]] .. message_html .. [[
      ]] .. game_content .. [[
      <hr />
      <a href="]]..path..[[" class="reset-link">⟳ Reset game</a>
    </div>
  </body>
  </html>
  ]]
end

-- Guess the number game routes (hardcoded secret = 42)
local guess_number_game = Routes {
  middleware = chain { html },  -- ensures proper HTML content-type

  -- GET: display initial game state (no message, attempts=0)
  { GET, "/", function(rq, rp)
    return render_guess_page(nil, 0, false, rq:uri())
  end },

  -- POST: process the user's guess
  { POST, "/", function(rq, rp)
    local form = rq:form()
    local guess_str = form.guess
    local attempts_str = form.attempts
    local attempts = tonumber(attempts_str) or 0
    local secret = 42  -- hardcoded number

    -- Validate input
    if not guess_str or guess_str == "" then
      return render_guess_page("❌ Please enter a number.", attempts, false, rq:uri())
    end

    local guess_num = tonumber(guess_str)
    if not guess_num then
      return render_guess_page("❌ Invalid input. Please enter a numeric value.", attempts, false, rq:uri())
    end

    -- Increment attempt counter
    attempts = attempts + 1

    -- Compare guess with hardcoded secret
    if guess_num == secret then
      return render_guess_page(
        string.format("🎉 Correct! The number was %d. You got it in %d attempt(s). 🎉", secret, attempts),
        attempts,
        true,
        rq:uri()
      )
    elseif guess_num < secret then
      return render_guess_page(
        string.format("📉 Too low! Guess #%d - try a higher number.", attempts),
        attempts,
        false,
        rq:uri()
      )
    else
      return render_guess_page(
        string.format("📈 Too high! Guess #%d - try a lower number.", attempts),
        attempts,
        false,
        rq:uri()
      )
    end
  end }
}

return guess_number_game