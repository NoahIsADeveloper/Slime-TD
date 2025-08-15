---@diagnostic disable: inject-field, undefined-field

local GameplayLoopModule = require("modules.gameplayLoop")
local CurrentGameData = require("modules.currentGameData")
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

    SoundModule.load()
    UIModule.loadScene("splashscreen", true)
end

function love.update(deltaTime)
    UIModule.update(deltaTime)
    SoundModule.update()

    if not CurrentGameData.gameStarted then return end

    GameplayLoopModule.update(deltaTime)
    EnemyModule.updateAll(deltaTime)
    UnitModule.updateAll(deltaTime)
end

function love.draw()
    RenderModule.drawAll()
end

function love.keypressed(key)
    if key == "o" then
       print(extra.getScaledMousePos())
    elseif key == "e" and CurrentGameData.gameStarted then
        UIModule.startPlacement("basicturret")
    -- elseif key == "r" and CurrentGameData.gameStarted then
    --     GameplayLoopModule.stopGame()
    elseif key == "f11" then
        local fullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not fullscreen)
    end
end

function love.mousepressed(_, _, button)
    SoundModule.playSound("click.wav", .5, true)
    UIModule.mousepressed(button)
end

function love.quit()
    love.window.setFullscreen(false)
end