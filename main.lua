-- Made by Maya (https://github.com/maya-bee)

-- // Variables // --

local BalanceMod = RegisterMod("Balance Mod", 1)
local ChargeBars = require("BalanceMod.Utility.ChargeBars")
local SaveManager = require("BalanceMod.Utility.SaveManager")
local GiantBookApi = require("BalanceMod.API.GiantBookApi")

-- //////////////////// --

-- // Local Functions // --

local function GetArrayLength(table) -- faster but only works for arrays
    local counter = 0
    for _ in ipairs(table) do
        counter = counter + 1
    end

    return counter
end

local function GetTableLength(table) -- slower but works for all tables
    local counter = 0
    for _ in pairs(table) do
        counter = counter + 1
    end

    return counter
end

-- //////////////////// --

-- // Initialization // --

SaveManager:Init(BalanceMod)
GiantBookApi:Init(BalanceMod)

BalanceMod:AddCallback(ModCallbacks.MC_POST_RENDER, ChargeBars.UpdateAllCustomChargeBars)

-- Load every item change


require("BalanceMod.Items.Dataminer")(BalanceMod)
require("BalanceMod.Items.BreathOfLife")(BalanceMod)
require("BalanceMod.Items.PlanC")(BalanceMod)
require("BalanceMod.Items.MomsPad")(BalanceMod)
require("BalanceMod.Items.LemonMishap")(BalanceMod)

-- //////////////////// --

-- // Save Handler // --

BalanceMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, SaveManager.Load)
BalanceMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, SaveManager.Flush)

-- /////////////// --