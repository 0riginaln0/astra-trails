So it is a Trails project template.

```
$ astra export
```

```
$ astra run main.lua
```

```
|   readme.md
│   main.lua
├───astra
│   └───lua
└───trails
    ├───other-useful-code
    └───templates
        └───lustache
```


Note that "Trails" files here are the same as in individual folders, but some of them have the following code prepended
```lua
-- It enables relative import from the current script directory.
package.path = package.path .. ";" .. debug.getinfo(1, "S").source:match("(.*[\\/])") .. "?.lua"
```


