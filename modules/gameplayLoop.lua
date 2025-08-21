local GameData = require("modules.data.gameData")
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

    if updateWaveTimer then GameData.waveTimer = math.ceil(seconds) end

    while timer < seconds do
        local deltaTime = coroutine.yield()
        if not deltaTime then deltaTime = 0 end

        timer = timer + deltaTime

        if updateWaveTimer then
            local waveTimer = math.ceil(seconds - timer)
            GameData.waveTimer = math.max(0, waveTimer)

            if waveTimer < lastTick then
                SoundModule.playSound("tick.wav", 1, true)
                lastTick = waveTimer
            end
        end
    end

    if updateWaveTimer then GameData.waveTimer = nil end
end

function Module.startGame(difficulty, map)
    if GameData.gameStarted then Module.stopGame() end

    local modulePath = "modules.data.difficulties." .. difficulty
    local path = "modules/data/difficulties/" .. difficulty .. ".lua"

    if not love.filesystem.getInfo(path) then return end

    UIModule.loadScene("ingame", true)

    local difficultyData = require(modulePath)
    GameData.waves = difficultyData.waves or {}

    GameData.gameStarted = true
    GameData.gameWon = false
    GameData.waveTimer = nil

    GameData.maxBaseHealth = 1500
    GameData.baseHealth = GameData.maxBaseHealth
    GameData.currentWave = 0
    GameData.cash = 800

    MapModule.load(map)

    waveCoroutine = coroutine.create(function()
        while UIModule.transitioning do
            waitSeconds(0.01, false)
        end

        waitSeconds(1, true)

        for index, wave in ipairs(GameData.waves) do
            GameData.currentWave = index

            for _, enemyGroup in ipairs(wave.enemies) do
                for _ = 1, enemyGroup.count do
                    EnemyModule.new(enemyGroup.type, enemyGroup.hidden)
                    waitSeconds(enemyGroup.spawnInterval or 1, false)
                end
            end

            while next(EnemyModule.getEnemies()) do
                waitSeconds(0.1, false)
            end

            if #GameData.waves ~= index then
                SoundModule.playSound("moneygain.wav", 1, true)
                GameData.cash = GameData.cash + (index * 100)

                waitSeconds(5, true)
            end
        end

        SoundModule.playSound("victory.wav", 0.5, false)
        GameData.gameWon = true
        Module.stopGame()
    end)

    coroutine.resume(waveCoroutine)
end

function Module.update(dt)
    if GameData.gameStarted then
        if GameData.baseHealth <= 0 then
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

    GameData.gameStarted = false
    GameData.waveTimer = nil
    GameData.waves = nil

    waveCoroutine = nil

    UIModule.loadScene("resultscreen", false)
end

return Module
