local GameData = require("modules.data.gameData")
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
        if not enemy.element or enemy.data.health < 0 then goto continue end
        if enemy.data.hidden and not currentData.hiddenDetection then goto continue end

        local dx = enemy.element.x - unit.element.x
        local dy = enemy.element.y - unit.element.y
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist > range then goto continue end
        
        local progress = (enemy.data.currentWaypoint or 0) + (enemy.data.t or 0)

        if progress < farthestProgress then goto continue end

        farthestProgress = progress
        farthestEnemy = enemy

        ::continue::
    end

    return farthestEnemy
end

function Module:upgrade()
    if self.currentUpgrade == #self.data.upgrades then return end

    local nextData = self.data.upgrades[self.currentUpgrade + 1]
    if GameData.cash < nextData.cost then return end

    GameData.cash = GameData.cash - nextData.cost

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

    self.sellPrice = math.floor(currentData.cost / 1.2)
end

function Module:sell()
    if not GameData.gameStarted then return end
    GameData.cash = GameData.cash + self.sellPrice

    SoundModule.playSound("moneygain.wav", 1, true)

    self:remove()
end

function Module:update()
    local currentData = self.data.upgrades[self.currentUpgrade]
    if os.clock() - self.lastAttack < currentData.cooldown then return end

    local enemyInRange = findEnemyInRange(self, currentData.range)
    if enemyInRange and os.clock() - self.lastAttack >= currentData.cooldown / GameData.timeScale and not self.stunned then
        local dx = enemyInRange.element.x - self.element.x
        local dy = enemyInRange.element.y - self.element.y

        ---@diagnostic disable-next-line: deprecated
        local targetAngle = math.atan2(dy, dx)

        local currentRotation = self.element.rot or 0
        local angleDiff = targetAngle - currentRotation

        angleDiff = (angleDiff + math.pi) % (2 * math.pi) - math.pi

        if math.abs(angleDiff) > 0.01 then
            local maxRotation = currentData.turnSpeed * love.timer.getDelta() * GameData.timeScale
            local rotationAmount = math.min(math.abs(angleDiff), maxRotation)
            self.element.rot = currentRotation + rotationAmount * extra.sign(angleDiff)
        else
            self.element.rot = targetAngle
        end

        if math.abs(angleDiff) <= currentData.attackThreshold then
            SoundModule.playSound(currentData.soundName, .3, true)
            GameData.cash = GameData.cash + 1

            enemyInRange:takeDamage(currentData.damage)

            if currentData.hasSplashDamage then
                local splashDamage = math.floor(currentData.damage * (currentData.splashDamageRatio or 0.5))
                for _, otherEnemy in pairs(EnemyModule.getEnemies()) do
                    if otherEnemy ~= enemyInRange and otherEnemy.element and otherEnemy.data.health > 0 then
                        local sdx = otherEnemy.element.x - enemyInRange.element.x
                        local sdy = otherEnemy.element.y - enemyInRange.element.y
                        local dist = math.sqrt(sdx * sdx + sdy * sdy)

                        if dist <= currentData.splashRadius then
                            otherEnemy:takeDamage(splashDamage)
                        end
                    end
                end
            end

            self.lastAttack = os.clock()
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
        if GameData.cash < data.upgrades[1].cost then return end

        GameData.cash = GameData.cash - data.upgrades[1].cost

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
            sellPrice = data.upgrades[1].cost,
        }, Module)

        newUnit.currentUpgrade = 1
        newUnit.lastAttack = 0
        newUnit.stunned = false

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