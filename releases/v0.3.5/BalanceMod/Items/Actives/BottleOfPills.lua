-- // Mom's Bottle of Pills // --

local BottleOfPills = {
    Item = Isaac.GetItemIdByName("Mom's Bottle of Pills"),
}

---@param player EntityPlayer
function BottleOfPills:OnUse(_, _, player)
    local pool = Game():GetItemPool()
    local pill = pool:GetPill(Game():GetSeeds():GetNextSeed())
    player:AddPill(pill)
    return true
end

-- /////////////////// --

BalanceMod:AddCallback(ModCallbacks.MC_USE_ITEM, BottleOfPills.OnUse, BottleOfPills.Item)

if EID then
    EID:addCollectible(BottleOfPills.Item, "Gives Isaac one pill on use")
end

return {
    OldItemId = CollectibleType.COLLECTIBLE_MOMS_BOTTLE_PILLS,
    NewItemId = BottleOfPills.Item,
}