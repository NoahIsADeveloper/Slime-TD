local RenderModule = require("modules.render")
local EnemyModule = require("modules.enemy")
local MapModule = require("modules.map")
local extra = require("modules.extra")

local Units = {}
local UnitIdCounter = 0

local Module = {}
Module.__index = Module

local function findEnemyInRange(unit, range)
    for _, enemy in pairs(EnemyModule.getEnemies()) do
        if enemy.element and enemy.data.health > 0 then
            local dx = enemy.element.x - unit.element.x
            local dy = enemy.element.y - unit.element.y
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist <= range then
                return enemy
            end
        end
    end

    return nil
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
            enemyInRange:takeDamage(currentData.damage)
            self.lastAttack = os.clock()
        elseif os.clock() - self.lastAttack < currentData.cooldown then
            self.element.rot = angle
        end
    end
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

        UnitIdCounter = UnitIdCounter + 1
        local data = extra.deepCopy(require(pathModule))

        local newUnit = setmetatable({
            element = RenderModule.new(data.upgrades[1].spritePath, 1, x, y),
            data = data,
            tableIndex = UnitIdCounter
        }, Module)

        newUnit.lastAttack = os.clock()
        newUnit.currentUpgrade = 1

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

        local x, y = love.mouse.getPosition()
        local scale = data.range / 500

        self.placeholderRange = RenderModule.new("assets/sprites/rangevisualizer.png", 99, x, y, .8, nil, 0, scale, scale)

        self.placeholder = RenderModule.new(data.spritePath, 99, x, y, .8)
        self.placeholderType = unitType
    end,

    updateAll = function(deltaTime)
        for _, unit in pairs(Units) do
            unit:update(deltaTime)
        end
    end
}