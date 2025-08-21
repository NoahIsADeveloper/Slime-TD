---@diagnostic disable: inject-field, undefined-field

local GameplayLoopModule = require("modules.gameplayLoop")
local GameData = require("modules.data.gameData")
local SaveFileModule = require("modules.savefile")
local RenderModule = require("modules.render")
local SoundModule = require("modules.sound")
local EnemyModule = require("modules.enemy")
local UnitModule = require("modules.unit")
local UIModule = require("modules.ui")
local extra = require("modules.extra")

function love.load()
    local imageData = love.image.newImageData("assets/sprites/cursor.png")
    local cursor = love.mouse.newCursor(imageData, 5, 5)
    love.mouse.setCursor(cursor)

    local font = love.graphics.newFont("assets/PixelOperator-Bold.ttf", 50)
    font:setFilter("nearest", "nearest")
    love.graphics.setFont(font)

    GameData.saveData = SaveFileModule.load()

    SoundModule.load()
    UIModule.loadScene("splashscreen", true)
end

function love.update(deltaTime)
    UIModule.update(deltaTime)
    SoundModule.update()

    if not GameData.gameStarted then return end

    local scaledDeltaTime = deltaTime * GameData.timeScale

    GameplayLoopModule.update(scaledDeltaTime)
    EnemyModule.updateAll(scaledDeltaTime)
    UnitModule.updateAll(scaledDeltaTime)
end

function love.draw()
    RenderModule.drawAll()
end

function love.keypressed(key)
    if GameData.gameStarted then
        for index, unit in pairs(GameData.saveData.loadout) do
            if tonumber(key) == index then
                UIModule.startPlacement(unit)
            end
        end
    end

    if key == "o" then
       print(extra.getScaledMousePos())
    elseif key == "f11" then
        local fullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not fullscreen, "desktop")
    end
end

function love.mousepressed(_, _, button)
    SoundModule.playSound("click.wav", .5, true)
    UIModule.mousepressed(button)
end

function love.quit()
    SaveFileModule.save(GameData.saveData)
    love.window.setFullscreen(false)
end