---@diagnostic disable: param-type-mismatch
-- oh boy, here we go

local Entity

local Clicker = {
    Item = Isaac.GetItemIdByName("Clicker")
}

local CharacterTypes = {
    PlayerType.PLAYER_ISAAC,
    PlayerType.PLAYER_MAGDALENE,
    PlayerType.PLAYER_CAIN,
    PlayerType.PLAYER_JUDAS,
    PlayerType.PLAYER_BLUEBABY,
    PlayerType.PLAYER_EVE,
    PlayerType.PLAYER_SAMSON,
    PlayerType.PLAYER_AZAZEL,
    PlayerType.PLAYER_LAZARUS,
    PlayerType.PLAYER_EDEN,
    PlayerType.PLAYER_THELOST,
    PlayerType.PLAYER_LILITH,
    PlayerType.PLAYER_KEEPER,
    PlayerType.PLAYER_APOLLYON,
    PlayerType.PLAYER_THEFORGOTTEN,
    PlayerType.PLAYER_BETHANY,
    PlayerType.PLAYER_JACOB,
    PlayerType.PLAYER_ISAAC_B,
    PlayerType.PLAYER_MAGDALENE_B,
    PlayerType.PLAYER_CAIN_B,
    PlayerType.PLAYER_JUDAS_B,
    PlayerType.PLAYER_BLUEBABY_B,
    PlayerType.PLAYER_EVE_B,
    PlayerType.PLAYER_SAMSON_B,
    PlayerType.PLAYER_AZAZEL_B,
    PlayerType.PLAYER_LAZARUS_B,
    PlayerType.PLAYER_EDEN_B,
    PlayerType.PLAYER_THELOST_B,
    PlayerType.PLAYER_LILITH_B,
    PlayerType.PLAYER_KEEPER_B,
    PlayerType.PLAYER_APOLLYON_B,
    PlayerType.PLAYER_THEFORGOTTEN_B,
    PlayerType.PLAYER_BETHANY_B,
    PlayerType.PLAYER_JACOB_B
}

local RedHeartCharacters = {
    PlayerType.PLAYER_ISAAC,
    PlayerType.PLAYER_MAGDALENE,
    PlayerType.PLAYER_CAIN,
    PlayerType.PLAYER_JUDAS,
    PlayerType.PLAYER_EVE,
    PlayerType.PLAYER_SAMSON,
    PlayerType.PLAYER_LAZARUS,
    PlayerType.PLAYER_EDEN,
    PlayerType.PLAYER_LILITH,
    PlayerType.PLAYER_APOLLYON,
    PlayerType.PLAYER_BETHANY,
    PlayerType.PLAYER_JACOB,
    PlayerType.PLAYER_ISAAC_B,
    PlayerType.PLAYER_MAGDALENE_B,
    PlayerType.PLAYER_CAIN_B,
    PlayerType.PLAYER_EVE_B,
    PlayerType.PLAYER_SAMSON_B,
    PlayerType.PLAYER_EDEN_B,
    PlayerType.PLAYER_LILITH_B,
    PlayerType.PLAYER_APOLLYON_B,
    PlayerType.PLAYER_JACOB_B
}

local SoulHeartCharacters = {
    PlayerType.PLAYER_BLUEBABY,
    PlayerType.PLAYER_AZAZEL,
    PlayerType.PLAYER_JUDAS_B,
    PlayerType.PLAYER_BLUEBABY_B,
    PlayerType.PLAYER_THEFORGOTTEN_B,
    PlayerType.PLAYER_BETHANY_B,
}

function GetIndexFromValue(table, value)
    for i = 1, #table do
        if table[i] == value then
            return i
        end
    end
    return nil  
end

---@param player EntityPlayer
---@param rng RNG
local function RandomCharacter(player, rng)
    local oldType = player:GetPlayerType()
    local choice = GetIndexFromValue(CharacterTypes, rng:RandomInt(#CharacterTypes) + 1)
    if choice == player:GetPlayerType() then
        return RandomCharacter(player, rng)
    end

    player:ChangePlayerType(choice)
    local newType = player:GetPlayerType()
    local wasRedHeartCharacter = GetIndexFromValue(RedHeartCharacters, oldType) ~= nil
    local wasSoulHeartCharacter = GetIndexFromValue(SoulHeartCharacters, oldType) ~= nil

    local isRedHeartCharacter = GetIndexFromValue(RedHeartCharacters, newType) ~= nil
    local isSoulHeartCharacter = GetIndexFromValue(SoulHeartCharacters, newType) ~= nil

    if isSoulHeartCharacter and wasRedHeartCharacter then

        
    end
end

---@param player EntityPlayer
---@param rng RNG
function Clicker:OnUse(collectible, rng, player, useflags)
    if player:GetPlayerType() <= MAX_PLAYER_TYPE then -- 40 is the number of player types in game
        local choice = rng:RandomInt(MAX_PLAYER_TYPE + 1)
    end
end

return function (BalanceMod)
    if EID then
        EID:addCollectible(Clicker.Item, "#Rerolls your character into another character#Cannot reroll normal characters into tainted and vice versa#{{Warning}} Red hearts will turn into soul hearts if the new character cannot have red hearts")
    end
end