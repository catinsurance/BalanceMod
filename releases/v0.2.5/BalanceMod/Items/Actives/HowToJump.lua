-- // How To Jump // --

local HowToJump = {
    Item = CollectibleType.COLLECTIBLE_HOW_TO_JUMP,
    IFrames = 10,
}

---@param player EntityPlayer
function HowToJump:Update(player)
    if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == CollectibleType.COLLECTIBLE_HOW_TO_JUMP then
        local sprite = player:GetSprite()
        if sprite:IsFinished("Jump") then
            player:SetMinDamageCooldown(HowToJump.IFrames)
        end
    end
end

-- /////////////////// --

return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, HowToJump.Update)

    if EID then
        EID:addCollectible(HowToJump.Item, "Allows Isaac to jump over gaps and across the room#Grants invincibility for a short amount of time after use#{{CursedRoom}} Can be used to enter curse rooms")
    end

    return false
end