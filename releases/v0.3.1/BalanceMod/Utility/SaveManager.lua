local json = require("json")

local dataCache = {}
local dataCacheBackup = {}
local shouldRestoreOnUse = false
local loadedData = false
local inRunButNotLoaded = true

---@class SaveData
---@field run RunSave @Data that is reset when the run ends. Using glowing hourglass restores data to the last backup.
---@field hourglassBackup table @The data that is restored when using glowing hourglass. Don't touch this.
---@field file FileSave @Data that is persistent between runs.

---@class RunSave
---@field persistent table @Things in this table will not be reset until the run ends.
---@field level table @Things in this table will not be reset until the level is changed.
---@field room table @Things in this table will not be reset until the room is changed.

---@class FileSave
---@field achievements table @Achievement related data.
---@field dss table @Dead Sea Scrolls related data.
---@field settings table @Setting related data.
---@field misc table @Use the other categories if you can.

-- If you want to store default data, you must put it in this table.
---@return SaveData
function BalanceMod.DefaultSave()
    return {
        ---@type RunSave
        run = {
            persistent = {},
            level = {},
            room = {},
        },
        ---@type RunSave
        hourglassBackup = {
            persistent = {},
            level = {},
            room = {},
        },
        ---@type FileSave
        file = {
            dss = {},
            settings = {},
        },
    }
end

function BalanceMod.ShallowCopy(tab)
    return {table.unpack(tab)}
end

function BalanceMod.DeepCopy(tab)
    local copy = {}
    for k, v in pairs(tab) do
        if type(v) == 'table' then
            copy[k] = BalanceMod.DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

---@return RunSave
function BalanceMod.DefaultRunSave()
    return {
        persistent = {},
        level = {},
        room = {},
    }
end

---@return boolean
function BalanceMod.IsDataLoaded()
    return loadedData
end

function BalanceMod.PatchSaveTable(deposit, source)
    source = source or BalanceMod.DefaultSave()

    for i, v in pairs(source) do
        if deposit[i] ~= nil then
            if type(v) == "table" then
                if type(deposit[i]) ~= "table" then
                    deposit[i] = {}
                end

                deposit[i] = BalanceMod.PatchSaveTable(deposit[i], v)
            else
                deposit[i] = v
            end
        else
            if type(v) == "table" then
                if type(deposit[i]) ~= "table" then
                    deposit[i] = {}
                end

                deposit[i] = BalanceMod.PatchSaveTable({}, v)
            else
                deposit[i] = v
            end
        end
    end

    return deposit
end

function BalanceMod.SaveModData()
    if not loadedData then
        return
    end

    -- Save backup
    local backupData = BalanceMod.DeepCopy(dataCacheBackup)
    dataCache.hourglassBackup = BalanceMod.PatchSaveTable(backupData, BalanceMod.DefaultRunSave())

    local finalData = BalanceMod.DeepCopy(dataCache)
    finalData = BalanceMod.PatchSaveTable(finalData, BalanceMod.DefaultSave())

    BalanceMod:SaveData(json.encode(finalData))
end

-- For glowing hourglass
function BalanceMod.BackupModData()
    local copy = BalanceMod.DeepCopy(dataCache)
    dataCacheBackup = copy.run
end

function BalanceMod.RestoreModData()
    if shouldRestoreOnUse then
        dataCache.run = BalanceMod.DeepCopy(dataCacheBackup)
        dataCache.run = BalanceMod.PatchSaveTable(dataCache.run, BalanceMod.DefaultRunSave())
    end
end

function BalanceMod.LoadModData()
    if loadedData then
        return
    end

    local saveData = BalanceMod.DefaultSave()

    if BalanceMod:HasData() then
        local data = json.decode(BalanceMod:LoadData())
        saveData = BalanceMod.PatchSaveTable(data, BalanceMod.DefaultSave())
    end

    dataCache = saveData
    dataCacheBackup = dataCache.hourglassBackup
    loadedData = true
    inRunButNotLoaded = false
end

---@return table?
function BalanceMod.GetRunPersistentSave()
    if not loadedData then
        return
    end

    return dataCache.run.persistent
end

---@return table?
function BalanceMod.GetLevelSave()
    if not loadedData then
        return
    end

    return dataCache.run.level
end

---@return table?
function BalanceMod.GetRoomSave()
    if not loadedData then
        return
    end

    return dataCache.run.room
end

---@return table?
function BalanceMod.GetSettingsSave()
    if not loadedData then
        return
    end

    return dataCache.file.settings
end

---@return table?
function BalanceMod.GetDssSave()
    if not loadedData then
        return
    end

    return dataCache.file.dss
end

---@param settingName string
function BalanceMod.IsSettingEnabled(settingName)
    local data = BalanceMod.GetSettingsSave()
    if data then
        if data[settingName] == nil then
            data[settingName] = true
        end

        return data[settingName] == true
    else
        -- Default
        return true
    end
end

local function ResetRunSave()
    dataCache.run.level = {}
    dataCache.run.room = {}
    dataCache.run.persistent = {}

    dataCache.hourglassBackup.level = {}
    dataCache.hourglassBackup.room = {}
    dataCache.hourglassBackup.persistent = {}

    BalanceMod.SaveModData()
end

BalanceMod:AddCallback(ModCallbacks.MC_USE_ITEM, BalanceMod.RestoreModData, CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)

BalanceMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function()
    local newGame = Game():GetFrameCount() == 0

    BalanceMod.LoadModData()

    if newGame then
        ResetRunSave()
        shouldRestoreOnUse = false
    end
end)

BalanceMod:AddCallback(ModCallbacks.MC_POST_UPDATE, function ()
    local game = Game()
    if game:GetFrameCount() > 0 then
        if not loadedData and inRunButNotLoaded then
            BalanceMod.LoadModData()
            inRunButNotLoaded = false
        end
    end
end)

BalanceMod:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, function(_, mod)
    if mod.Name == "Balance Mod" and Isaac.GetPlayer() ~= nil then
        if loadedData then
            BalanceMod.SaveModData()
        end
    end
end)

BalanceMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    dataCache.run.room = {}
    BalanceMod.SaveModData()
    shouldRestoreOnUse = true
end)

BalanceMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    dataCache.run.level = {}
    BalanceMod.SaveModData()
    shouldRestoreOnUse = true
end)

BalanceMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function(_, shouldSave)
    BalanceMod.SaveModData()
    loadedData = false
    inRunButNotLoaded = false
    shouldRestoreOnUse = false
end)