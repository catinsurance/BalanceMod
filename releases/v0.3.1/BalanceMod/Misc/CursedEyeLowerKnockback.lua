-- // Cursed Eye's lower knockback // --

local CursedEye = {
    Item = CollectibleType.COLLECTIBLE_CURSED_EYE,
    KnockbackMultiplier = 0.35,
}

---@param tear EntityTear
function CursedEye:TearInit(tear)
    if tear.FrameCount == 1 and BalanceMod.IsSettingEnabled("CursedEyeTweak") then
        if tear.Parent ~= nil and tear.Parent.Type == EntityType.ENTITY_PLAYER then
            local player = tear.Parent:ToPlayer()
            if player:HasCollectible(CursedEye.Item) then
                tear.Mass = tear.Mass * CursedEye.KnockbackMultiplier
            end
        end
    end
end

BalanceMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, CursedEye.TearInit)