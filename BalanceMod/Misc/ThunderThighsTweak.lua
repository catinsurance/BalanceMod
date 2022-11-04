-- // Little Baggy tweak // --

local ThunderThighs = {
    Item = CollectibleType.COLLECTIBLE_THUNDER_THIGHS
}

---@param player EntityPlayer
function ThunderThighs:CacheUpdate(player, flag)
    if flag == CacheFlag.CACHE_SPEED then
        if player:HasCollectible(ThunderThighs.Item) then
            player.MoveSpeed = player.MoveSpeed + 0.1
        end
    end
end

return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ThunderThighs.CacheUpdate)
end