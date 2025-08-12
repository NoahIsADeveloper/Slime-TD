---@diagnostic disable: inject-field, undefined-field

local RenderModule = require("modules.render")
local EnemyModule = require("modules.enemy")
local UnitModule = require("modules.unit")
local MapModule = require("modules.map")
local extra = require("modules.extra")

function love.load()
    MapModule.load("grasslands")
    EnemyModule.new("slime")
end

function love.update(deltaTime)
    EnemyModule.updateAll(deltaTime)
    UnitModule.updateAll(deltaTime)
end

function love.draw()
    RenderModule.drawAll()
end

function love.keypressed(key)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local scaleX = screenWidth / 800
    local scaleY = screenHeight / 600
    local scale = math.min(scaleX, scaleY)
    local offsetX = (screenWidth - 800 * scale) / 2
    local offsetY = (screenHeight - 600 * scale) / 2

    local mouseX, mouseY = love.mouse.getPosition()
    local x = (mouseX - offsetX) / scale
    local y = (mouseY - offsetY) / scale

    if key == "o" then
       print(x, y)
    elseif key == "e" then
        UnitModule:startPlacement("handgunner")
    end
end

function love.mousemoved(x, y)
    if UnitModule.currentlyPlacing then
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local scaleX = screenWidth / 800
        local scaleY = screenHeight / 600
        local scale = math.min(scaleX, scaleY)
        local offsetX = (screenWidth - 800 * scale) / 2
        local offsetY = (screenHeight - 600 * scale) / 2

        local gameX = (x - offsetX) / scale
        local gameY = (y - offsetY) / scale

        UnitModule.placeholderRange.x, UnitModule.placeholderRange.y = gameX, gameY
        UnitModule.placeholder.x, UnitModule.placeholder.y = gameX, gameY
        UnitModule.canPlace = true

        local newW, newH = UnitModule.placeholder.sprite:getWidth(), UnitModule.placeholder.sprite:getHeight()
        local newRadius = math.max(newW, newH) / 2

        for _, unit in pairs(UnitModule.getUnits()) do
            local unitW, unitH = unit.element.sprite:getWidth(), unit.element.sprite:getHeight()
            local unitRadius = math.max(unitW, unitH) / 2

            local dx = gameX - unit.element.x
            local dy = gameY - unit.element.y
            local dist = math.sqrt(dx * dx + dy * dy)

            if dist < (newRadius + unitRadius) then
                UnitModule.canPlace = false
                break
            end
        end

        if UnitModule.canPlace then
            UnitModule.placeholder.color = {r = 255, g = 255, b = 255}
        else
            UnitModule.placeholder.color = {r = 255, g = 0, b = 0}
        end
    end
end

function love.mousepressed(_, _, button)
    if not UnitModule.currentlyPlacing then return end

    if button == 1 then
        if not UnitModule.canPlace then return end
        UnitModule.new(UnitModule.placeholderType, UnitModule.placeholder.x, UnitModule.placeholder.y)
    elseif button == 2 then
    else
        return
    end

    UnitModule.currentlyPlacing = false

    UnitModule.placeholderRange:remove()
    UnitModule.placeholder:remove()
end