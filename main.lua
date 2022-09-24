-- Made by Maya (https://github.com/maya-bee)

-- // Variables // --

local BalanceMod = RegisterMod("Balance Mod", 1)

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

BalanceMod:AddCallback(ModCallbacks.MC_POST_RENDER, ChargeBars.UpdateAllCustomChargeBars)

-- Load every item change

local ChargeBars = require("BalanceMod.Utility.ChargeBars")
require("BalanceMod.Items.Dataminer")(BalanceMod)
require("BalanceMod.Items.BreathOfLife")(BalanceMod)

-- //////////////////// --

-- // Callbacks // --

-- /////////////// --