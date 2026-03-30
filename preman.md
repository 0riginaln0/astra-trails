# Preman

It’s like Postman, but contained in a single HTML file that you can host on your web server. You can send as many requests as you want - until you’re exhausted and ready to retreat to your cave.

## Usage

```lua
Routes(server) {
  --
  -- Your routes
  --
  { STATIC_FILE, "/preman", "preman.html" },
}
```

## TBD

- [ ] HTTP Methods besides GET.

- [ ] Fields for request body inputs.

- [ ] Show output when request fails

- [ ] Parametrized defaults
