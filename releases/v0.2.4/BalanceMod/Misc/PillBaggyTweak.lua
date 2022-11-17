-- // Little Baggy tweak // --

local LittleBaggy = {
    Item = CollectibleType.COLLECTIBLE_LITTLE_BAGGY,
    IdentifiedFinish = false
}

local SaveManager = require("BalanceMod.Utility.SaveManager")

---@param player EntityPlayer
function LittleBaggy:PlayerUpdate(player)
    if SaveManager:Get("DSS") and SaveManager:Get("DSS").LittleBaggyTweak and not player:GetData().LittleBaggyIdentifyCheck then
        if player:HasCollectible(LittleBaggy.Item) then
            local itemPool = Game():GetItemPool()
            for i = 0, PillColor.NUM_PILLS do
                itemPool:IdentifyPill(i)
            end
            player:GetData().LittleBaggyIdentifyCheck = true
        end
    end
end

return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, LittleBaggy.PlayerUpdate)
end