-- // Fish Head // --

local FishHead = {
    Trinket = Isaac.GetTrinketIdByName("Fish Head"),
    Chance = 1/6,
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
        local wasSelfDamage
    
        if entityRef.Entity == nil then
            wasSelfDamage = true
        else
            if entityRef.Entity.Parent ~= nil then
                wasSelfDamage = (entityRef.Entity.Parent:ToPlayer() or entityRef.Entity.Parent:ToFamiliar()) ~= nil
            end
        
            if entityRef.SpawnerEntity ~= nil then
                wasSelfDamage = (entityRef.Entity.SpawnerEntity:ToPlayer() or entityRef.Entity.SpawnerEntity:ToFamiliar()) ~= nil
            end 
    
            if wasSelfDamage == nil then
                for _, flag in ipairs(FishHead.BlacklistedFlags) do
                    if flags & flag == flag then
                        wasSelfDamage = true
                        break
                    end
                end
            end
        
            if wasSelfDamage == nil then
                wasSelfDamage = (entityRef.Entity:ToPlayer()) ~= nil
            end
        end

        if not wasSelfDamage then
            for _ = 1, player:GetTrinketMultiplier(FishHead.Trinket) do
                Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, LocustSubtypes.LOCUST_OF_PESTILENCE, player.Position, Vector(0, 0), player)
            end
        end
    end
end

-- /////////////////// --

return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, FishHead.OnEntityHurt, EntityType.ENTITY_PLAYER)
end