local GnawedLeaf = {
    Item = Isaac.GetItemIdByName("Clicker")
}

local MAX_PLAYER_TYPE = 40 

---@param player EntityPlayer
function GnawedLeaf:OnUse(collectible, rng, player, useflags)
    if player:GetPlayerType() <= MAX_PLAYER_TYPE then -- 40 is the number of player types in game
        
    end
end

if EID then
    EID:addCollectible(GnawedLeaf.Item, "#")
end