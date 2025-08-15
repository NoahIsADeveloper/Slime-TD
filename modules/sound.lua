local Module = {
    activeSources = {},
    loadedSounds = {},
    loadedMusic = {},
    activeMusic = nil,
    activeMusicName = ""
}

function Module.load()
    local soundPath = "assets/sounds"
    for _, filename in ipairs(love.filesystem.getDirectoryItems(soundPath)) do
        local filePath = soundPath .. "/" .. filename
        if love.filesystem.getInfo(filePath, "file") then
            local sd = love.sound.newSoundData(filePath)
            local source = love.audio.newSource(sd, "static")
            Module.loadedSounds[filename] = { soundData = sd, source = source }
        end
    end

    local musicPath = "assets/music"
    for _, filename in ipairs(love.filesystem.getDirectoryItems(musicPath)) do
        local filePath = musicPath .. "/" .. filename
        if love.filesystem.getInfo(filePath, "file") then
            local source = love.audio.newSource(filePath, "stream")
            Module.loadedMusic[filename] = source
        end
    end
end

function Module.loadSound(filename)
    if Module.loadedSounds[filename] then return Module.loadedSounds[filename] end

    local filePath = "assets/sounds/" .. filename
    if love.filesystem.getInfo(filePath, "file") then
        local sd = love.sound.newSoundData(filePath)
        local source = love.audio.newSource(sd, "static")
        Module.loadedSounds[filename] = { soundData = sd, source = source }
        return Module.loadedSounds[filename]
    end

    return nil
end

function Module.playSound(name, volume, randomizePitch)
    local entry = Module.loadedSounds[name] or Module.loadSound(name)
    if not entry then return end

    local source = entry.source:clone()
    if randomizePitch then source:setPitch(1 + (math.random(-1000, 1000) / 7500)) end
    source:setVolume(volume or 1)
    source:play()
    table.insert(Module.activeSources, source)
end

function Module.playMusic(filename, loop)
    local source = Module.loadedMusic[filename] or Module.loadMusic(filename)
    if not source then return end

    if Module.activeMusic then
        Module.activeMusic:stop()
    end

    source:setLooping(loop ~= false)
    source:play()
    Module.activeMusic = source
    Module.activeMusicName = filename
end

function Module.stopMusic()
    if Module.activeMusic then
        Module.activeMusic:stop()
        Module.activeMusic = nil
        Module.activeMusicName = ""
    end
end

function Module.update()
    for i = #Module.activeSources, 1, -1 do
        local source = Module.activeSources[i]
        if not source:isPlaying() then
            table.remove(Module.activeSources, i)
            source:release()
        end
    end
end

return Module