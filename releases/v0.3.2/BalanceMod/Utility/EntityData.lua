local Module = {}
local data = {}

function Module:GetPlayerIndex(player)
    local collectible = 1

    local playerType = player:GetPlayerType()
    if playerType == PlayerType.PLAYER_LAZARUS2_B then
        collectible = 2
    end

    local seed = player:GetCollectibleRNG(collectible):GetSeed()
    return tostring(seed)
end

function Module:GetPlayers()
    local game = Game()
    local numPlayers = game:GetNumPlayers() - 1
  
    local players = {}
    for i = 0, numPlayers do
      local player = Isaac.GetPlayer(i)
      table.insert(players, player)
    end
  
    return players
end

function Module:GetFromIndex(index)
    local players = Module:GetPlayers()
    for _, player in ipairs(players) do
        if Module:GetPlayerIndex(player) == index then
            return player
        end
    end
end

function Module:GetEntityData(entity)
    if not entity then return nil end
    
    if entity.Type == EntityType.ENTITY_PLAYER then
        local player = entity:ToPlayer()
        if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then
            player = player:GetOtherTwin()
        end
        local index = Module:GetPlayerIndex(player)
        if not data[index] then
            data[index] = {}
        end

        return data[index]
    elseif entity.Type == EntityType.ENTITY_FAMILIAR then
        local index = entity:ToFamiliar().InitSeed
        if not data[index] then
            data[index] = {}
        end
        return data[index]
    else 
        local index = GetPtrHash(entity)
        if not data[index] then
            data[index] = {}
        end
        return data[index]
    end
end

function Module:RemoveEntityData(entity)
    if not entity then return end
    
    if entity.Type == EntityType.ENTITY_PLAYER then
        local player = entity:ToPlayer()
        if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then
            player = player:GetOtherTwin()
        end
        local index = Module:GetPlayerIndex(player)
        if data[index] then
            data[index] = nil
        end
    elseif entity.Type == EntityType.ENTITY_FAMILIAR then
        local index = entity:ToFamiliar().InitSeed
        if data[index] then
            data[index] = nil
        end
    else 
        local index = GetPtrHash(entity)
        if data[index] then
            data[index] = {}
        end
    end
end

return Module