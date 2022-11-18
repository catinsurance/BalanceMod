local PoolHelper = require("BalanceMod.Utility.PoolHelper")

-- // Gish item change // --

local Gish = {
    Chance = 1/2,
}

local SaveManager = require("BalanceMod.Utility.SaveManager")

---@param itemPedestal EntityPickup
function Gish:NewItemPedestal(itemPedestal)
    if itemPedestal.FrameCount ~= 1 then return end
    if not SaveManager:Get("DSS") then return end
    if not SaveManager:Get("DSS").GishTweak then return end

    local rng = RNG()
    rng:SetSeed(Game():GetSeeds():GetStartSeed(), PoolHelper.ShiftIndex)

    local roll = rng:RandomFloat()
    local success = (roll < Gish.Chance)
    if success then return end
    
    PoolHelper:RerollPedestalIfType(itemPedestal:ToPickup(), CollectibleType.COLLECTIBLE_LITTLE_GISH, ItemPoolType.POOL_BOSS, rng)
end



-- /////////////////// --

return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, Gish.NewItemPedestal, PickupVariant.PICKUP_COLLECTIBLE)
end