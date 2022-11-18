local GnawedLeaf = {
    Item = Isaac.GetItemIdByName("Clicker")
}

local MAX_PLAYER_TYPE = 40 

---@param player EntityPlayer
function Clicker:OnUse(collectible, rng, player, useflags)
    if player:GetPlayerType() <= MAX_PLAYER_TYPE then -- 40 is the number of player types in game
        
    end
end

return function (BalanceMod)
    if EID then
        EID:addCollectible(Clicker.Item, "#Rerolls your character into another character#Cannot reroll normal characters into tainted and vice versa#{{Warning}} Red hearts will turn into soul hearts if the new character cannot have red hearts")
    end
end