local CurrentGameData = require("modules.currentGameData")
local RenderModule = require("modules.render")
local SoundModule = require("modules.sound")
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

    local currentData = unit.data.upgrades[unit.currentUpgrade]

    for _, enemy in pairs(EnemyModule.getEnemies()) do
        if enemy.element and enemy.data.health > 0 then

            local canTarget = true

            if enemy.data.hidden and not currentData.hiddenDetection then
                canTarget = false
            end

            if canTarget then
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

    local elementProperties = {
        type = "sprite",
        spritePath = currentData.spritePath,
        zindex = 1,
        x = oldElement.x,
        y = oldElement.y,
        alpha = oldElement.alpha,
        color = oldElement.color,
        rot = oldElement.rot,
        scaleX = oldElement.scaleX,
        scaleY = oldElement.scaleY
    }

    self.element = RenderModule.new(elementProperties)
    oldElement:remove()

    self.sellPrice = math.floor(currentData.cost / 1.5)
end

function Module:sell()
    if not CurrentGameData.gameStarted then return end
    CurrentGameData.cash = CurrentGameData.cash + self.sellPrice

    SoundModule.playSound("moneygain.wav", 1, true)

    self:remove()
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
            SoundModule.playSound(currentData.soundName, 0.5, true)
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
    self = nil
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

        local elementProperties = {
            type = "sprite",
            spritePath = data.upgrades[1].spritePath,
            zindex = 2,
            x = x,
            y = y,
        }

        local newUnit = setmetatable({
            element = RenderModule.new(elementProperties),
            data = data,
            tableIndex = UnitIdCounter,
            sellPrice = math.floor(data.upgrades[1].cost / 1.5),
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