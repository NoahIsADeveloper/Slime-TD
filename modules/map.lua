local CurrentGameData = require("modules.currentGameData")
local RenderModule = require("modules.render")

local Module = {}

function Module.load(mapName)
    local mapPath = "modules.data.maps." .. mapName
    local newMap = require(mapPath)

    if not newMap then return end
    if not newMap.waypoints then return end
    if not newMap.spritePath then return end

    RenderModule.clearAll()

    local screenWidth, screenHeight = love.graphics.getDimensions()
    RenderModule.new(newMap.spritePath, 0, screenWidth / 2, screenHeight / 2)

    CurrentGameData.currentMapPathMask = love.image.newImageData(newMap.pathMask)
    CurrentGameData.currentMap = newMap
end

return Module