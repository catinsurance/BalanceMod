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

return PlayerTracker