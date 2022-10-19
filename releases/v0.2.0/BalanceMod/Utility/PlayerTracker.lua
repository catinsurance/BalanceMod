local PlayerTracker = {}

function PlayerTracker:GetPlayerIndex(player)
    local collectible = 1

    local playerType = player:GetPlayerType()
    if playerType == PlayerType.PLAYER_LAZARUS2_B then
        collectible = 2
    end

    local seed = player:GetCollectibleRNG(collectible):GetSeed()
    return tostring(seed)
end

function PlayerTracker:GetPlayerByIndex(playerIndex)
    for _, player in ipairs(PlayerTracker:GetPlayers()) do
        if PlayerTracker:GetPlayerIndex(player) == playerIndex then
            return player
        end
    end
end

function PlayerTracker:GetPlayers()
    local game = Game()
    local numPlayers = game:GetNumPlayers()
  
    local players = {}
    for i = 0, numPlayers do
      local player = Isaac.GetPlayer(i)
      table.insert(players, player)
    end
  
    return players
end

---@param player EntityPlayer
function PlayerTracker:HasMomsBox(player)
    return player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == CollectibleType.COLLECTIBLE_MOMS_BOX or player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == CollectibleType.COLLECTIBLE_MOMS_BOX
end

return PlayerTracker