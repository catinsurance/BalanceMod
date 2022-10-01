local PoolHelper = require("BalanceMod.Utility.PoolHelper")

-- // CHAD item change // --

local Chad = {
    Chance = 1/2,
}

---@param itemPedestal EntityPickup
function Chad:NewItemPedestal(itemPedestal)
    if itemPedestal.FrameCount ~= 1 then return end

    local rng = RNG()
    rng:SetSeed(Game():GetSeeds():GetStartSeed(), PoolHelper.ShiftIndex)

    local roll = rng:RandomFloat()
    local success = (roll < Chad.Chance)
    if success then return end
    
    PoolHelper:RerollPedestalIfType(itemPedestal:ToPickup(), CollectibleType.COLLECTIBLE_LITTLE_CHAD, ItemPoolType.POOL_BOSS, rng)
end



-- /////////////////// --

return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Chad.NewItemPedestal, PickupVariant.PICKUP_COLLECTIBLE)
end