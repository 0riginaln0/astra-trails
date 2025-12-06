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

- watch for changes of `main.lua` and `some-handlers.lua` and `lib/some.lua`
```sh
./watch.sh main.lua some-handlers.lua lib/some.lua
```

- watch for all .lua files changes
```sh
./watch.sh "*.lua"
```

- watch for all .lua files changes and any files from the assets folder
```sh
./watch.sh "*.lua" assets/
```
