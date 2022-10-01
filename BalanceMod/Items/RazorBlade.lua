local PlayerTracker = require("BalanceMod.Utility.PlayerTracker")

-- // Razor Blade // --

local RazorBlade = {
    Item = Isaac.GetItemIdByName("Razor Blade"),
    DamageIncrease = 1.8,
    PlayerSelfDamage = {}
}

---@param player EntityPlayer
---@param flag CacheFlag
function RazorBlade:OnCacheEvaluate(player, flag)
    if player:HasCollectible(RazorBlade.Item) then
        if flag == CacheFlag.CACHE_DAMAGE then
            local pindex = PlayerTracker:GetPlayerIndex(player)
            if RazorBlade.PlayerSelfDamage[pindex] == nil then
                RazorBlade.PlayerSelfDamage[pindex] = 0
            end
            player.Damage = player.Damage + (RazorBlade.DamageIncrease * RazorBlade.PlayerSelfDamage[pindex])
        end
    end
end

function RazorBlade:ResetCounter()
    RazorBlade.PlayerSelfDamage = {}
end

---@param player EntityPlayer
function RazorBlade:OnUse(_, _, player)
    if not player:TakeDamage(2, DamageFlag.DAMAGE_RED_HEARTS, EntityRef(player), 0) then
        return
    end

    local currentSelfDamage = RazorBlade.PlayerSelfDamage[PlayerTracker:GetPlayerIndex(player)] or 0
    RazorBlade.PlayerSelfDamage[PlayerTracker:GetPlayerIndex(player)] = currentSelfDamage + 1
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    
    return true
end

-- /////////////////// --

return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_USE_ITEM, RazorBlade.OnUse, RazorBlade.Item)
    BalanceMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, RazorBlade.OnCacheEvaluate)
    BalanceMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, RazorBlade.ResetCounter)
    BalanceMod:AddCallback(ModCallbacks.MC_POST_GAME_END, RazorBlade.ResetCounter)
end