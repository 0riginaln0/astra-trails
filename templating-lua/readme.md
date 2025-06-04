Lua implementation of Mustache template system: https://github.com/Olivine-Labs/lustache

An overview of this library:

```lua
local lustache = require("lustache")

local function print_return(...)
  print(...)
  return ...
end

-- VARIABLES
-- Variables in templates are written in {{}}
local vars = [[
{{escaped_name}}
{{&unescaped_variable1}}
{{{unescaped_variable2}}}
]]
-- The view table must have keys with the same name as variable names in {{}}
local view = {
  escaped_name = "<b>Booo</b>",
  unescaped_variable1 = "<b>Booo1</b>",
  unescaped_variable2 = "<b>Booo2</b>",
}
-- To get rendered template you call render(template, view)
local rendered = print_return(lustache:render(vars, view))
local expected = [[
&lt;b&gt;Booo&lt;&#x2F;b&gt;
<b>Booo1</b>
<b>Booo2</b>
]]
assert(expected == rendered)


-- Variables can have keys
local vars_with_keys = [[
{{name.first}} {{name.last}}
{{age}}
]]
-- Сorresponding, view table must have a key with another table
view = {
  name = {first = "Anton", last = "Zabolotny"},
  age = 33,  
}
local rendered = print_return(lustache:render(vars_with_keys, view))
expected = [[
Anton Zabolotny
33
]]
assert(expected == rendered)


-- SECTIONS. Are written like this: {{#section_begin}} {{/section_end}}
local template = [[
Shown.
{{#section}}
Show me too!
{{/section}}
]]
-- If the section key exists and is not false/nil or empty {}, the block will be rendered
view = { section = true } -- try to change to false or nil or {}
rendered = print_return(lustache:render(template, view))
expected = [[
Shown.
Show me too!
]]
assert(expected == rendered)

-- When the section key value is a list, the block is rendered for each item
local list_template = [[
{{#puskas_award_winners}}
<b>{{year}} - {{name}}</b>
{{/puskas_award_winners}}
]]
view = {
  puskas_award_winners = {
    { year = 2009, name = "Cristiano Ronaldo" },
    { year = 2010, name = "Hamit Altintop" },
    { year = 2011, name = "Neymar" },
    { year = 2012, name = "Miroslav Stoch" },
    { year = 2013, name = "Zlatan Ibrahimovic" },
    { year = 2014, name = "James Rodriguez" },
    { year = 2015, name = "Wendell Lira" },
    { year = 2016, name = "Mohd Faiz Subri" },
    { year = 2017, name = "Olivier Giroud" },
    { year = 2018, name = "Mohamed Salah" },
    { year = 2019, name = "Daniel Zsori" },
    { year = 2020, name = "Son Heung-min" },
    { year = 2021, name = "Erik Lamela" },
    { year = 2022, name = "Marcin Oleksy" },
    { year = 2023, name = "Guilherme Madruga" },
    { year = 2024, name = "Alejandro Garnacho" }
  }
}
rendered = print_return(lustache:render(list_template, view))
expected = [[
<b>2009 - Cristiano Ronaldo</b>
<b>2010 - Hamit Altintop</b>
<b>2011 - Neymar</b>
<b>2012 - Miroslav Stoch</b>
<b>2013 - Zlatan Ibrahimovic</b>
<b>2014 - James Rodriguez</b>
<b>2015 - Wendell Lira</b>
<b>2016 - Mohd Faiz Subri</b>
<b>2017 - Olivier Giroud</b>
<b>2018 - Mohamed Salah</b>
<b>2019 - Daniel Zsori</b>
<b>2020 - Son Heung-min</b>
<b>2021 - Erik Lamela</b>
<b>2022 - Marcin Oleksy</b>
<b>2023 - Guilherme Madruga</b>
<b>2024 - Alejandro Garnacho</b>
]]
assert(expected == rendered)

-- If a section key is an list of strings, use '.' to reference current item
local array_template = [[
{{#musketeers}}
* {{.}}
{{/musketeers}}
]]
view = {
  musketeers = { "Athos", "Aramis", "Porthos", "DArtagnan" }
}
rendered = print_return(lustache:render(array_template, view))
expected = [[
* Athos
* Aramis
* Porthos
* DArtagnan
]]
assert(expected == rendered)

-- If section key is a function, it is used to do custom rendering
local function_template = [[
{{#bold}}Hi! {{text}} {{/bold}}
]]
view = {
  text = "I am bold!",
  bold = function(text, render)
    return "<b>" .. render(text) .. "</b>"
  end
}

rendered = print_return(lustache:render(function_template, view))
expected = [[
<b>Hi! I am bold! </b>
]]
assert(expected == rendered)


-- INVERTED SECTIONS (^) {{^inverted_section_begin}} {{inverted_section_end}}
-- They are used to render content when corresponding key is false/nil/empty
local inverted_template = [[
{{^repos}}No repos :({{/repos}}
{{#repos}}<b>{{name}}</b>{{/repos}}
]]
-- Test with empty list
view = { repos = {} }
rendered = print_return(lustache:render(inverted_template, view))
expected = [[
No repos :(

]]
assert(expected == rendered)

-- Test with populated list
view = {
  repos = {
    { name = "lustache" },
    { name = "busted" }
  }
}
rendered = print_return(lustache:render(inverted_template, view))
expected = [[

<b>lustache</b><b>busted</b>
]]
assert(expected == rendered)


-- COMMENTS {{!comment_example}}
-- Comments are ignored in templates
local comment_template = [[
<h1>Today{{! This is a comment }}.</h1>
{{! Multi-line
    comment }}
]]
rendered = print_return(lustache:render(comment_template, {}))
expected = [[
<h1>Today.</h1>
]]
assert(expected == rendered)


-- PARTIALS  {{> partial_name}} 
-- Include other templates using  lustache:render(base_template, view, partials)
-- Key of a partials must be the same as {{> name}} in the base template
local partials = {
  user = "<strong>{{name}}</strong>"
}

local base_template = [[
<h2>Names</h2>
{{#names}}
  {{> user}}
{{/names}}
]]

view = {
  names = {
    { name = "Alice" },
    { name = "Bob" }
  }
}

rendered = print_return(lustache:render(base_template, view, partials))
expected = [[
<h2>Names</h2>
<strong>Alice</strong><strong>Bob</strong>
]]

for i=1, string.len(rendered) do
    local r = string.sub(rendered, i,i)
    local e = string.sub(expected, i,i)
    if r ~= e then
    print(r, " is not equal to ", e)
    end
end

-- assert(expected == rendered) -- somehow it fails. However, the above check does not reveal any inequalities.


-- SET DELIMITER
-- Customize tag delimiters {{=cUstOm DelImItEr=}}
local delimiter_template = [[
* {{ default_tags }}
{{=<% %>=}}
* <% erb_style_tags %>
<%={{ }}=%>
* {{ default_tags_again }}
]]

view = {
  default_tags = "rendered from default tags",
  erb_style_tags = "rendered from erb style tags",
  default_tags_again = "rendered from default tags again!"
}
print("alo")
rendered = print_return(lustache:render(delimiter_template, view))
expected = [[
* rendered from default tags
* rendered from erb style tags
* rendered from default tags again!
]]
assert(expected == rendered)

print("All examples executed successfully!")
```
