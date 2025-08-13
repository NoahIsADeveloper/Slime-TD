---@diagnostic disable: inject-field, undefined-field

local GameplayLoopModule = require("modules.gameplayLoop")
local CurrentGameData = require("modules.currentGameData")
local RenderModule = require("modules.render")
local EnemyModule = require("modules.enemy")
local UnitModule = require("modules.unit")
local UIModule = require("modules.ui")
local extra = require("modules.extra")

function love.load()
    local imageData = love.image.newImageData("assets/sprites/cursor.png")
    local cursor = love.mouse.newCursor(imageData, 20, 20)
    love.mouse.setCursor(cursor)

    love.graphics.setFont(love.graphics.newFont("assets/PixelOperator-Bold.ttf", 24))

    GameplayLoopModule.startGame("normal", "grasslands")
end

function love.update(deltaTime)
    if not CurrentGameData.gameStarted then return end

    GameplayLoopModule.update(deltaTime)
    EnemyModule.updateAll(deltaTime)
    UnitModule.updateAll(deltaTime)
    UIModule.update(deltaTime)
end

function love.draw()
    RenderModule.drawAll()
    love.graphics.print("$" .. CurrentGameData.cash .. " | " .. CurrentGameData.baseHealth .. "/" .. CurrentGameData.maxBaseHealth .. " HP") --%note temporary
end

function love.keypressed(key)
    if key == "o" then
       print(extra.getScaledMousePos())
    elseif key == "e" and CurrentGameData.gameStarted then
        UIModule.startPlacement("handgunner")
    elseif key == "f11" then
        local fullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not fullscreen)
    end
end

function love.mousepressed(_, _, button)
    UIModule.mousepressed(button)
end