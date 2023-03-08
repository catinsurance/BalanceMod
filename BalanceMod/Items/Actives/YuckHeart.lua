-- // How To Jump // --

local YuckHeart = {
    Item = CollectibleType.COLLECTIBLE_YUCK_HEART,
    FlyCount = 7,
}

---@param player EntityPlayer
function YuckHeart:Use(_, _, player)

    if player:GetRottenHearts() * 2 == player:GetMaxHearts() or player:GetMaxHearts() == 0 then
        player:AddBlueFlies(YuckHeart.FlyCount, player.Position, player)
    end

    return true
end

-- /////////////////// --

return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_USE_ITEM, YuckHeart.Use, YuckHeart.Item)

    if EID then
        EID:addCollectible(YuckHeart.Item, "{{RottenHeart}} +1 Rotten Heart#If there are no red heart containers, or all red heart containers are filled with Rotten Hearts, gives 5 blue flies")
    end

    return false
end