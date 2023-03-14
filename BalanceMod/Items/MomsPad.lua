local GiantBook = BalanceMod.GiantBookApi

-- // Mom's Pad // --

local MomsPad = {
    Item = Isaac.GetItemIdByName("Mom's Pad"),
    RadiusOfEffect = 115,
    EffectLifetime = 4 * 60, -- 4 seconds,
    EntityTracker = {}
}

---@param player EntityPlayer
function MomsPad:OnUse(_, _, player)
    local entityInRadius = Isaac.FindInRadius(player.Position, MomsPad.RadiusOfEffect, EntityPartition.ENEMY)
    for _, entity in ipairs(entityInRadius) do
        entity:AddEntityFlags(EntityFlag.FLAG_BAITED)
        MomsPad.EntityTracker[GetPtrHash(entity)] = Isaac.GetFrameCount()
    end

    GiantBook:PlayGiantBook("Appear", "giantbook_008_diaper.png", Color(1, 1, 1, 1), Color(1, 1, 1, 1), Color(0.9, 0.9, 0.9, 1), SoundEffect.SOUND_MOM_VOX_FILTERED_ISAAC)
    return {
        Discharge = true,
        ShowAnim = true,
        Remove = false
    }
end

---@param entity EntityNPC
function MomsPad:OnEntityUpdate(entity)
    local frameStart = MomsPad.EntityTracker[GetPtrHash(entity)]
    if frameStart ~= nil then
        if entity:HasEntityFlags(EntityFlag.FLAG_BAITED) then
            if Isaac.GetFrameCount() - frameStart > MomsPad.EffectLifetime then
                entity:ClearEntityFlags(EntityFlag.FLAG_BAITED)
                MomsPad.EntityTracker[GetPtrHash(entity)] = nil
            end
        else
            MomsPad.EntityTracker[GetPtrHash(entity)] = nil
        end    
    end
end

-- /////////////////// --

BalanceMod:AddCallback(ModCallbacks.MC_USE_ITEM, MomsPad.OnUse, MomsPad.Item)
BalanceMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, MomsPad.OnEntityUpdate)
if EID then
    EID:addCollectible(MomsPad.Item, "{{Bait}} Baits enemies in a small radius around Isaac#Baited enemies will be targeted by other enemies#Effect lasts 4 seconds")
end

return {
    OldItemId = CollectibleType.COLLECTIBLE_MOMS_PAD,
    NewItemId = MomsPad.Item,
}