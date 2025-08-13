local CurrentGameData = require("modules.currentGameData")
local RenderModule = require("modules.render")
local extra = require("modules.extra")

local Enemies = {}
local EnemyIdCounter = 0

local Module = {}
Module.__index = Module

local function catmullRom(p0, p1, p2, p3, t)
    local t2 = t * t
    local t3 = t2 * t

    local x = 0.5 * ((2 * p1.x) +
        (-p0.x + p2.x) * t +
        (2*p0.x - 5*p1.x + 4*p2.x - p3.x) * t2 +
        (-p0.x + 3*p1.x - 3*p2.x + p3.x) * t3)

    local y = 0.5 * ((2 * p1.y) +
        (-p0.y + p2.y) * t +
        (2*p0.y - 5*p1.y + 4*p2.y - p3.y) * t2 +
        (-p0.y + 3*p1.y - 3*p2.y + p3.y) * t3)

    return x, y
end

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

    local currentMap = CurrentGameData.currentMap
    if not currentMap then self:remove() return end

    local waypoints = currentMap.waypoints
    if not waypoints then return end

    if self.data.currentWaypoint == 0 then
        self.element.x = waypoints[1].x
        self.element.y = waypoints[1].y
        self.data.currentWaypoint = 1
        self.data.t = 0
        return
    end

    local i = self.data.currentWaypoint

    if i >= #waypoints then
        self:remove()
        return
    end

    local p0 = waypoints[math.max(i - 1, 1)]
    local p1 = waypoints[i]
    local p2 = waypoints[math.min(i + 1, #waypoints)]
    local p3 = waypoints[math.min(i + 2, #waypoints)]

    local stepSize = 0.01
    local distanceToTravel = self.data.moveSpeed * deltaTime
    local traveledDistance = 0
    local lastX, lastY = catmullRom(p0, p1, p2, p3, self.data.t)
    local currentT = self.data.t

    while traveledDistance < distanceToTravel and currentT < 1 do
        local nextT = math.min(currentT + stepSize, 1)
        local nextX, nextY = catmullRom(p0, p1, p2, p3, nextT)
        local dx, dy = nextX - lastX, nextY - lastY
        local dist = math.sqrt(dx * dx + dy * dy)

        if traveledDistance + dist > distanceToTravel then
            local remaining = distanceToTravel - traveledDistance
            local ratio = remaining / dist
            currentT = currentT + ratio * stepSize
            traveledDistance = distanceToTravel
        else
            traveledDistance = traveledDistance + dist
            currentT = nextT
        end

        lastX, lastY = nextX, nextY
    end

    self.data.t = currentT

    if self.data.t >= 1 then
        self.data.t = self.data.t - 1
        self.data.currentWaypoint = i + 1

        if self.data.currentWaypoint >= #waypoints then
            CurrentGameData.baseHealth = CurrentGameData.baseHealth - self.data.health
            self:remove()

            return
        end

        i = self.data.currentWaypoint
        p0 = waypoints[math.max(i - 1, 1)]
        p1 = waypoints[i]
        p2 = waypoints[math.min(i + 1, #waypoints)]
        p3 = waypoints[math.min(i + 2, #waypoints)]
    end

    local x, y = catmullRom(p0, p1, p2, p3, self.data.t)
    self.element.x = x
    self.element.y = y

    local time = os.clock()
    self.element.rot = math.sin(time * (self.data.moveSpeed / 25)) / 5
end

function Module:remove()
    if CurrentGameData.gameStarted and self.data.health <= 0 then
        CurrentGameData.cash = CurrentGameData.cash + self.data.killReward
    end

    if self.element then self.element:remove() end
    Enemies[self.tableIndex] = nil
    self = nil
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
