local CurrentGameData = require("modules.currentGameData")
local RenderModule = require("modules.render")
local EnemyModule = require("modules.enemy")
local UnitModule = require("modules.unit")
local extra = require("modules.extra")

local Module = {
    UnitPlacementData = {
        currentlyPlacing = false,
        canPlace = true,

        placeholder = nil
    },

    currentlySelectedUnit = nil,
    rangeVisualizer = nil
}

local UnitPlacementData = Module.UnitPlacementData

function Module.checkCanPlace()
    UnitPlacementData.canPlace = true

    if UnitPlacementData.placeholder.data.cost > CurrentGameData.cash then
        UnitPlacementData.canPlace = false
        return
    end

    local px, py = UnitPlacementData.placeholder.element.x, UnitPlacementData.placeholder.element.y
    local pathMask = CurrentGameData.currentMapPathMask

    ---@diagnostic disable-next-line: undefined-field, need-check-nil
    if px < 0 or py < 0 or px >= pathMask:getWidth() or py >= pathMask:getHeight() then
        return false
    end

    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    local r = pathMask:getPixel(px, py)

    if r == 1 then
        UnitPlacementData.canPlace = false
        return
    end

    local psx = UnitPlacementData.placeholder.element.scaleX or 1
    local psy = UnitPlacementData.placeholder.element.scaleY or 1
    local psw = UnitPlacementData.placeholder.element.sprite:getWidth() * psx
    local psh = UnitPlacementData.placeholder.element.sprite:getHeight() * psy

    for _, unit in pairs(UnitModule.getUnits()) do
        local ux, uy = unit.element.x, unit.element.y
        local usx = unit.element.scaleX or 1
        local usy = unit.element.scaleY or 1
        local usw = unit.element.sprite:getWidth() * usx
        local ush = unit.element.sprite:getHeight() * usy

        if math.abs(px - ux) < (psw + usw) / 2 and math.abs(py - uy) < (psh + ush) / 2 then
            UnitPlacementData.canPlace = false
            break
        end
    end
end

function Module.startPlacement(unitType)
    if UnitPlacementData.currentlyPlacing then return end

    local pathModule = "modules.data.units." .. unitType
    local path = "modules/data/units/" .. unitType .. ".lua"

    if not love.filesystem.getInfo(path) then return end
    local data = require(pathModule).upgrades[1]

    UnitPlacementData.currentlyPlacing = true

    local x, y = extra.getScaledMousePos()

    if Module.rangeVisualizer then Module.rangeVisualizer:remove() Module.rangeVisualizer = nil end

    love.mouse.setVisible(false)

    local scale = data.range / 500
    Module.rangeVisualizer = RenderModule.new("assets/sprites/rangevisualizer.png", 1, x, y, .8, nil, 0, scale, scale)

    UnitPlacementData.placeholder = {
        element = RenderModule.new(data.spritePath, 99, x, y, .8),
        data = data,
        type = unitType
    }
end

function Module.mousepressed(mouseButton)
    if mouseButton == 1 and not UnitPlacementData.currentlyPlacing then
        local clicked = false

        for _, unit in pairs(UnitModule.getUnits()) do
            if unit:isClicked() then
                clicked = true

                if Module.rangeVisualizer then
                    Module.rangeVisualizer:remove()
                    Module.rangeVisualizer = nil

                    if Module.currentlySelectedUnit == unit then
                        Module.currentlySelectedUnit = nil
                        return
                    end
                end

                Module.currentlySelectedUnit = unit

                local currentData = unit.data.upgrades[unit.currentUpgrade]

                local scale = currentData.range / 500
                Module.rangeVisualizer = RenderModule.new("assets/sprites/rangevisualizer.png", 1, unit.element.x, unit.element.y, .8, nil, 0, scale, scale)
            end
        end

        if Module.currentlySelectedUnit and not clicked then
            if Module.rangeVisualizer then Module.rangeVisualizer:remove() end
            Module.rangeVisualizer = nil
            Module.currentlySelectedUnit = nil
        end
    end

    if UnitPlacementData.currentlyPlacing and CurrentGameData.gameStarted then
        if mouseButton == 1 then
            if not UnitPlacementData.canPlace then return end
            UnitModule.new(UnitPlacementData.placeholder.type, UnitPlacementData.placeholder.element.x, UnitPlacementData.placeholder.element.y)

        elseif mouseButton == 2 then
        else
            return
        end

        UnitPlacementData.currentlyPlacing = false

        Module.rangeVisualizer:remove()
        Module.rangeVisualizer = nil
        UnitPlacementData.placeholder.element:remove()

        love.mouse.setVisible(true)
    end
end

function Module.update(deltaTime)
    local time = os.clock()

    if Module.rangeVisualizer then
        Module.rangeVisualizer.rot = Module.rangeVisualizer.rot + (0.5 * deltaTime)
    end

    if UnitPlacementData.currentlyPlacing then
        Module.checkCanPlace()

        UnitPlacementData.placeholder.element.x, UnitPlacementData.placeholder.element.y = extra.getScaledMousePos()
        Module.rangeVisualizer.x, Module.rangeVisualizer.y = extra.getScaledMousePos()

        UnitPlacementData.placeholder.element.rot = math.sin(time * 4) / 5

        if UnitPlacementData.canPlace then
            UnitPlacementData.placeholder.element.color = {r = 255, g = 255, b = 255}
        else
            UnitPlacementData.placeholder.element.color = {r = 255, g = 0, b = 0}
        end
    end
end

return Module