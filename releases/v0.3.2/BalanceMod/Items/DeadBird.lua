-- // Dead Bird // --

local DeadBird = {
    Item = Isaac.GetItemIdByName("Dead Bird"),
    BleedDuration = 60 * 3
}

---@param entity EntityEffect
---@param source EntityRef
function DeadBird:DamageTaken(entity, _, _, source)
    if not entity:IsEnemy() then return end

    if source.Type == EntityType.ENTITY_FAMILIAR and source.Variant == FamiliarVariant.DEAD_BIRD then
        if entity:HasEntityFlags(EntityFlag.FLAG_SLOW) then return end

        local player = source.Entity:ToFamiliar().Player
        entity:AddSlowing(EntityRef(player), 60, 0.5, Color(0.5, 0.3, 0.3, 1, 0, 0, 0))
    end
end

-- /////////////////// --

BalanceMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, DeadBird.DamageTaken)
if EID then
    EID:addCollectible(DeadBird.Item, "A bird familiar will appear whenever Isaac takes damage#The bird chases enemies and deals contact damage#The bird will slow enemies it touches")
end