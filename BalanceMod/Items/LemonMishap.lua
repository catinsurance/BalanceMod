-- // Lemon Mishap // --

local LemonMishap = {
    Item = Isaac.GetItemIdByName("Lemon Mishap"),
    ConfusionDuration = 60 * 5
}

---@param entity EntityEffect
---@param source EntityRef
function LemonMishap:DamageTaken(entity, _, _, source)
    if entity:IsEnemy() and source.Variant == EffectVariant.PLAYER_CREEP_LEMON_MISHAP and not entity:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
        entity:AddConfusion(source, LemonMishap.ConfusionDuration, false)
    end
end

-- /////////////////// --

BalanceMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, LemonMishap.DamageTaken)
if EID then
    EID:addCollectible(LemonMishap.Item, "Spawns a tiny pool of creep#Deals 24 damage per second#{{Confusion}} Enemies that touch the creep will become confused")
end