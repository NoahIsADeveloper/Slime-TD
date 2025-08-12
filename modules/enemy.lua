local RenderModule = require("modules.render")
local MapModule = require("modules.map")
local extra = require("modules.extra")

local Enemies = {}
local EnemyIdCounter = 0

local Module = {}
Module.__index = Module

function Module:takeDamage(damage)
    self.data.health = self.data.health - damage
    self.data.flashTimer = os.clock()
end

function Module:update(deltaTime)
    if self.data.health <= 0 then self:remove() return end
    if not self.element then self:remove() return end

    if os.clock() - self.data.flashTimer < 0.08 then
        self.element.color = {r = 255, g = 0, b = 0}
        self.element.alpha = 0.8
    else
        self.element.color = {r = 255, g = 255, b = 255}
        self.element.alpha = 1
    end

    local currentMap = MapModule.currentMap
    if not currentMap then self:remove() return end

    local waypoints = currentMap.waypoints
    if not waypoints then return end

    if self.data.currentWaypoint == 0 then
        self.element.x = waypoints[1].x
        self.element.y = waypoints[1].y
        self.data.currentWaypoint = 1
        return
    end

    local currentIndex = self.data.currentWaypoint + 1
    if currentIndex > #waypoints then self:remove() return end

    local startPos = waypoints[self.data.currentWaypoint]
    local targetPos = waypoints[currentIndex]

    local directionX = targetPos.x - self.element.x
    local directionY = targetPos.y - self.element.y
    local distance = math.sqrt(directionX * directionX + directionY * directionY)

    if distance == 0 then
        self.data.currentWaypoint = self.data.currentWaypoint + 1
        return
    end

    local moveDist = self.data.moveSpeed * deltaTime

    if moveDist >= distance then
        self.element.x = targetPos.x
        self.element.y = targetPos.y
        self.data.currentWaypoint = self.data.currentWaypoint + 1
    else
        local moveX = (directionX / distance) * moveDist
        local moveY = (directionY / distance) * moveDist
        self.element.x = self.element.x + moveX
        self.element.y = self.element.y + moveY
    end
end

function Module:remove()
     if self.element then self.element:remove() end
    Enemies[self.tableIndex] = nil
end

return {
    new = function(enemyType)
        local pathModule = "modules.data.enemies." .. enemyType
        local path = "modules/data/enemies/" .. enemyType .. ".lua"

        if not love.filesystem.getInfo(path) then return end

        EnemyIdCounter = EnemyIdCounter + 1
        local data = extra.deepCopy(require(pathModule))

        local newEnemy = setmetatable({
            element = RenderModule.new(data.spritePath, 2),
            data = data,
            tableIndex = EnemyIdCounter
        }, Module)

        newEnemy.data.health = newEnemy.data.maxHealth
        newEnemy.data.currentWaypoint = 0
        newEnemy.data.flashTimer = 0

        Enemies[EnemyIdCounter] = newEnemy

        return newEnemy
    end,

    findEnemyByNumber = function(number)
        return Enemies[number]
    end,

    getEnemies = function()
        return Enemies
    end,

    updateAll = function(deltaTime)
        for _, enemy in pairs(Enemies) do
            enemy:update(deltaTime)
        end
    end,

    clearAll = function()
        for _, enemy in pairs(Enemies) do
            enemy:remove()
        end
    end
}
