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
    rangeVisualizer = nil,

    transitionElement = nil,
    fade = {
        state = "none",
        speed = 2,
        callback = nil
    },

    splashScreenComplete = false,
    splashTime = 0
}

local UnitPlacementData = Module.UnitPlacementData

function Module.startFadeIn(callback)
    Module.fade.state = "in"
    Module.fade.callback = callback
    Module.transitionElement.alpha = 0
end

function Module.startFadeOut(callback)
    Module.fade.state = "out"
    Module.fade.callback = callback
    Module.transitionElement.alpha = 1
end

function Module.loadScene(scene, animate)
    local function actuallyLoadScene()
        local pathModule = "modules.data.ui-scenes." .. scene
        local path = "modules/data/ui-scenes/" .. scene .. ".lua"
        if not love.filesystem.getInfo(path) then return end

        for _, element in pairs(Module.CurrentSceneData) do
            element:remove()
        end

        Module.CurrentSceneData = {}
        Module.CurrentScene = scene

        local sceneData = require(pathModule)
        for index, elementProperties in pairs(sceneData) do
            Module.CurrentSceneData[index] = RenderModule.new(elementProperties)
        end
    end

    if Module.transitionElement then Module.transitionElement:remove() end

    if animate then
        Module.transitionElement = RenderModule.new({
            type = "sprite",
            spritePath = "assets/sprites/background.png",
            color = {r=0, g=0, b=0},
            scaleX = 1,
            scaleY = 1,
            zindex = 1000,
            alpha = 0,
            x = 400,
            y = 300
        })

        Module.startFadeIn(function()
            local delay = 0.25
            local elapsed = 0
            local timerUpdate

            timerUpdate = function(dt)
                elapsed = elapsed + dt
                if elapsed >= delay then
                    actuallyLoadScene()
                    Module.startFadeOut(nil)

                    Module.update = (function(original)
                        return function(dt)
                            original(dt)
                            timerUpdate = nil
                        end
                    end)(Module.update)
                end
            end

            local originalUpdate = Module.update
            Module.update = function(dt)
                originalUpdate(dt)
                if timerUpdate then timerUpdate(dt) end
            end
        end)
    else
        actuallyLoadScene()
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
        alpha = .7,
    }

    UnitPlacementData.placeholder = {
        element = RenderModule.new(elementProperties),
        data = data,
        type = unitType
    }
end

function Module.mousepressed(mouseButton)
    --%note buggy as hell, don't wanna deal with it rn
    -- if mouseButton == 1 and not Module.splashScreenComplete then
    --     Module.splashScreenComplete = true
    --     Module.loadScene("mainmenu", true)
    -- end

    if Module.CurrentScene == "mainmenu" and not CurrentGameData.gameStarted then
        if Module.CurrentSceneData.playButton:isClicked() then
            require("modules.gameplayLoop").startGame("normal", "grasslands")
        end
    elseif Module.CurrentScene == "resultscreen" and not CurrentGameData.gameStarted then
        if Module.CurrentSceneData.backToMenuButton:isClicked() then
            Module.loadScene("mainmenu", true)
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

    local hovering = false

    local enemies = {}
    for _, enemy in pairs(EnemyModule.getEnemies()) do
        if enemy and enemy.element then
            table.insert(enemies, enemy)
        end
    end

    table.sort(enemies, function(a, b)
        return a.element.tableIndex > b.element.tableIndex
    end)

    for _, enemy in ipairs(enemies) do
        if enemy.element:isClicked() and not hovering then
            hovering = true

            Module.CurrentSceneData.enemyHealthCounter.text = enemy.data.health .. "/" .. enemy.data.maxHealth .. " HP"
            Module.CurrentSceneData.enemyNameDisplay.text = enemy.data.displayName

            local x, y = extra.getScaledMousePos()

            Module.CurrentSceneData.enemyHealthCounter.x, Module.CurrentSceneData.enemyHealthCounter.y = x + 15, y - 15
            Module.CurrentSceneData.enemyNameDisplay.x, Module.CurrentSceneData.enemyNameDisplay.y = x + 15, y - 35
        end
    end

    if not hovering and Module.CurrentScene == "ingame" then
        Module.CurrentSceneData.enemyHealthCounter.text = ""
        Module.CurrentSceneData.enemyNameDisplay.text = ""
    end

    if not Module.splashScreenComplete then
        Module.splashTime = Module.splashTime + deltaTime
        if Module.splashTime >= 4 then
            Module.loadScene("mainmenu", true)
            Module.splashScreenComplete = true
        end
    end

    if Module.fade.state ~= "none" then
        if Module.fade.state == "in" then
            Module.transitionElement.alpha = math.min(Module.transitionElement.alpha + Module.fade.speed * deltaTime, 1)
            if Module.transitionElement.alpha >= 1 then
                Module.fade.state = "none"
                if Module.fade.callback then Module.fade.callback() end
            end
        elseif Module.fade.state == "out" then
            Module.transitionElement.alpha = math.max(Module.transitionElement.alpha - Module.fade.speed * deltaTime, 0)
            if Module.transitionElement.alpha <= 0 then
                Module.fade.state = "none"
                if Module.fade.callback then Module.fade.callback() end
            end
        end
    end

    if CurrentGameData.gameStarted and Module.CurrentScene == "ingame" then
        Module.CurrentSceneData.baseHealth.text =  math.max(CurrentGameData.baseHealth, 0) .. "/" .. CurrentGameData.maxBaseHealth .. " BASE HP"
        Module.CurrentSceneData.baseHealth.rot = math.sin(time) / 35

        Module.CurrentSceneData.baseHealth.color = {r=107, g=255, b=107}

        Module.CurrentSceneData.cashCounter.text = "$" .. CurrentGameData.cash
        Module.CurrentSceneData.cashCounter.rot = math.sin(time * 2.5) / 20

        Module.CurrentSceneData.currentWave.text = "Wave: " .. CurrentGameData.currentWave
        Module.CurrentSceneData.currentWave.rot = math.sin(time) / 35

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
        Module.CurrentSceneData.information.rot = math.sin(time) / 35
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
        Module.CurrentSceneData.result.rot = -sin
    elseif Module.CurrentScene == "splashscreen" then
        Module.CurrentSceneData.logo.rot = math.sin(time) / 15
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