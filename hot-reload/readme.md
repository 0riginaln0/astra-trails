Ok. Maybe it's a bit misleading, because it restarts the web server entirely, but I don't care.

> (I care) The real hot code reloading could be achieved via `invalidate_cache` `server:shutdown` and a couple of other Astra functions, but at the end of a day the app state should be kept in some single module which is not gonna be reloaded. And at the end of another day Astra web apps are more about stateless web apps sooo... the provided shell script is good enough.

Usage:

> [!NOTE]
> Dear Windows users, run this script from Git Bash

```sh
./watch.sh [files_to_watch...]
```

Examples:

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
