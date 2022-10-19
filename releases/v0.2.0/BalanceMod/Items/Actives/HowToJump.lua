-- // How To Jump // --

local HowToJump = {
    Item = CollectibleType.COLLECTIBLE_HOW_TO_JUMP,
    IFrames = 80,
}

---@param player EntityPlayer
function HowToJump:OnUse(_, _, player)
    player:SetMinDamageCooldown(HowToJump.IFrames)
end

-- /////////////////// --

return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_USE_ITEM, HowToJump.OnUse, HowToJump.Item)

    if EID then
        EID:addCollectible(HowToJump.Item, "Allows Isaac to jump over gaps and across the room#Grants invincibility for a short amount of time on use#{{CursedRoom}} Can be used to enter curse rooms")
    end

    return false
end