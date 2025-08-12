local CurrentGameData = require("modules.currentGameData")
local RenderModule = require("modules.render")
local EnemyModule = require("modules.enemy")
local MapModule = require("modules.map")
local extra = require("modules.extra")

local Units = {}
local UnitIdCounter = 0

local Module = {}
Module.__index = Module

local function findEnemyInRange(unit, range)
    local farthestEnemy = nil
    local farthestProgress = -math.huge

    for _, enemy in pairs(EnemyModule.getEnemies()) do
        if enemy.element and enemy.data.health > 0 then
            local dx = enemy.element.x - unit.element.x
            local dy = enemy.element.y - unit.element.y
            local dist = math.sqrt(dx * dx + dy * dy)

            if dist <= range then
                local progress = (enemy.data.currentWaypoint or 0) + (enemy.data.t or 0)

                if progress > farthestProgress then
                    farthestProgress = progress
                    farthestEnemy = enemy
                end
            end
        end
    end

    return farthestEnemy
end

function Module:upgrade()
    if self.currentUpgrade == #self.data.upgrades then return end

    local nextData = self.data.upgrades[self.currentUpgrade + 1]
    if CurrentGameData.cash < nextData.cost then return end

    CurrentGameData.cash = CurrentGameData.cash - nextData.cost

    self.currentUpgrade = self.currentUpgrade + 1

    local currentData = self.data.upgrades[self.currentUpgrade]
    local oldElement = self.element

    self.element = RenderModule.new(currentData.spritePath, 1, oldElement.x, oldElement.y, oldElement.alpha, oldElement.color, oldElement.rot, oldElement.scaleX, oldElement.scaleY)
    oldElement:remove()
end

function Module:isClicked()
    local mx, my = extra.getScaledMousePos()
    local sprite = self.element.sprite
    local x, y = self.element.x, self.element.y

    local width = sprite:getWidth()
    local height = sprite:getHeight()
    local halfWidth = width / 2
    local halfHeight = height / 2

    return mx >= (x - halfWidth) and mx <= (x + halfWidth)
       and my >= (y - halfHeight) and my <= (y + halfHeight)
end

function Module:update()
    local currentData = self.data.upgrades[self.currentUpgrade]

    local enemyInRange = findEnemyInRange(self, currentData.range)
    if enemyInRange then
        local dx = enemyInRange.element.x - self.element.x
        local dy = enemyInRange.element.y - self.element.y

        ---@diagnostic disable-next-line: deprecated
        local angle = math.atan2(dy, dx)

        if os.clock() - self.lastAttack >= currentData.cooldown then
            CurrentGameData.cash = CurrentGameData.cash + 1

            enemyInRange:takeDamage(currentData.damage)
            self.lastAttack = os.clock()
            self.element.rot = angle
        end
    end
end

function Module:remove()
    if self.element then self.element:remove() end
    Units[self.tableIndex] = nil
end

return {
    currentlyPlacing = false,
    canPlace = false,

    placeholderType = "",

    placeholderRange = nil,
    placeholder = nil,

    new = function(unitType, x, y)
        local pathModule = "modules.data.units." .. unitType
        local path = "modules/data/units/" .. unitType .. ".lua"

        if not love.filesystem.getInfo(path) then return end

        local data = extra.deepCopy(require(pathModule))
        if CurrentGameData.cash < data.upgrades[1].cost then return end

        CurrentGameData.cash = CurrentGameData.cash - data.upgrades[1].cost

        UnitIdCounter = UnitIdCounter + 1

        local newUnit = setmetatable({
            element = RenderModule.new(data.upgrades[1].spritePath, 1, x, y),
            data = data,
            tableIndex = UnitIdCounter
        }, Module)

        newUnit.currentUpgrade = 1
        newUnit.lastAttack = 0

        Units[UnitIdCounter] = newUnit

        return newUnit
    end,

    findUnitByNumber = function(number)
        return Units[number]
    end,

    getUnits = function()
        return Units
    end,

    startPlacement = function(self, unitType)
        if self.currentlyPlacing then return end

        local pathModule = "modules.data.units." .. unitType
        local path = "modules/data/units/" .. unitType .. ".lua"

        if not love.filesystem.getInfo(path) then return end
        local data = require(pathModule).upgrades[1]
        self.currentlyPlacing = true

        local x, y = extra.getScaledMousePos()
        --local scale = data.range / 500

        --self.placeholderRange = RenderModule.new("assets/sprites/rangevisualizer.png", 99, x, y, .8, nil, 0, scale, scale)

        self.placeholder = RenderModule.new(data.spritePath, 99, x, y, .8)
        self.placeholderType = unitType
    end,

    updateAll = function(deltaTime)
        for _, unit in pairs(Units) do
            unit:update(deltaTime)
        end
    end,

    clearAll = function(self)
        for _, unit in pairs(Units) do
            unit:remove()
        end

        if self.placeholderRange then self.placeholderRange:remove() end
        if self.placeholder then self.placeholder:remove() end
    end
}