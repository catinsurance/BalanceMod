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
    if player:GetCollectibleNum(CarrotJuice.Item) > 0 then
        ---@diagnostic disable-next-line: assign-type-mismatch
        player.TearFlags = player.TearFlags | TearFlags.TEAR_KNOCKBACK
    end
end

-- /////////////////// --

BalanceMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, CarrotJuice.AddShotSpeed, CacheFlag.CACHE_SHOTSPEED)
BalanceMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, CarrotJuice.AddKnockback, CacheFlag.CACHE_TEARFLAG)

if EID then
    EID:addCollectible(CarrotJuice.Item, "{{ArrowUp}}+0.4 Shot speed#{{ArrowUp}} Increased knockback on tears")
end

return false