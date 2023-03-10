local PoolHelper = {
    ShiftIndex = 35,
    PickupNullIndex = 0
}

local ItemsToPools = {}

---@param pickup EntityPickup
function PoolHelper:GetPickupItemPool(pickup)
    local pool = Game():GetItemPool():GetLastPool()
    if pool ~= nil then
        ItemsToPools[GetPtrHash(pickup)] = pool
        return pool
    end
end

---@param pickup EntityPickup
function PoolHelper:PickupSpawned(pickup) -- do not call ths function directly
    return ItemsToPools[GetPtrHash(pickup)]
end

---@param pedestal EntityPickup
---@param collectible CollectibleType
---@param poolType ItemPoolType
---@param rng RNG
function PoolHelper:RerollPedestalIfType(pedestal, collectible, poolType, rng) -- replace pedestal with a different collectible from the same pool if it is the collectibletype specified
    local itemConfig = Isaac.GetItemConfig():GetCollectible(pedestal.SubType)
    local collectibleType = itemConfig.ID
    if collectibleType ~= collectible then return end

    local pool = Game():GetItemPool()
    
    local collectible = pool:GetCollectible(poolType, true, rng:GetSeed(), CollectibleType.COLLECTIBLE_LITTLE_GISH)
    pedestal:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible)
end

return PoolHelper