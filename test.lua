function a()
    return 1, 2, 3
end

function b()
    return 4, 5, 6
end

t = {
    table.pack(a()),
    b(),
    7,
    8
}

for key, value in pairs(t) do
    print(key, value)
end