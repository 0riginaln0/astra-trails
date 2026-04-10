local paths = {
  "?.lua",
  "./trails/?.lua",
  "./vendor/?.lua",
  "./vendor/?/init.lua",
  "./vendor/?/?.lua",
}

package.path = table.concat(paths, ";")..";"..package.path
