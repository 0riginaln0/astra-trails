local components = {}

local function register(name, component)
    components[name] = component
end

local function get(name)
    return components[name]
end

return { register = register, get = get }
