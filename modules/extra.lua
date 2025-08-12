local Module = {}

function Module.deepCopy(orig)
    local orig_type = type(orig)
    local copy

    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Module.deepCopy(orig_key)] = Module.deepCopy(orig_value)
        end
        setmetatable(copy, Module.deepCopy(getmetatable(orig)))
    else
        copy = orig
    end

    return copy
end

function Module.sleep(ms)
    local elapsed = 0
    while elapsed < ms do
        local deltaTime = coroutine.yield()
        if not deltaTime then deltaTime = 0 end
        elapsed = elapsed + deltaTime * 1000
    end
end

function Module.lerp(a, b, t)
    return a + (b - a) * t
end

return Module
