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
    local x, y = love.mouse.getPosition()

    if key == "o" then
       print(x, y)
    elseif key == "e" then
        UnitModule:startPlacement("boxer")
    end
end

function love.mousemoved(x, y)
    if UnitModule.currentlyPlacing then
        UnitModule.placeholderRange.x, UnitModule.placeholderRange.y = x, y
        UnitModule.placeholder.x, UnitModule.placeholder.y = x, y
        UnitModule.canPlace = true

        local newW, newH = UnitModule.placeholder.sprite:getWidth(), UnitModule.placeholder.sprite:getHeight()
        local newRadius = math.max(newW, newH) / 2

        for _, unit in pairs(UnitModule.getUnits()) do
            local unitW, unitH = unit.element.sprite:getWidth(), unit.element.sprite:getHeight()
            local unitRadius = math.max(unitW, unitH) / 2

            local dx = x - unit.element.x
            local dy = y - unit.element.y
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

function love.mousepressed(x, y, button)
    if not UnitModule.currentlyPlacing then return end

    if button == 1 then
        if not UnitModule.canPlace then return end
        UnitModule.new(UnitModule.placeholderType, x, y)
    elseif button == 2 then
    else
        return
    end

    UnitModule.currentlyPlacing = false

    UnitModule.placeholderRange:remove()
    UnitModule.placeholder:remove()
end