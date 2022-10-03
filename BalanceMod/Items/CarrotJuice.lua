-- // Carrot Juice // --

local CarrotJuice = {
    Item = Isaac.GetItemIdByName("Carrot Juice")
}

---@param player EntityPlayer
function CarrotJuice:AddShotSpeed(player)
    player.ShotSpeed = player.ShotSpeed + (0.4 * player:GetCollectibleNum(CarrotJuice.Item))
end

---@param player EntityPlayer
function CarrotJuice:AddKnockback(player)
    ---@diagnostic disable-next-line: assign-type-mismatch
    player.TearFlags = player.TearFlags | TearFlags.TEAR_KNOCKBACK
end

-- /////////////////// --

return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, CarrotJuice.AddShotSpeed, CacheFlag.CACHE_SHOTSPEED)
    BalanceMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, CarrotJuice.AddKnockback, CacheFlag.CACHE_TEARFLAG)
    if not EID then return end
    EID:addCollectible(CarrotJuice.Item, "{{ArrowUp}}+0.4 Shot speed#{{ArrowUp}} Increased knockback on tears")
end