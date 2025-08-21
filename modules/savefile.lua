local Module = {}

local SAVE_FILE = "savedata.lua"

local DEFAULT_DATA = {
    settings = {
        soundVolumeMulti = 0.5,
        musicVolumeMulti = 0.45,
    },
    unlockedTowers = {"basicturret"},
    loadout = {"basicturret"}
}

local function serializeTable(tbl, indent)
    indent = indent or ""

    local result = "{\n"
    local nextIndent = indent .. "    "

    for k, v in pairs(tbl) do
        local key
        if type(k) == "string" and k:match("^%a[%w_]*$") then
            key = k
        else
            key = "[" .. tostring(k) .. "]"
        end

        if type(v) == "table" then
            result = result .. nextIndent .. key .. " = " .. serializeTable(v, nextIndent) .. ",\n"
        elseif type(v) == "string" then
            result = result .. nextIndent .. key .. " = " .. string.format("%q", v) .. ",\n"
        else
            result = result .. nextIndent .. key .. " = " .. tostring(v) .. ",\n"
        end
    end

    result = result .. indent .. "}"

    return result
end

function Module.save(data)
    local contents = "return " .. serializeTable(data)
    love.filesystem.write(SAVE_FILE, contents)
end

function Module.load()
    if not love.filesystem.getInfo(SAVE_FILE) then return DEFAULT_DATA end

    local chunk, err = love.filesystem.load(SAVE_FILE)
    if not chunk then error("Error loading save file: " .. err) end

    local data = chunk()
    if type(data) ~= "table" then return DEFAULT_DATA end

    for k, v in pairs(DEFAULT_DATA) do
        if data[k] == nil then
            data[k] = v
        end
    end

    return data
end

return Module
