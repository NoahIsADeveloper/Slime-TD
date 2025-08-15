local extra = require("modules.extra")

local Module = {}
Module.__index = Module

local Elements = {}
local ElementIdCounter = 0

local BaseWidth, BaseHeight = 800, 600

function Module:remove()
    Elements[self.tableIndex] = nil
    self = nil
end

function Module:isHovering()
    if self.type == "sprite" then
        local mx, my = extra.getScaledMousePos()

        local sprite = self.sprite
        local x, y = self.x, self.y
        local width = sprite:getWidth() * self.scaleX
        local height = sprite:getHeight() * self.scaleY
        local halfWidth = width / 2
        local halfHeight = height / 2

        return mx >= (x - halfWidth) and mx <= (x + halfWidth)
           and my >= (y - halfHeight) and my <= (y + halfHeight)
    end

    return false
end

return {
    new = function(properties)
        local type = properties.type or "sprite"
        local sprite

        if type == "sprite" then
            if love.filesystem.getInfo(properties.spritePath or "", "file") then
                sprite = love.graphics.newImage(properties.spritePath)
            else
                sprite = love.graphics.newImage("assets/sprites/debug_missing.png")
            end
        end

        if not properties.color then properties.color = {r = 255, g = 255, b = 255} end
        if not properties.zindex then properties.zindex = 0 end

        ElementIdCounter = ElementIdCounter + 1
        local element = setmetatable({
            type = type,
            x = properties.x or 0,
            y = properties.y or 0,
            alpha = properties.alpha or 1,
            rot = properties.rot or 0,
            scaleX = properties.scaleX or 1,
            scaleY = properties.scaleY or 1,
            zindex = properties.zindex or 0,
            tableIndex = ElementIdCounter,
            color = {r = properties.color.r or 255, g = properties.color.g or 255, b = properties.color.b or 255},
        }, Module)

        if type == "sprite" then
            element.sprite = sprite
        elseif type == "text" then
            element.text = properties.text or ""
        end

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
            love.graphics.setColor(element.color.r / 255, element.color.g / 255, element.color.b / 255, element.alpha)

            if element.type == "sprite" then
                local ox = element.sprite:getWidth() / 2
                local oy = element.sprite:getHeight() / 2

                love.graphics.draw(
                    element.sprite,
                    element.x * scale + offsetX,
                    element.y * scale + offsetY,
                    element.rot,
                    element.scaleX * scale,
                    element.scaleY * scale,
                    ox,
                    oy
                )
            elseif element.type == "text" then
                local font = love.graphics.getFont()
                local ox = font:getWidth(element.text) / 2
                local oy = font:getAscent() / 2

                love.graphics.print(
                    element.text,
                    element.x * scale + offsetX,
                    element.y * scale + offsetY,
                    element.rot,
                    element.scaleX * scale,
                    element.scaleY * scale,
                    ox,
                    oy
                )
            end


            love.graphics.setColor(1, 1, 1, 1)
        end

        love.graphics.setScissor()
    end,

    clearAll = function()
        for _, element in pairs(Elements) do
            element:remove()
        end
    end
}