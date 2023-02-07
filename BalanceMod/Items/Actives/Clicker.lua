---@diagnostic disable: param-type-mismatch
-- oh boy, here we go

local SaveManager = require("BalanceMod.Utility.SaveManager")
local PlayerTracker = require("BalanceMod.Utility.PlayerTracker")
local TrinketHelper = require("BalanceMod.Utility.TrinketHelper")

local Clicker = {
    Item = Isaac.GetItemIdByName("Clicker")
}

local DummyTrinkets = {
    ["Dummy Magdalene"] = PlayerType.PLAYER_MAGDALENE,
    ["Dummy Cain"] = PlayerType.PLAYER_CAIN,
    ["Dummy Judas"] = PlayerType.PLAYER_JUDAS,
    ["Dummy Blue Baby"] = PlayerType.PLAYER_BLUEBABY,
    ["Dummy Eve"] = PlayerType.PLAYER_EVE,
    ["Dummy Samson"] = PlayerType.PLAYER_SAMSON,
    ["Dummy Azazel"] = PlayerType.PLAYER_AZAZEL,
    ["Dummy Lazarus"] = PlayerType.PLAYER_LAZARUS,
    ["Dummy Eden"] = PlayerType.PLAYER_EDEN,
    ["Dummy Lost"] = PlayerType.PLAYER_THELOST,
    ["Dummy Lilith"] = PlayerType.PLAYER_LILITH,
    ["Dummy Keeper"] = PlayerType.PLAYER_KEEPER,
    ["Dummy Apollyon"] = PlayerType.PLAYER_APOLLYON,
    ["Dummy Forgotten"] = PlayerType.PLAYER_THEFORGOTTEN,
    ["Dummy Bethany"] = PlayerType.PLAYER_BETHANY,
    ["Dummy Jacob and Esau"] = PlayerType.PLAYER_JACOB,
    ["Dummy Tainted Isaac"] = PlayerType.PLAYER_ISAAC_B,
    ["Dummy Tainted Magdalene"] = PlayerType.PLAYER_MAGDALENE_B,
    ["Dummy Tainted Cain"] = PlayerType.PLAYER_CAIN_B,
    ["Dummy Tainted Judas"] = PlayerType.PLAYER_JUDAS_B,
    ["Dummy Tainted Blue Baby"] = PlayerType.PLAYER_BLUEBABY_B,
    ["Dummy Tainted Eve"] = PlayerType.PLAYER_EVE_B,
    ["Dummy Tainted Samson"] = PlayerType.PLAYER_SAMSON_B,
    ["Dummy Tainted Azazel"] = PlayerType.PLAYER_AZAZEL_B,
    ["Dummy Tainted Lazarus"] = PlayerType.PLAYER_LAZARUS_B,
    ["Dummy Tainted Eden"] = PlayerType.PLAYER_EDEN_B,
    ["Dummy Tainted Lost"] = PlayerType.PLAYER_THELOST_B,
    ["Dummy Tainted Lilith"] = PlayerType.PLAYER_LILITH_B,
    ["Dummy Tainted Keeper"] = PlayerType.PLAYER_KEEPER_B,
    ["Dummy Tainted Apollyon"] = PlayerType.PLAYER_APOLLYON_B,
    ["Dummy Tainted Forgotten"] = PlayerType.PLAYER_THEFORGOTTEN_B,
    ["Dummy Tainted Bethany"] = PlayerType.PLAYER_BETHANY_B,
    ["Dummy Tainted Jacob"] = PlayerType.PLAYER_JACOB_B
}

local UnlockedCharacters = {}

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
    PlayerType.PLAYER_LAZARUS2,
    PlayerType.PLAYER_EDEN,
    PlayerType.PLAYER_THELOST,
    PlayerType.PLAYER_BLACKJUDAS,
    PlayerType.PLAYER_LILITH,
    PlayerType.PLAYER_KEEPER,
    PlayerType.PLAYER_APOLLYON,
    PlayerType.PLAYER_THEFORGOTTEN,
    PlayerType.PLAYER_BETHANY,
    PlayerType.PLAYER_JACOB,
    PlayerType.PLAYER_MAGDALENE_B,
    PlayerType.PLAYER_CAIN_B,
    PlayerType.PLAYER_JUDAS_B,
    PlayerType.PLAYER_BLUEBABY_B,
    PlayerType.PLAYER_EVE_B,
    PlayerType.PLAYER_SAMSON_B,
    PlayerType.PLAYER_AZAZEL_B,
    PlayerType.PLAYER_LAZARUS_B,
    PlayerType.PLAYER_LAZARUS2_B,
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
    PlayerType.PLAYER_AZAZEL,
    PlayerType.PLAYER_LAZARUS,
    PlayerType.PLAYER_LAZARUS2,
    PlayerType.PLAYER_LAZARUS_B,
    PlayerType.PLAYER_LAZARUS2_B,
    PlayerType.PLAYER_EDEN,
    PlayerType.PLAYER_LILITH,
    PlayerType.PLAYER_APOLLYON,
    PlayerType.PLAYER_BETHANY,
    PlayerType.PLAYER_JACOB,
    PlayerType.PLAYER_MAGDALENE_B,
    PlayerType.PLAYER_CAIN_B,
    PlayerType.PLAYER_EVE_B,
    PlayerType.PLAYER_SAMSON_B,
    PlayerType.PLAYER_AZAZEL_B,
    PlayerType.PLAYER_EDEN_B,
    PlayerType.PLAYER_LILITH_B,
    PlayerType.PLAYER_APOLLYON_B,
    PlayerType.PLAYER_JACOB_B
}

local SoulHeartCharacters = {
    PlayerType.PLAYER_BLUEBABY,
    PlayerType.PLAYER_JUDAS_B,
    PlayerType.PLAYER_BLUEBABY_B,
    PlayerType.PLAYER_THEFORGOTTEN_B,
    PlayerType.PLAYER_BETHANY_B,
}

local CoinHeartCharacters = {
    PlayerType.PLAYER_KEEPER,
    PlayerType.PLAYER_KEEPER_B
}

local NoHeartCharacters = {
    PlayerType.PLAYER_THELOST,
    PlayerType.PLAYER_THELOST_B
}

local function clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

local function roundNearestWhole(value)
    local remainder = value % 1
    if remainder >= 0.5 then
        return math.ceil(value)
    else
        return math.floor(value)
    end
end

local function GetIndexFromValue(table, value)
    for i = 1, #table do
        if table[i] == value then
            return i
        end
    end
    return nil  
end

local function countOneBits(int)
    local countOnes = 0

    while (int > 0) do
        int = int & int - 1
        countOnes = countOnes + 1
    end

    return countOnes
end


---@param player EntityPlayer
---@return number soulHearts, number blackHearts @Soul hearts and black hearts
local function getSoulAndBlackHearts(player)
    -- read bit mask to get soul hearts
    local soulBlackBitMask = player:GetBlackHearts()

    local blackHearts = countOneBits(soulBlackBitMask) * 2
    local soulHearts = clamp(player:GetSoulHearts() - blackHearts, 0, 99)

    return soulHearts, blackHearts
end

---@param player EntityPlayer
local function removeHp(player)
    player:AddMaxHearts(-player:GetMaxHearts(), false)
    player:AddGoldenHearts(-player:GetGoldenHearts())
    player:AddRottenHearts(-player:GetRottenHearts())
    player:AddBrokenHearts(-player:GetBrokenHearts())
    player:AddHearts(-player:GetHearts())
    player:AddSoulHearts(-player:GetSoulHearts())
    player:AddBlackHearts(-player:GetBlackHearts())
    player:AddEternalHearts(-player:GetEternalHearts())
    player:AddBoneHearts(-player:GetBoneHearts())
end

local debugNext = {PlayerType.PLAYER_BETHANY_B, PlayerType.PLAYER_BETHANY, PlayerType.PLAYER_ISAAC}
local debugWasNext = 1
---@param player EntityPlayer
---@param rng RNG
local function RandomCharacter(player, rng)

    local playerIndex = PlayerTracker:GetPlayerIndex(player)
    local clickerData = SaveManager.Loaded.Clicker

    if not clickerData then
        clickerData = {}
        SaveManager.Loaded.Clicker = clickerData
    end

    if not clickerData[playerIndex] then
        clickerData[playerIndex] = {}
    end

    local oldType = player:GetPlayerType()

    local num = rng:RandomInt(#CharacterTypes) + 1
    local choice = debugNext[debugWasNext] or CharacterTypes[num]
    debugWasNext = debugWasNext + 1

    if not choice then
        choice = player:GetPlayerType()
    end

    if choice == player:GetPlayerType() then
        if #CharacterTypes ~= 1 then
            return RandomCharacter(player, rng)
        end
    end

    local boneHearts = player:GetBoneHearts()
    local redHearts = player:GetHearts()
    local redHeartContainers = player:GetMaxHearts()
    local rottenHearts = player:GetRottenHearts()
    local soulHearts, blackHearts = getSoulAndBlackHearts(player)
    local brokenHearts = player:GetBrokenHearts()
    local eternalHearts = player:GetEternalHearts()
    local goldenHearts = player:GetGoldenHearts()
    local oldSoulCharge = player:GetSoulCharge()
    local oldBloodCharge = player:GetBloodCharge()

    local subPlayer = player:GetSubPlayer()
    local subPlayerSoulHearts, subPlayerBlackHearts = 0, 0
    if subPlayer then
        subPlayerSoulHearts, subPlayerBlackHearts = getSoulAndBlackHearts(subPlayer) 
    end

    local wasRedHeartCharacter = GetIndexFromValue(RedHeartCharacters, oldType) ~= nil
    local wasSoulHeartCharacter = GetIndexFromValue(SoulHeartCharacters, oldType) ~= nil
    local wasCoinHeartCharacter = GetIndexFromValue(CoinHeartCharacters, oldType) ~= nil
    local wasNoHeartCharacter = GetIndexFromValue(NoHeartCharacters, oldType) ~= nil

    player:ChangePlayerType(choice)
    local newType = player:GetPlayerType()

    local isRedHeartCharacter = GetIndexFromValue(RedHeartCharacters, newType) ~= nil
    local isSoulHeartCharacter = GetIndexFromValue(SoulHeartCharacters, newType) ~= nil
    local isCoinHeartCharacter = GetIndexFromValue(CoinHeartCharacters, newType) ~= nil
    local isNoHeartCharacter = GetIndexFromValue(NoHeartCharacters, newType) ~= nil

    if not clickerData[playerIndex].LastRedHeartCharacter then
        clickerData[playerIndex].LastRedHeartCharacter = {
            RedHearts = redHearts,
            RedHeartContainers = redHeartContainers,
            BoneHearts = boneHearts,
            RottenHearts = rottenHearts,
            GoldenHearts = goldenHearts,
            EternalHearts = eternalHearts,
            BlackHearts = blackHearts,
            SoulHearts = soulHearts
        }
    end

    if player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B then
        if soulHearts == 0 then
            soulHearts = 2
        end

        print("adding blood charge",redHeartContainers)
        player:AddBloodCharge(redHeartContainers)
    end

    if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then

        print("adding soul charge",soulHearts + blackHearts)
        player:AddSoulCharge(soulHearts + blackHearts)
    end

    if isSoulHeartCharacter and wasRedHeartCharacter then
        soulHearts = redHeartContainers + soulHearts
        redHearts = 0
        redHeartContainers = 0
        boneHearts = 0
    end

    if isRedHeartCharacter and wasSoulHeartCharacter then
        -- restore red hearts
        
        redHeartContainers = clickerData[playerIndex].LastRedHeartCharacter.RedHeartContainers
        boneHearts = clickerData[playerIndex].LastRedHeartCharacter.BoneHearts

        soulHearts = clickerData[playerIndex].LastRedHeartCharacter.SoulHearts
        blackHearts = clickerData[playerIndex].LastRedHeartCharacter.BlackHearts

        rottenHearts = clickerData[playerIndex].LastRedHeartCharacter.RottenHearts
        goldenHearts = clickerData[playerIndex].LastRedHeartCharacter.GoldenHearts
        eternalHearts = clickerData[playerIndex].LastRedHeartCharacter.EternalHearts

        redHearts = clickerData[playerIndex].LastRedHeartCharacter.RedHearts + (boneHearts * 2)
    end

    if (wasNoHeartCharacter or wasCoinHeartCharacter) and not (isCoinHeartCharacter or isNoHeartCharacter) then
        redHeartContainers = clickerData[playerIndex].LastRedHeartCharacter.RedHeartContainers
        redHearts = clickerData[playerIndex].LastRedHeartCharacter.RedHearts
        boneHearts = clickerData[playerIndex].LastRedHeartCharacter.BoneHearts
        rottenHearts = clickerData[playerIndex].LastRedHeartCharacter.RottenHearts
        goldenHearts = clickerData[playerIndex].LastRedHeartCharacter.GoldenHearts
        eternalHearts = clickerData[playerIndex].LastRedHeartCharacter.EternalHearts
        soulHearts = clickerData[playerIndex].LastRedHeartCharacter.SoulHearts
        blackHearts = clickerData[playerIndex].LastRedHeartCharacter.BlackHearts
    end

    if (isNoHeartCharacter or isCoinHeartCharacter) and not (wasNoHeartCharacter or wasCoinHeartCharacter) then

        clickerData[playerIndex].LastRedHeartCharacter.SoulHearts = soulHearts
        clickerData[playerIndex].LastRedHeartCharacter.BlackHearts = blackHearts
    end

    if isCoinHeartCharacter then
        -- round redHeartContainer to even 
        redHeartContainers = clamp(redHeartContainers, 4, 6)
        redHeartContainers = redHeartContainers + redHeartContainers % 2
        redHearts = redHeartContainers
    end

    if player:GetPlayerType() == PlayerType.PLAYER_THELOST_B then
        player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, false)
    end

    if player:GetPlayerType() == PlayerType.PLAYER_THELOST or player:GetPlayerType() == PlayerType.PLAYER_THELOST_B then
        soulHearts = clamp(soulHearts - 1, 0, 99)
    end

    if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
        local soulAndBlackHearts = soulHearts + blackHearts
        boneHearts = math.ceil((math.floor(soulAndBlackHearts / 2) + redHeartContainers) / 2)
        redHeartContainers = 0
        redHearts = boneHearts * 2
    end

    if oldType == PlayerType.PLAYER_THEFORGOTTEN then
        redHeartContainers = boneHearts * 2
        boneHearts = 0
        redHearts = redHeartContainers
        soulHearts = subPlayerSoulHearts
        blackHearts = subPlayerBlackHearts


    end

    if oldType == PlayerType.PLAYER_BETHANY_B and (isRedHeartCharacter) then
        local oldRed = clickerData[playerIndex].LastRedHeartCharacter.RedHeartContainers
        local total = clamp(math.floor((oldBloodCharge - oldRed)), 0, 99)

        if total > oldRed then
            redHeartContainers = clickerData[playerIndex].LastRedHeartCharacter.RedHeartContainers + total
            redHearts = clickerData[playerIndex].LastRedHeartCharacter.RedHearts + total
        elseif total == oldRed then
            redHeartContainers = clickerData[playerIndex].LastRedHeartCharacter.RedHeartContainers
            redHearts = clickerData[playerIndex].LastRedHeartCharacter.RedHearts
        else
            redHeartContainers = math.max(clickerData[playerIndex].LastRedHeartCharacter.RedHeartContainers - math.abs(total), 0)
            redHeartContainers = math.ceil(redHeartContainers)
            redHearts = math.max(clickerData[playerIndex].LastRedHeartCharacter.RedHearts - math.abs(total), 1)
        end
    end

    if oldType == PlayerType.PLAYER_BETHANY and (isSoulHeartCharacter or isRedHeartCharacter) then
        local oldSoulAndBlack = clickerData[playerIndex].LastRedHeartCharacter.SoulHearts + clickerData[playerIndex].LastRedHeartCharacter.BlackHearts
        local total = clamp(math.ceil((oldSoulCharge - oldSoulAndBlack) / 2), 0, 99)
        print("total", total)
        print("old soul and black", oldSoulAndBlack)

        if total > oldSoulAndBlack then
            soulHearts = soulHearts + total
            blackHearts = clickerData[playerIndex].LastRedHeartCharacter.BlackHearts
        elseif total == oldSoulAndBlack then 
            soulHearts = clickerData[playerIndex].LastRedHeartCharacter.SoulHearts
            blackHearts = clickerData[playerIndex].LastRedHeartCharacter.BlackHearts
        else
            soulHearts = math.max(clickerData[playerIndex].LastRedHeartCharacter.SoulHearts - math.abs(total), 0)
            blackHearts = clickerData[playerIndex].LastRedHeartCharacter.BlackHearts
        end
    end

    if isRedHeartCharacter then
        clickerData[playerIndex].LastRedHeartCharacter = {
            RedHearts = redHearts,
            RedHeartContainers = redHeartContainers,
            BoneHearts = boneHearts,
            RottenHearts = rottenHearts,
            GoldenHearts = goldenHearts,
            EternalHearts = eternalHearts,
            SoulHearts = soulHearts,
            BlackHearts = blackHearts
        }
    end

    if player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B and soulHearts == 0 then
        soulHearts = 2
    end

    if player:GetPlayerType() == PlayerType.PLAYER_BETHANY and redHeartContainers == 0 then
        redHeartContainers = 2
    end

    if player:GetPlayerType() == PlayerType.PLAYER_BETHANY and redHearts == 0 then
        redHearts = clamp(redHeartContainers, 1, 2)
    end

    removeHp(player)
    player:AddMaxHearts(redHeartContainers, false)
    player:AddBoneHearts(boneHearts)

    player:AddHearts(redHearts)

    player:AddRottenHearts(rottenHearts)
    player:AddGoldenHearts(goldenHearts)
    player:AddEternalHearts(eternalHearts)
    player:AddBrokenHearts(brokenHearts)

    if not isCoinHeartCharacter then
        player:AddSoulHearts(soulHearts)
        player:AddBlackHearts(blackHearts)
    end

    print("redHeartContainers", redHeartContainers, "redHearts", redHearts, "boneHearts", boneHearts, "rottenHearts", rottenHearts, "goldenHearts", goldenHearts, "brokenHearts", brokenHearts, "soulHearts", soulHearts, "blackHearts", blackHearts, "eternalHearts", eternalHearts)
end

for trinketName in pairs(DummyTrinkets) do
    TrinketHelper:RemoveOnSpawn(Isaac.GetTrinketIdByName(trinketName))
end

function Clicker:CharacterUnlockedChecker(bool)

    if not bool then
        SaveManager.Loaded.Clicker = {}
    end

    local pool = Game():GetItemPool()
    for itemName, playerType in pairs(DummyTrinkets) do
        if pool:RemoveTrinket(Isaac.GetTrinketIdByName(itemName)) then
            table.insert(UnlockedCharacters, playerType)
        end
    end
end

---@param player EntityPlayer
---@param rng RNG
function Clicker:OnUse(collectible, rng, player, useflags)
    if GetIndexFromValue(CharacterTypes, player:GetPlayerType())  then -- if player is a normal character
        RandomCharacter(player, rng)
    end

    return true
end

return function (BalanceMod)

    BalanceMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Clicker.CharacterUnlockedChecker)
    BalanceMod:AddCallback(ModCallbacks.MC_USE_ITEM, Clicker.OnUse, Clicker.Item)

    if EID then
        EID:addCollectible(Clicker.Item, "#Rerolls your character into another character#Cannot reroll normal characters into tainted and vice versa#{{Warning}} Red hearts will turn into soul hearts if the new character cannot have red hearts")
    end

    return {
        OldItemId = CollectibleType.COLLECTIBLE_CLICKER,
        NewItemId = Clicker.Item,
    }
end