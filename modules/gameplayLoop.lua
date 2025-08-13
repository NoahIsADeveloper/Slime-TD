local CurrentGameData = require("modules.currentGameData")
local EnemyModule = require("modules.enemy")
local UnitModule = require("modules.unit")
local MapModule = require("modules.map")

local Module = {}

local waveCoroutine

local function waitSeconds(seconds, updateWaveTimer)
    local timer = 0
    if updateWaveTimer then CurrentGameData.waveTimer = math.ceil(seconds) end

    while timer < seconds do
        local dt = coroutine.yield()
        if not dt then dt = 0 end

        timer = timer + dt
        if updateWaveTimer then CurrentGameData.waveTimer = math.max(0, math.ceil(seconds - timer)) end
    end

    if updateWaveTimer then CurrentGameData.waveTimer = nil end
end

function Module.startGame(difficulty, map)
    if CurrentGameData.gameStarted then Module.stopGame() end

    local modulePath = "modules.data.difficulties." .. difficulty
    local path = "modules/data/difficulties/" .. difficulty .. ".lua"

    if not love.filesystem.getInfo(path) then return end

    local difficultyData = require(modulePath)
    CurrentGameData.waves = difficultyData.waves or {}

    CurrentGameData.gameStarted = true
    CurrentGameData.gameWon = false
    CurrentGameData.waveTimer = nil

    CurrentGameData.maxBaseHealth = 1500
    CurrentGameData.baseHealth = CurrentGameData.maxBaseHealth
    CurrentGameData.currentWave = 0
    CurrentGameData.cash = 800

    MapModule.load(map)

    waveCoroutine = coroutine.create(function()
        for index, wave in ipairs(CurrentGameData.waves) do
            CurrentGameData.currentWave = index

            for _, enemyGroup in ipairs(wave.enemies) do
                for _ = 1, enemyGroup.count do
                    EnemyModule.new(enemyGroup.type)
                    waitSeconds(enemyGroup.spawnInterval or 1, false)
                end
            end

            while next(EnemyModule.getEnemies()) do
                waitSeconds(0.1, false)
            end

            CurrentGameData.cash = CurrentGameData.cash + (index * 200)
            if CurrentGameData.waves[index + 1] then waitSeconds(5, true) end
        end

        CurrentGameData.gameWon = true

        waitSeconds(3, true)
        Module.stopGame()
    end)

    coroutine.resume(waveCoroutine)
end

function Module.update(dt)
    if CurrentGameData.gameStarted then
        if CurrentGameData.baseHealth <= 0 then
            Module.stopGame()
            return
        end

        if waveCoroutine and coroutine.status(waveCoroutine) ~= "dead" then
            coroutine.resume(waveCoroutine, dt)
        end
    end
end

function Module.stopGame()
    EnemyModule:clearAll()
    UnitModule:clearAll()

    CurrentGameData.gameStarted = false
    CurrentGameData.waveTimer = nil
    CurrentGameData.waves = nil

    waveCoroutine = nil
end

return Module
