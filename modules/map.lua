local GameData = require("modules.data.gameData")
local RenderModule = require("modules.render")

local Module = {}

function Module.load(mapName)
    local mapPath = "modules.data.maps." .. mapName
    local newMap = require(mapPath)

    if not newMap then return end
    if not newMap.waypoints then return end
    if not newMap.spritePath then return end

    local elementProperties = {
            type = "sprite",
            spritePath = newMap.spritePath,
            zindex = 0,
            x = 400,
            y = 300
        }

    RenderModule.new(elementProperties)

    GameData.currentMapMask = love.image.newImageData(newMap.mask)
    GameData.currentMap = newMap
end

return Module