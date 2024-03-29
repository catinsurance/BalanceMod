local ExtraMath = require("BalanceMod.Utility.ExtraMath")

-- // The Black Bean // --

local BlackBean = {
    Item = Isaac.GetItemIdByName("The Black Bean"),
    PushbackForce = 50,
    RadiusInTiles = 3,
    DecayRateInTiles = 2,
    PickupMultiplier = 0.3, -- how much do we multiply the force by if its a pickup
    DecayAmount = 20, -- for every Blackbean.DecayRate distance, the pushback force is subtracted by this
    BlacklistedEntities = { -- dont push these back
        [EntityType.ENTITY_EFFECT] = true,
        [EntityType.ENTITY_PLAYER] = true,
        [EntityType.ENTITY_FAMILIAR] = true,
    }
}

---@param entity Entity
function BlackBean:OnHurt(entity)
    local player = entity:ToPlayer()
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_BEAN) then
        Game():ButterBeanFart(player.Position, ExtraMath:TilesToUnits(BlackBean.RadiusInTiles), player, true, true)
    end
end

-- /////////////////// --

BalanceMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, BlackBean.OnHurt, EntityType.ENTITY_PLAYER)

if EID then
    EID:addCollectible(BlackBean.Item, "Isaac will fart upon taking damage#Fart deals poison damage#{{Collectible" .. BlackBean.Item .. "}} Fart pushes things away with immense force!")
end

return false