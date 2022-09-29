-- // Razor Blade // --

local RazorBlade = {
    Item = Isaac.GetItemIdByName("Razor Blade"),
    DamageIncrease = 1.8
}

---@param player EntityPlayer
---@param flag CacheFlag
function RazorBlade:OnCacheEvaluate(player, flag)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_RAZOR_BLADE) then
        if flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + RazorBlade.DamageIncrease
        end
    end
end

---@param player EntityPlayer
function RazorBlade:OnUse(_, _, player)
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
end

-- /////////////////// --

return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_USE_ITEM, RazorBlade.OnUse, RazorBlade.Item)
end