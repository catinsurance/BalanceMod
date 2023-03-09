local ObsessedFan = {
    Item = CollectibleType.COLLECTIBLE_OBSESSED_FAN,
    Familiar = FamiliarVariant.OBSESSED_FAN,
}

---@param familiar EntityFamiliar
---@param collider Entity
function ObsessedFan:FamiliarCollision(familiar, collider)

    if not BalanceMod.IsSettingEnabled("ObsessedFan") then
        return
    end

    if collider.Type == EntityType.ENTITY_PROJECTILE then
        local playerSize = familiar.Player.Position
        -- calculations so that standing still gets you hit
        if collider.Position:Distance(playerSize) * (familiar.Player.Size / 10) > familiar.Player.Size * 2 then
            collider:Die()
        end
    end
end

BalanceMod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, ObsessedFan.FamiliarCollision, ObsessedFan.Familiar)

if not EID then return false end
EID:addCollectible(ObsessedFan.Item, "Follows Isaac's movement on a delay#Blocks projectiles")

return false