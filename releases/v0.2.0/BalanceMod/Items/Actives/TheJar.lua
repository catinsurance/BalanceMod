-- // The Jar // --

local TheJar = {
    Item = Isaac.GetItemIdByName("The Jar"),
    ItemFull = Isaac.GetItemIdByName("The Jar (Full)"),
}

local function GetJarSlot(playerRef)
    local player = playerRef.Entity:ToPlayer()
    if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == TheJar.Item then
        return ActiveSlot.SLOT_PRIMARY
    elseif player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == TheJar.Item then
        return ActiveSlot.SLOT_SECONDARY
    end
end

local function GetFullJarSlot(playerRef)
    local player = playerRef.Entity:ToPlayer()
    if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == TheJar.ItemFull then
        return ActiveSlot.SLOT_PRIMARY
    elseif player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == TheJar.ItemFull then
        return ActiveSlot.SLOT_SECONDARY
    end
end

---@param entity Entity
function TheJar:OnHit(entity)
    local player = entity:ToPlayer()
    if player then
        local fullJarSlot = GetFullJarSlot(EntityRef(player))
        if fullJarSlot then
            player:RemoveCollectible(TheJar.ItemFull, false, fullJarSlot)
            player:AddCollectible(TheJar.Item, 0, false, fullJarSlot)
            SFXManager():Play(SoundEffect.SOUND_VAMP_GULP)
            player:SetMinDamageCooldown(60)
            return false
        end
    end
end

---@param collider Entity
---@param pickup EntityPickup
function TheJar:OnCollision(pickup, collider)
    local player = collider:ToPlayer()
    if player then
        if pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_DOUBLEPACK then
            local jarSlot = GetJarSlot(EntityRef(player))
            if jarSlot and not player:CanPickRedHearts() then
                player:RemoveCollectible(TheJar.Item, false, jarSlot)
                player:AddCollectible(TheJar.ItemFull, 0, false, jarSlot)
                pickup:PlayPickupSound()
                pickup:Remove()
            end
        end
    end
end

return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, TheJar.OnHit)
    BalanceMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, TheJar.OnCollision, PickupVariant.PICKUP_HEART) -- 0 = normal player
    
    if EID then
        EID:addCollectible(TheJar.Item, "Absorbs damage if full#Can be filled with only a full or double red heart#Emptied when damage is absorbed")
        EID:addCollectible(TheJar.ItemFull, "Absorbs damage if full#Can only be filled with a full red heart or a double red heart#Emptied when damage is absorbed", "The Jar")
    end
    

    return {
        OldItemId = CollectibleType.COLLECTIBLE_THE_JAR,
        NewItemId = TheJar.Item
    }
end