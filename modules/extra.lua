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

function Module.lerp(a, b, t)
    return a + (b - a) * t
end

function Module.getScaledMousePos()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local scaleX = screenWidth / 800
    local scaleY = screenHeight / 600
    local scale = math.min(scaleX, scaleY)
    local offsetX = (screenWidth - 800 * scale) / 2
    local offsetY = (screenHeight - 600 * scale) / 2

    local mouseX, mouseY = love.mouse.getPosition()
    local x = (mouseX - offsetX) / scale
    local y = (mouseY - offsetY) / scale

    x, y = Module.clamp(x, 0, 800), Module.clamp(y, 0, 600)

    return x, y
end

function Module.clamp(x, min, max)
    return math.max(math.min(x, max), min)
end

function Module.sign(x)
    return x > 0 and 1 or (x < 0 and -1 or 0)
end

return Module
