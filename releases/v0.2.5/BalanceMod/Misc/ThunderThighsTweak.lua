-- // Little Baggy tweak // --

local ThunderThighs = {
    Item = CollectibleType.COLLECTIBLE_THUNDER_THIGHS
}

local SaveManager = require("BalanceMod.Utility.SaveManager")

---@param player EntityPlayer
function ThunderThighs:CacheUpdate(player, flag)
    if flag == CacheFlag.CACHE_SPEED and (SaveManager:Get("DSS") and SaveManager:Get("DSS").ThunderThighs) then
        if player:HasCollectible(ThunderThighs.Item) then
            player.MoveSpeed = player.MoveSpeed + 0.1
        end
    end
end

return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ThunderThighs.CacheUpdate)
end