return {
    gameStarted = false,
    gameWon = false,

    currentMapMask = nil,
    currentMap = nil,

    timeSinceLastSpawn = 0,
    timeScale = 1,
    waveTimer = 0,

    maxBaseHealth = 1500,
    baseHealth = 1500,
    currentWave = 0,
    cash = 800,

    waves = {}
}