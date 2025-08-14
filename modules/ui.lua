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

    CurrentSceneData = {},
    CurrentScene = "",

    currentlySelectedUnit = nil,
    rangeVisualizer = nil
}

local UnitPlacementData = Module.UnitPlacementData

function Module.loadScene(scene)
    local pathModule = "modules.data.ui-scenes." .. scene
    local path = "modules/data/ui-scenes/" .. scene .. ".lua"

    if not love.filesystem.getInfo(path) then return end

    local sceneData = require(pathModule)

    for _, element in pairs(Module.CurrentSceneData) do
        element:remove()
    end

    Module.CurrentSceneData = {}
    Module.CurrentScene = scene

    for index, elementProperties in pairs(sceneData) do
        Module.CurrentSceneData[index] = RenderModule.new(elementProperties)
    end
end

function Module.checkCanPlace()
    UnitPlacementData.canPlace = true

    if UnitPlacementData.placeholder.data.cost > CurrentGameData.cash then
        UnitPlacementData.canPlace = false
        return
    end

    local x, y = extra.getScaledMousePos()
    local mask = CurrentGameData.currentMapMask

    ---@diagnostic disable-next-line: undefined-field, need-check-nil
    if x < 0 or y < 0 or x >= mask:getWidth() or y >= mask:getHeight() then
        return false
    end

    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    local r, g, b = mask:getPixel(x, y)

    if not (r == 0 and g == 1 and b == 0) then
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

        if math.abs(x - ux) < (psw + usw) / 2 and math.abs(y - uy) < (psh + ush) / 2 then
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

    local scale = data.range / 500

    local elementProperties = {
            type = "sprite",
            spritePath = "assets/sprites/rangevisualizer.png",
            zindex = 1,
            x = x,
            y = y,
            alpha = .8,
            scaleX = scale,
            scaleY = scale
        }

    Module.rangeVisualizer = RenderModule.new(elementProperties)

    local elementProperties = {
        type = "sprite",
        spritePath = data.spritePath,
        zindex = 99,
        x = x,
        y = y,
        alpha = .8,
    }

    UnitPlacementData.placeholder = {
        element = RenderModule.new(elementProperties),
        data = data,
        type = unitType
    }
end

function Module.mousepressed(mouseButton)
    if Module.CurrentScene == "mainmenu" then
        if Module.CurrentSceneData.playButton:isClicked() then
            require("modules.gameplayLoop").startGame("normal", "grasslands")
        end
    elseif Module.CurrentScene == "resultscreen" then
        if Module.CurrentSceneData.backToMenuButton:isClicked() then
            Module.loadScene("mainmenu")
        end
    end

    if mouseButton == 1 and not UnitPlacementData.currentlyPlacing then
        local clicked = false

        for _, unit in pairs(UnitModule.getUnits()) do
            if unit.element:isClicked() then
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

                local elementProperties = {
                    type = "sprite",
                    spritePath = "assets/sprites/rangevisualizer.png",
                    zindex = 1,
                    x = unit.element.x,
                    y = unit.element.y,
                    alpha = .8,
                    scaleX = scale,
                    scaleY = scale
                }

                Module.rangeVisualizer = RenderModule.new(elementProperties)
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
    end
end

function Module.update(deltaTime)
    local time = os.clock()

    if CurrentGameData.gameStarted then
        Module.CurrentSceneData.baseHealth.text =  math.max(CurrentGameData.baseHealth, 0) .. "/" .. CurrentGameData.maxBaseHealth .. " BASE HP"

        if CurrentGameData.baseHealth <= 0 then
            Module.CurrentSceneData.baseHealth.color = {r=255, g=58, b=58}
        elseif CurrentGameData.baseHealth < CurrentGameData.maxBaseHealth then
            Module.CurrentSceneData.baseHealth.color = {r=255, g=150, b=50}
        else
            Module.CurrentSceneData.baseHealth.color = {r=107, g=255, b=0107}
        end

        Module.CurrentSceneData.cashCounter.text = "$" .. CurrentGameData.cash

        Module.CurrentSceneData.currentWave.text = "Wave: " .. CurrentGameData.currentWave

        local informationText

        if CurrentGameData.waveTimer then
            informationText = "Wave incoming! (" .. CurrentGameData.waveTimer .. "s)"
        else
            local count = 0

            for _, _ in pairs(EnemyModule.getEnemies()) do
                count = count + 1
            end

            informationText = "Slimes alive: " .. count
        end

        Module.CurrentSceneData.information.text = informationText
    elseif not CurrentGameData.gameStarted and Module.CurrentScene == "mainmenu" then
        Module.CurrentSceneData.logo.rot = math.sin(time) / 15

        local sin = math.sin(time) / 20

        local rot = (Module.CurrentSceneData.playButton:isClicked() and -sin or 0)
        Module.CurrentSceneData.playButtonLabel.rot = rot
        Module.CurrentSceneData.playButton.rot = rot
    elseif not CurrentGameData.gameStarted and Module.CurrentScene == "resultscreen" then
        local sin = math.sin(time) / 20

        local rot = (Module.CurrentSceneData.backToMenuButton:isClicked() and sin or 0)
        Module.CurrentSceneData.backToMenuButtonLabel.rot = rot
        Module.CurrentSceneData.backToMenuButton.rot = rot

        Module.CurrentSceneData.result.text = (CurrentGameData.gameWon and "You won!" or "You lost!")
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
            Module.rangeVisualizer.color = {r = 255, g = 255, b = 255}
        else
            Module.rangeVisualizer.color = {r = 255, g = 0, b = 0}
        end
    end
end

return Module