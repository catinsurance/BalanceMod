-- // Fish Head // --

local FishHead = {
    Trinket = Isaac.GetTrinketIdByName("Fish Head"),
    Chance = 1/4,
    BlacklistedFlags = {
        DamageFlag.DAMAGE_FIRE,
        DamageFlag.DAMAGE_CLONES,
        DamageFlag.DAMAGE_POOP,
        DamageFlag.DAMAGE_DEVIL,
        DamageFlag.DAMAGE_TNT,
        DamageFlag.DAMAGE_IV_BAG,
        DamageFlag.DAMAGE_FAKE,
        DamageFlag.DAMAGE_CHEST
    },
}

---@param victim Entity
function FishHead:OnEntityHurt(victim, _, flags, entityRef)
    local player = victim:ToPlayer()
   
    if not player:HasTrinket(FishHead.Trinket) then return end
    
    local rng = player:GetTrinketRNG(FishHead.Trinket)
    local chance = rng:RandomFloat()
    if chance < FishHead.Chance then
        for _ = 1, player:GetTrinketMultiplier(FishHead.Trinket) do
            local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, LocustSubtypes.LOCUST_OF_PESTILENCE, player.Position, Vector(0, 0), player)
            fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        end
    else
        for _ = 1, player:GetTrinketMultiplier(FishHead.Trinket) do
            local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0, player.Position, Vector(0, 0), player)
            fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        end
    end
end

-- /////////////////// --

BalanceMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, FishHead.OnEntityHurt, EntityType.ENTITY_PLAYER)

if EID then
    EID:addTrinket(FishHead.Trinket, "#75% chance to spawn a blue fly on hit#25% chance to spawn a Locust of Pestilence on hit")
end

return {
    OldItemId = TrinketType.TRINKET_FISH_HEAD,
    NewItemId = FishHead.Trinket,
}