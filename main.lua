-- Made by Slugcat (https://github.com/maya-bee)

-- // Variables // --

-- ITS A GLOBA NOW WAHAAAAT
_G.BalanceMod = RegisterMod("Balance Mod", 1)

BalanceMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function() -- run this first as its really important
    if #Isaac.FindByType(EntityType.ENTITY_PLAYER) == 0 then
        Isaac.ExecuteCommand("reloadshaders")
    end
end)

include("BalanceMod.Utility.SaveManager")

BalanceMod.Chargebars = include("BalanceMod.Utility.ChargeBars")
BalanceMod.PoolHelper = include("BalanceMod.Utility.PoolHelper")
BalanceMod.TrinketHelper = include("BalanceMod.Utility.TrinketHelper")

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


BalanceMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, BalanceMod.PoolHelper.PickupSpawned, PickupVariant.PICKUP_COLLECTIBLE)
BalanceMod:AddCallback(ModCallbacks.MC_POST_RENDER, BalanceMod.Chargebars.UpdateAllCustomChargeBars)

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

items[#items + 1] = include("BalanceMod.Items.Dataminer")
include("BalanceMod.Items.BreathOfLife")
items[#items + 1] = include("BalanceMod.Items.PlanC")
items[#items + 1] = include("BalanceMod.Items.MomsPad")
include("BalanceMod.Items.LemonMishap")
items[#items + 1] = include("BalanceMod.Items.D10")
include("BalanceMod.Items.BlackBean")
items[#items + 1] = include("BalanceMod.Items.RazorBlade")
items[#items + 1] = include("BalanceMod.Items.Abel")
include("BalanceMod.Items.DeadBird")
include("BalanceMod.Items.CarrotJuice")
include("BalanceMod.Items.Actives.HowToJump")
items[#items + 1] = include("BalanceMod.Items.Actives.TheJar")
items[#items + 1] = include("BalanceMod.Items.Familiars.Milk")
items[#items + 1] = include("BalanceMod.Items.Actives.BottleOfPills")
items[#items + 1] = include("BalanceMod.Items.Actives.Clicker")
include("BalanceMod.Items.Actives.YuckHeart")
include("BalanceMod.Items.Familiars.ObsessedFan")

-- Load every trinket change

include("BalanceMod.Trinkets.Nazar")
trinkets[#trinkets + 1] = include("BalanceMod.Trinkets.FishHead")
trinkets[#trinkets + 1] = include("BalanceMod.Trinkets.Perfection")

-- Load every enemy change

include("BalanceMod.NPCs.MomsHand")
include("BalanceMod.NPCs.HealthChanges")

-- Load every misc change

include("BalanceMod.Misc.ItemQualityTweaks")
include("BalanceMod.Misc.ChadItem")
include("BalanceMod.Misc.GishItem")
include("BalanceMod.Misc.CursedEyeLowerKnockback")
include("BalanceMod.Misc.RKeyTweak")
include("BalanceMod.Misc.PillBaggyTweak")
include("BalanceMod.Misc.ThunderThighsTweak")

-- Load dss
include("BalanceMod.Misc.DeadSeaScrolls")

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

local function getIndexFromItemId(itemId)
    for _, item in ipairs(BalanceMod.SETTING_INFO.ITEM_CHANGES) do
        if item.Id == itemId then
            return item.Index
        end
    end

    for _, item in ipairs(BalanceMod.SETTING_INFO.TRINKET_CHANGES) do
        if item.Id == itemId then
            return item.Index
        end
    end
end

---@param player EntityPlayer
function BalanceMod:CorrectCharacter(player) -- this runs every player update so that mods that change the player's items don't break
    if not BalanceMod.IsDataLoaded() then return end

    for _, item in ipairs(items) do
        if item then
            local index = getIndexFromItemId(item.NewItemId)
            if index and not BalanceMod.IsSettingEnabled(tostring(index)) then
                if player:HasCollectible(item.NewItemId, false) then
                    local itemSlot
                    for i = ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_POCKET2 do
                        if player:GetActiveItem(i) == item.NewItemId then
                            itemSlot = i
                            break
                        end
                    end
                    if itemSlot then
                        local itemConfig = Isaac.GetItemConfig():GetCollectible(item.OldItemId)
                        local activeCharge = player:NeedsCharge(itemSlot) and player:GetActiveCharge(itemSlot) or itemConfig.MaxCharges

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
                        local itemConfig = Isaac.GetItemConfig():GetCollectible(item.NewItemId)
                        local activeCharge = player:NeedsCharge(itemSlot) and player:GetActiveCharge(itemSlot) or itemConfig.MaxCharges
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
            local index = getIndexFromItemId(trinket.NewItemId)
            if index and not BalanceMod.IsSettingEnabled(tostring(index)) then
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

-- // Hook Callbacks // --

BalanceMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, BalanceMod.OnGameStart)
BalanceMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BalanceMod.CorrectCharacter, 0) -- 0 = normal player variant
BalanceMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, BalanceMod.PickupInit, PickupVariant.PICKUP_TRINKET)

-- //////////////////// --