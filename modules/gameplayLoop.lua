local CurrentGameData = require("modules.currentGameData")
local EnemyModule = require("modules.enemy")
local UnitModule = require("modules.unit")
local MapModule = require("modules.map")

local Module = {}

local waveCoroutine

local function waitSeconds(seconds)
    local timer = 0
    while timer < seconds do
        local dt = coroutine.yield()
        if not dt then dt = 0 end
        timer = timer + dt
    end
end

function Module.startGame(difficulty)
    if CurrentGameData.gameStarted then
        Module.stopGame()
    end

    local modulePath = "modules.data.difficulties." .. difficulty
    local path = "modules/data/difficulties/" .. difficulty .. ".lua"

    if not love.filesystem.getInfo(path) then
        return
    end

    local difficultyData = require(modulePath)
    CurrentGameData.waves = difficultyData.waves or {}

    CurrentGameData.gameStarted = true
    CurrentGameData.gameWon = false

    MapModule.load("grasslands")

    waveCoroutine = coroutine.create(function()
        for _, wave in ipairs(CurrentGameData.waves) do
            for _, enemyGroup in ipairs(wave.enemies) do
                for _ = 1, enemyGroup.count do
                    EnemyModule.new(enemyGroup.type)
                    waitSeconds(enemyGroup.spawnInterval or 1)
                end
            end

            while next(EnemyModule.getEnemies()) do
                waitSeconds(0.1)
            end
        end

        CurrentGameData.gameWon = true

        waitSeconds(3)
        Module.stopGame()
    end)

    coroutine.resume(waveCoroutine)
end

function Module.update(dt)
    if waveCoroutine and CurrentGameData.gameStarted and coroutine.status(waveCoroutine) ~= "dead" then
        coroutine.resume(waveCoroutine, dt)
    end
end

function Module.stopGame()
    CurrentGameData.gameStarted = false

    EnemyModule:clearAll()
    UnitModule:clearAll()

    CurrentGameData.waves = nil
    waveCoroutine = nil
end

return Module