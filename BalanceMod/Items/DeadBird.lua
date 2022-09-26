-- // Dead Bird // --

local DeadBird = {
    Item = Isaac.GetItemIdByName("Dead Bird"),
    BleedDuration = 60 * 3
}

---@param entity EntityEffect
---@param source EntityRef
function DeadBird:DamageTaken(entity, _, _, source)
    if entity:IsEnemy() and source.Variant == EffectVariant.DEAD_BIRD and not entity:HasEntityFlags(EntityFlag.FLAG_BLEED_OUT) then
        entity:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
    end
end

function DeadBird:OnUpdate()
    
end

-- /////////////////// --

return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, DeadBird.DamageTaken)
end