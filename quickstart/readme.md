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


# Run project in a watch mode

- Watch only for `main.lua` changes (by default it watches only for that file)
```sh
./watch.sh
```

- watch for changes of `main.lua`, `some-handlers.lua` and `lib/some.lua`
```sh
./watch.sh main.lua some-handlers.lua lib/some.lua
```

- watch for all `.lua` files changes
```sh
./watch.sh "*.lua"
```

- watch for changes of all `.lua` files and any files from the `assets/` folder
```sh
./watch.sh "*.lua" assets/
```