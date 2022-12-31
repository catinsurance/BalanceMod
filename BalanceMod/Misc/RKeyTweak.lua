local SaveManager = require("BalanceMod.Utility.SaveManager")

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
    SaveManager:Set("RKeyUsed", true)
end

---@param entity Entity
function RKey:OnDamage(entity, amount, flags, _, countdown)
    local player = entity:ToPlayer()
    if SaveManager:Get("RKeyUsed") == true and SaveManager:Get("DSS") and SaveManager:Get("DSS").RKeyTweak then
        if not WasSelfDamage(flags) and amount == 1 then
            if not player:HasCollectible(CollectibleType.COLLECTIBLE_WAFER) then
                player:TakeDamage(1, DamageFlag.DAMAGE_NO_MODIFIERS, EntityRef(player), countdown) -- make them take an extra damage
            end
        end
    end
end

function RKey:GameStart(newGame)
    if not newGame then
        SaveManager:Set("RKeyUsed", false)
    end
end

return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, RKey.OnDamage)
    BalanceMod:AddCallback(ModCallbacks.MC_USE_ITEM, RKey.OnUse, RKey.Item)
    BalanceMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, RKey.GameStart)
end