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

    UI = {
        baseHealthBar = nil,

        informationText = nil,
        baseHealthText = nil,
        cashText = nil,

        upgradeMenu = {
            currentlySelected = nil
        }
    },

    rangeVisualizer = nil,
}

local UnitPlacementData = Module.UnitPlacementData

function Module.checkCanPlace()
    UnitPlacementData.canPlace = true

    if UnitPlacementData.placeholder.data.cost > CurrentGameData.cash then
        UnitPlacementData.canPlace = false
        return
    end

    local px, py = UnitPlacementData.placeholder.element.x, UnitPlacementData.placeholder.element.y
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

function Module.mousepressed(button)
    if button == 1 and not UnitPlacementData.currentlyPlacing then
        for _, unit in pairs(UnitModule.getUnits()) do
            if unit:isClicked() then
                if Module.rangeVisualizer then
                    Module.rangeVisualizer:remove()
                    Module.rangeVisualizer = nil

                    if Module.UI.upgradeMenu.currentlySelected == unit then
                        Module.UI.upgradeMenu.currentlySelected = nil
                        return
                    end
                end

                Module.UI.upgradeMenu.currentlySelected = unit

                local currentData = unit.data.upgrades[unit.currentUpgrade]

                local scale = currentData.range / 500
                Module.rangeVisualizer = RenderModule.new("assets/sprites/rangevisualizer.png", 1, unit.element.x, unit.element.y, .8, nil, 0, scale, scale)
            end
        end
    end

    if UnitPlacementData.currentlyPlacing and CurrentGameData.gameStarted then
        if button == 1 then
            if not UnitPlacementData.canPlace then return end
            UnitModule.new(UnitPlacementData.placeholder.type, UnitPlacementData.placeholder.element.x, UnitPlacementData.placeholder.element.y)

        elseif button == 2 then
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

    if CurrentGameData.gameStarted then
        if not Module.UI.informationText then Module.UI.informationText = RenderModule.newText("", love.graphics.getFont(), 100, 400, 50, 1, {r=255,g=255,b=255}) end
        if not Module.UI.baseHealthText then Module.UI.baseHealthText = RenderModule.newText("", love.graphics.getFont(), 101, 400, 20, 1, {r=255,g=255,b=255}) end
        if not Module.UI.cashText then Module.UI.cashText = RenderModule.newText("", love.graphics.getFont(), 100, 100, 550, 1, {r=255,g=192,b=0}) end

        Module.UI.baseHealthText.text = CurrentGameData.baseHealth .. "/" .. CurrentGameData.maxBaseHealth
        Module.UI.cashText.text = "$" .. CurrentGameData.cash
    end

    if CurrentGameData.waveTimer and CurrentGameData.waveTimer > 0 then
        Module.UI.informationText.text = "Wave Incoming! (" .. math.ceil(CurrentGameData.waveTimer) .. "s)"
    elseif CurrentGameData.gameStarted then
        local count = 0

        for _, _ in pairs(EnemyModule.getEnemies()) do
            count = count + 1
        end

        Module.UI.informationText.text = "Slimes Alive: " .. count
    end

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