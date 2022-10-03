-- Made by Maya (https://github.com/maya-bee)

-- // Variables // --

local BalanceMod = RegisterMod("Balance Mod", 1)
local ChargeBars = require("BalanceMod.Utility.ChargeBars")
local SaveManager = require("BalanceMod.Utility.SaveManager")
local GiantBookApi = require("BalanceMod.API.GiantBookApi")
local PoolHelper = require("BalanceMod.Utility.PoolHelper")

-- //////////////////// --

-- // Initialization // --

SaveManager:Init(BalanceMod)
GiantBookApi:Init(BalanceMod)

BalanceMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, PoolHelper.PickupSpawned, PickupVariant.PICKUP_COLLECTIBLE)
BalanceMod:AddCallback(ModCallbacks.MC_POST_RENDER, ChargeBars.UpdateAllCustomChargeBars)

-- Load every item change

require("BalanceMod.Items.Dataminer")(BalanceMod)
require("BalanceMod.Items.BreathOfLife")(BalanceMod)
require("BalanceMod.Items.PlanC")(BalanceMod)
require("BalanceMod.Items.MomsPad")(BalanceMod)
require("BalanceMod.Items.LemonMishap")(BalanceMod)
require("BalanceMod.Items.D10")(BalanceMod)
require("BalanceMod.Items.BlackBean")(BalanceMod)
require("BalanceMod.Items.RazorBlade")(BalanceMod)
require("BalanceMod.Items.Abel")(BalanceMod)
require("BalanceMod.Items.DeadBird")(BalanceMod)
require("BalanceMod.Items.CarrotJuice")(BalanceMod)

-- Load every trinket change

require("BalanceMod.Trinkets.Nazar")(BalanceMod)
require("BalanceMod.Trinkets.FishHead")(BalanceMod)

-- Load every enemy change

require("BalanceMod.NPCs.MomsHand")(BalanceMod)

-- Load every misc change

require("BalanceMod.Misc.ChadItem")(BalanceMod)
require("BalanceMod.Misc.GishItem")(BalanceMod)

-- //////////////////// --

-- // Save Handler // --

BalanceMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, SaveManager.Load)
BalanceMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, SaveManager.Flush)

-- /////////////// --