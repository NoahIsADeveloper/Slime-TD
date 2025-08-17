local CurrentGameData = require("modules.currentGameData")
local SoundModule = require("modules.sound")
local EnemyModule = require("modules.enemy")
local UnitModule = require("modules.unit")
local MapModule = require("modules.map")
local UIModule = require("modules.ui")

local Module = {}

local waveCoroutine

local function waitSeconds(seconds, updateWaveTimer)
    local timer = 0
    local lastTick = seconds + 1

    if updateWaveTimer then CurrentGameData.waveTimer = math.ceil(seconds) end

    while timer < seconds do
        local deltaTime = coroutine.yield()
        if not deltaTime then deltaTime = 0 end

        timer = timer + deltaTime

        if updateWaveTimer then
            local waveTimer = math.ceil(seconds - timer)
            CurrentGameData.waveTimer = math.max(0, waveTimer)

            if waveTimer < lastTick then
                SoundModule.playSound("tick.wav", 1, true)
                lastTick = waveTimer
            end
        end
    end

    if updateWaveTimer then CurrentGameData.waveTimer = nil end
end

function Module.startGame(difficulty, map)
    if CurrentGameData.gameStarted then Module.stopGame() end

    local modulePath = "modules.data.difficulties." .. difficulty
    local path = "modules/data/difficulties/" .. difficulty .. ".lua"

    if not love.filesystem.getInfo(path) then return end

    UIModule.loadScene("ingame", true)

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
        waitSeconds(15, true)

        for index, wave in ipairs(CurrentGameData.waves) do
            CurrentGameData.currentWave = index

            for _, enemyGroup in ipairs(wave.enemies) do
                for _ = 1, enemyGroup.count do
                    EnemyModule.new(enemyGroup.type, enemyGroup.hidden)
                    waitSeconds(enemyGroup.spawnInterval or 1, false)
                end
            end

            while next(EnemyModule.getEnemies()) do
                waitSeconds(0.1, false)
            end

            if #CurrentGameData.waves ~= index then
                SoundModule.playSound("moneygain.wav", 1, true)
                CurrentGameData.cash = CurrentGameData.cash + (index * 50)

                waitSeconds(5, true)
            end
        end

        SoundModule.playSound("victory.wav", 0.5, false)
        CurrentGameData.gameWon = true
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

    UIModule.loadScene("resultscreen", false)
end

return Module
