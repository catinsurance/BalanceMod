local PlayerTracker = require("BalanceMod.Utility.PlayerTracker")
local ExtraMath = require("BalanceMod.Utility.ExtraMath")

-- // Dataminer // --

local Dataminer = {
    Item = Isaac.GetItemIdByName("Dataminer"),
    ActiveForPlayers = {},
    BonusForPlayers = {},
    DamageBonus = 1,
    FireDelayBonus = 0.5,
}

---@param player EntityPlayer
---@param cacheFlag CacheFlag
function Dataminer:OnCacheUpdate(player, cacheFlag)
    if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == Dataminer.Item or player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == Dataminer.Item then
        local playerIndex = PlayerTracker:GetPlayerIndex(player)
        local activeCount = Dataminer.ActiveForPlayers[playerIndex]

        if activeCount ~= nil and activeCount > 0 then -- they have a new use on their active
            Dataminer.BonusForPlayers[playerIndex] = {
                Damage = Dataminer.DamageBonus * activeCount,
                FireDelay = ExtraMath:Clamp(Dataminer.FireDelayBonus * activeCount, 0.35, (Dataminer.FireDelayBonus * 3))
            }

            player.Damage = player.Damage + Dataminer.BonusForPlayers[playerIndex].Damage
            player.MaxFireDelay = player.MaxFireDelay - Dataminer.BonusForPlayers[playerIndex].FireDelay
        else -- their active is not active..... inactive, some would say.
            if Dataminer.BonusForPlayers[playerIndex] ~= nil then -- they have a bonus to remove
                player.Damage = player.Damage - Dataminer.BonusForPlayers[playerIndex].Damage
                player.MaxFireDelay = player.MaxFireDelay + Dataminer.BonusForPlayers[playerIndex].FireDelay
                Dataminer.BonusForPlayers[playerIndex] = nil
            end
        end
    end
end

---@param item CollectibleType 
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param activeSlot ActiveSlot
function Dataminer:OnUseItem(item, rng, player, useFlags, activeSlot)
    local playerIndex = PlayerTracker:GetPlayerIndex(player)

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type ~= EntityType.ENTITY_PLAYER then
            entity.SpriteRotation = entity.SpriteRotation + math.random(1, 360)
        end
    end

    if Dataminer.ActiveForPlayers[playerIndex] ~= nil then
        Dataminer.ActiveForPlayers[playerIndex] = Dataminer.ActiveForPlayers[playerIndex] + 1
    else
        Dataminer.ActiveForPlayers[playerIndex] = 1
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
    player:EvaluateItems()

    return true
end

function Dataminer:OnEnd()
    Dataminer.ActiveForPlayers = {} -- Reset the activeness

    for _, player in ipairs(PlayerTracker:GetPlayers()) do -- Update their cache
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
    end
end

-- /////////////////// --

-- Add callbacks below
return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Dataminer.OnCacheUpdate)
    BalanceMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Dataminer.OnEnd)

    BalanceMod:AddCallback(ModCallbacks.MC_USE_ITEM, Dataminer.OnUseItem, Dataminer.Item)
    if EID then
        EID:addCollectible(Dataminer.Item, "On use:#{{ArrowUp}} +1 Damage#{{ArrowUp}} +0.5 Firerate#{{Warning}} Rotates all enemies#Effect only lasts for the room#Does not affect hitboxes")
    end
    
    return {
        OldItemId = CollectibleType.COLLECTIBLE_DATAMINER,
        NewItemId = Dataminer.Item,
    }
end 