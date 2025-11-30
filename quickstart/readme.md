So it is a Trails project folder template.

It's recommended to run `astra export` in the root folder in order to enable auto-complete.
```
│   .luarc.json
│   main.lua
├───astra
│   └───lua
└───trails
    ├───other-useful-code
    └───templates
        └───lustache
```

Make sure you have the correct Lua version in `.luarc.json`. It could be
- `"runtime.version": "Lua 5.4"`
- `"runtime.version": "LuaJIT"`



Note that all "Trails" files here are the same as in individual folders, but some of them have the following code prepended
```lua
-- It enables relative import from the current script directory.
package.path = package.path .. ";" .. debug.getinfo(1, "S").source:match("(.*[\\/])") .. "?.lua"
```
