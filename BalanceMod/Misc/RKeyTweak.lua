-- // R Key's damage // --

local RKey = {
    Item = CollectibleType.COLLECTIBLE_R_KEY
}

RKey.SelfDamageFlags = {
    DamageFlag.DAMAGE_FAKE,
    DamageFlag.DAMAGE_NO_MODIFIERS
}
local function WasSelfDamage(flags)
    local blacklisted = false
    for _, flag in pairs(RKey.SelfDamageFlags) do
        if flags & flag == flag then
            blacklisted = true
            break
        end
    end

    return blacklisted
end

function RKey:OnUse()
    BalanceMod.GetRunPersistentSave().RKeyUsed = true
end

---@param entity Entity
function RKey:OnDamage(entity, amount, flags, _, countdown)
    local player = entity:ToPlayer()
    if BalanceMod.IsSettingEnabled("RKeyTweak") and BalanceMod.GetRunPersistentSave() and BalanceMod.GetRunPersistentSave().RKeyUsed then
        if not WasSelfDamage(flags) and amount == 1 then
            if not player:HasCollectible(CollectibleType.COLLECTIBLE_WAFER) then
                player:TakeDamage(1, DamageFlag.DAMAGE_NO_MODIFIERS, EntityRef(player), countdown) -- make them take an extra damage
            end
        end
    end
end

BalanceMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, RKey.OnDamage)
BalanceMod:AddCallback(ModCallbacks.MC_USE_ITEM, RKey.OnUse, RKey.Item)