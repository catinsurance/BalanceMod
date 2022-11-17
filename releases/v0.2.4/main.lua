-- Made by Maya (https://github.com/maya-bee)

-- // Variables // --

local BalanceMod = RegisterMod("Balance Mod", 1)

BalanceMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function() -- run this first as its really important
    if #Isaac.FindByType(EntityType.ENTITY_PLAYER) == 0 then
        Isaac.ExecuteCommand("reloadshaders")
    end
end)

local ChargeBars = require("BalanceMod.Utility.ChargeBars")
local SaveManager = require("BalanceMod.Utility.SaveManager")
local GiantBookApi = require("BalanceMod.API.GiantBookApi")
local PoolHelper = require("BalanceMod.Utility.PoolHelper")

local disabledItems = {}
local disabledTrinkets = {}

local function ArrayHasValue(array, value)
    for i, v in pairs(array) do
        if v == value then
            return i
        end
    end
end

-- //////////////////// --

-- // Initialization // --

SaveManager:Init(BalanceMod)
GiantBookApi:Init(BalanceMod)

BalanceMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, PoolHelper.PickupSpawned, PickupVariant.PICKUP_COLLECTIBLE)
BalanceMod:AddCallback(ModCallbacks.MC_POST_RENDER, ChargeBars.UpdateAllCustomChargeBars)

SaveManager:Load()

-- Load every item change

local items = {}
local trinkets = {}

-- Every item and trinket change that is technically a new item should return a table structured like below
--[[

    {
        OldItemId = xxx, -- The item ID of the item that was replaced
        NewItemId = xxx, -- The item ID of the item that replaced the old item
    }

]]

items[#items + 1] = include("BalanceMod.Items.Dataminer")(BalanceMod)
include("BalanceMod.Items.BreathOfLife")(BalanceMod)
items[#items + 1] = include("BalanceMod.Items.PlanC")(BalanceMod)
items[#items + 1] = include("BalanceMod.Items.MomsPad")(BalanceMod)
include("BalanceMod.Items.LemonMishap")(BalanceMod)
items[#items + 1] = include("BalanceMod.Items.D10")(BalanceMod)
include("BalanceMod.Items.BlackBean")(BalanceMod)
items[#items + 1] = include("BalanceMod.Items.RazorBlade")(BalanceMod)
items[#items + 1] = include("BalanceMod.Items.Abel")(BalanceMod)
include("BalanceMod.Items.DeadBird")(BalanceMod)
include("BalanceMod.Items.CarrotJuice")(BalanceMod)
include("BalanceMod.Items.Actives.HowToJump")(BalanceMod)
items[#items + 1] = include("BalanceMod.Items.Actives.TheJar")(BalanceMod)
items[#items + 1] = include("BalanceMod.Items.Familiars.Milk")(BalanceMod)
items[#items + 1] = include("BalanceMod.Items.Actives.BottleOfPills")(BalanceMod)

-- Load every trinket change

include("BalanceMod.Trinkets.Nazar")(BalanceMod)
trinkets[#trinkets + 1] = include("BalanceMod.Trinkets.FishHead")(BalanceMod)
trinkets[#trinkets + 1] = include("BalanceMod.Trinkets.Perfection")(BalanceMod)

-- Load every enemy change

include("BalanceMod.NPCs.MomsHand")(BalanceMod)
include("BalanceMod.NPCs.HealthChanges")(BalanceMod)

-- Load every misc change

include("BalanceMod.Misc.ItemQualityTweaks")(BalanceMod)
include("BalanceMod.Misc.ChadItem")(BalanceMod)
include("BalanceMod.Misc.GishItem")(BalanceMod)
include("BalanceMod.Misc.CursedEyeLowerKnockback")(BalanceMod)
include("BalanceMod.Misc.RKeyTweak")(BalanceMod)
include("BalanceMod.Misc.PillBaggyTweak")(BalanceMod)
include("BalanceMod.Misc.ThunderThighsTweak")(BalanceMod)

-- Load dss
include("BalanceMod.Misc.DeadSeaScrolls")()

-- //////////////////// --

-- // Update item pools // --

function BalanceMod:OnGameStart()
    local itemPool = Game():GetItemPool()
    for _, item in ipairs(items) do
        if item and not ArrayHasValue(disabledItems, item.NewItemId) then
            itemPool:RemoveCollectible(item.OldItemId)
        end
    end

    for _, trinket in ipairs(trinkets) do
        if trinket and not ArrayHasValue(disabledTrinkets, trinket.NewItemId) then
            itemPool:RemoveTrinket(trinket.OldItemId)
        end
    end
end

---@param pickup EntityPickup
function BalanceMod:PickupInit(pickup)
    if pickup.FrameCount == 1 then
        for _, trinket in ipairs(trinkets) do
            if trinket and trinket.OldItemId == pickup.SubType and not ArrayHasValue(trinkets, trinket.NewItemId) then
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, trinket.NewItemId, pickup.Position, Vector(0, 0), nil)
                pickup:Remove()
                break
            end
        end
    end
end

---@param player EntityPlayer
function BalanceMod:CorrectCharacter(player) -- this runs every player update so that mods that change the player's items don't break
    for _, item in ipairs(items) do
        if item then
            if not SaveManager:Get("DSS")[tostring(item.NewItemId)] then
                if player:HasCollectible(item.NewItemId, false) then
                    local itemSlot
                    for i = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET2 do
                        if player:GetActiveItem(i) == item.NewItemId then
                            itemSlot = i
                            break
                        end
                    end
                    if itemSlot then
                        local activeCharge = player:GetActiveCharge(itemSlot)
                        player:RemoveCollectible(item.NewItemId, false, itemSlot, false)
                        player:AddCollectible(item.OldItemId, activeCharge, false, itemSlot, 0)
                    else
                        player:RemoveCollectible(item.NewItemId, false, nil, false)
                        player:AddCollectible(item.OldItemId, nil, false)
                    end
                end
            else
                if player:HasCollectible(item.OldItemId, false) then
                    local itemSlot
                    for i = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET2 do
                        if player:GetActiveItem(i) == item.OldItemId then
                            itemSlot = i
                            break
                        end
                    end
                    if itemSlot then
                        local activeCharge = player:GetActiveCharge(itemSlot)
                        player:RemoveCollectible(item.OldItemId, false, itemSlot, false)
                        player:AddCollectible(item.NewItemId, activeCharge, false, itemSlot, 0)
                    else
                        player:RemoveCollectible(item.OldItemId, false, nil, false)
                        player:AddCollectible(item.NewItemId, nil, false)
                    end
                end
            end
        end
    end

    for _, trinket in ipairs(trinkets) do
        if trinket then
            if not SaveManager:Get("DSS")["trinket-" .. tostring(trinket.NewItemId)] then
                if player:HasTrinket(trinket.NewItemId, true) then
                    player:TryRemoveTrinket(trinket.NewItemId)
                    player:AddTrinket(trinket.OldItemId, false)
                end
            else

                if player:HasTrinket(trinket.OldItemId, true) then
                    player:TryRemoveTrinket(trinket.OldItemId)
                    player:AddTrinket(trinket.NewItemId, false)
                end
            end
        end
    end
end

-- //////////////////// --

-- // Save Handler // --

BalanceMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, SaveManager.Load)
BalanceMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, SaveManager.Flush)
BalanceMod:AddCallback(ModCallbacks.MC_POST_GAME_END, SaveManager.Flush)
BalanceMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, BalanceMod.OnGameStart)
BalanceMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BalanceMod.CorrectCharacter, 0) -- 0 = normal player variant
BalanceMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, BalanceMod.PickupInit, PickupVariant.PICKUP_TRINKET)

-- //////////////////// --