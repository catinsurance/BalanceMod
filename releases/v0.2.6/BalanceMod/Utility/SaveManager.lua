local json = require("BalanceMod.API.json")

local SaveManager = {
    ModReference = nil,
    Loaded = {}
}

local function IsInitComplete()
    return SaveManager.ModReference ~= nil
end

local function print(...)
    _G.print("[BalanceMod] " .. ...)
end

local function Length(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

function SaveManager:Flush() -- save from cache
    if not IsInitComplete() then
        --print("SaveManager:Save() called before initialization was complete, no save was made.")
        return
    end

    local toJson = json.encode(SaveManager.Loaded)
    SaveManager.ModReference:SaveData(toJson)
end

function SaveManager:Get(key)
    if not IsInitComplete() then
        --print("SaveManager:Get() called before initialization was complete, no data was returned.")
        return
    end

    return SaveManager.Loaded[key]
end

function SaveManager:Set(key, value)
    if not IsInitComplete() then
        --print("SaveManager:Set() called before initialization was complete, no data was set.")
        return
    end

    SaveManager.Loaded[key] = value    
end

function SaveManager:Load()
    if not IsInitComplete() then
        --print("SaveManager:GetData() called before initialization was complete, no data was returned.")
        return
    end

    if Length(SaveManager.Loaded) > 0 then
        --print("SaveManager:GetData() called when data was already loaded, no data was returned.")
        return
    end

    if SaveManager.ModReference:HasData() then
        local data = SaveManager.ModReference:LoadData()
        local fromJson = data ~= "" and json.decode(data) or {}
        SaveManager.Loaded = fromJson
    else
        SaveManager.Loaded = {}
    end
end

function SaveManager:Init(ModReference)
    if IsInitComplete() then
        --print("SaveManager:Init() called after initialization was complete, aborting initialization.")
        return
    end

    SaveManager.ModReference = ModReference
end

function SaveManager:IsInitialized()
    return IsInitComplete()
end

return SaveManager