local RenderModule = require("modules.render")
local extra = require("modules.extra")

local Module = {
    currentMap = nil
}

function Module.load(mapName)
    local mapPath = "modules.data.maps." .. mapName
    local newMap = require(mapPath)

    if not newMap then return end
    if not newMap.waypoints then return end
    if not newMap.spritePath then return end

    RenderModule.clearAll()

    local screenWidth, screenHeight = love.graphics.getDimensions()
    RenderModule.new(newMap.spritePath, 0, screenWidth / 2, screenHeight / 2)

    Module.currentMap = newMap
end

return Module