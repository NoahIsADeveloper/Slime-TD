local extra = require("modules.extra")

local Module = {}
Module.__index = Module

local Elements = {}
local ElementIdCounter = 0

local BaseWidth, BaseHeight = 800, 600

function Module:remove()
    Elements[self.tableIndex] = nil
end

return {
    new = function(spritePath, zindex, x, y, alpha, color, rot, scaleX, scaleY)
        local sprite

        if love.filesystem.getInfo(spritePath, "file") then
            sprite = love.graphics.newImage(spritePath)
        else
            sprite = love.graphics.newImage("assets/sprites/debug_missing.png")
        end

        if not color then color = {r = 255, g = 255, b = 255} end
        if not zindex then zindex = 0 end  -- default zindex if not provided

        ElementIdCounter = ElementIdCounter + 1
        local element = setmetatable({
            sprite = sprite,
            x = x or 0,
            y = y or 0,
            alpha = alpha or 1,
            rot = rot or 0,
            scaleX = scaleX or 1,
            scaleY = scaleY or 1,
            zindex = zindex or 0,
            tableIndex = ElementIdCounter,
            color = {r = color.r or 255, g = color.g or 255, b = color.b or 255}
        }, Module)

        Elements[ElementIdCounter] = element

        return element
    end,

    drawAll = function()
        local screenWidth, screenHeight = love.graphics.getDimensions()
        local scaleX = screenWidth / BaseWidth
        local scaleY = screenHeight / BaseHeight

        local scale = math.min(scaleX, scaleY)

        local offsetX = (screenWidth - BaseWidth * scale) / 2
        local offsetY = (screenHeight - BaseHeight * scale) / 2

        love.graphics.setScissor(offsetX, offsetY, BaseWidth * scale, BaseHeight * scale)

        local sortedElements = {}

        for _, element in pairs(Elements) do
            table.insert(sortedElements, element)
        end

        table.sort(sortedElements, function(a, b)
            if a.zindex == b.zindex then
                return a.tableIndex > b.tableIndex
            else
                return a.zindex < b.zindex
            end
        end)


        for _, element in ipairs(sortedElements) do
            local drawX = element.x * scale + offsetX
            local drawY = element.y * scale + offsetY

            local ox = element.sprite:getWidth() / 2
            local oy = element.sprite:getHeight() / 2

            love.graphics.setColor(element.color.r, element.color.g, element.color.b, element.alpha)
            love.graphics.draw(element.sprite, drawX, drawY, element.rot, element.scaleX * scale, element.scaleY * scale, ox, oy)
            love.graphics.setColor(1, 1, 1, 1)
        end

        love.graphics.setScissor()
    end,

    clearAll = function()
        Elements = {}
    end
}