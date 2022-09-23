-- Made by Maya (https://github.com/maya-bee)

-- // Variables // --

local BalanceMod = RegisterMod("Balance Mod", 1)
local ChargeBars = require("BalanceMod.Utility.ChargeBars")
local VectorZero = Vector(0, 0)

-- //////////////////// --

-- // Local Functions // --

local function GetArrayLength(table) -- faster but only works for arrays
    local counter = 0
    for _ in ipairs(table) do
        counter = counter + 1
    end

    return counter
end

local function GetTableLength(table) -- slower but works for all tables
    local counter = 0
    for _ in pairs(table) do
        counter = counter + 1
    end

    return counter
end

local function GetPlayerIndex(player)
    local collectible = 1

    local playerType = player:GetPlayerType()
    if playerType == PlayerType.PLAYER_LAZARUS2_B then
        collectible = 2
    end

    local seed = player:GetCollectibleRNG(collectible):GetSeed()
    return tostring(seed)
end

local function GetPlayers()
    local game = Game()
    local numPlayers = game:GetNumPlayers()
  
    local players = {}
    for i = 0, numPlayers do
      local player = Isaac.GetPlayer(i)
      table.insert(players, player)
    end
  
    return players
end

local function Clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    end
    return value
end

local function Round(num)
    local ofs = 2^52
    if math.abs(num) > ofs then
      return num
    end
    return num < 0 and num - ofs + ofs or num + ofs - ofs
end

-- //////////////////// --

-- // Initialization // --

BalanceMod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, ChargeBars.UpdateChargeBarsForPlayer)

-- //////////////////// --

-- // Dataminer // --

local Dataminer = {
    Item = Isaac.GetItemIdByName("Dataminer"),
    ActiveForPlayers = {},
    BonusForPlayers = {},
    DamageBonus = 1,
    FireDelayBonus = 0.5,
}

---@param player EntityPlayer
---@param cacheFlag CacheFlag
function Dataminer:OnCacheUpdate(player, cacheFlag)
    if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == Dataminer.Item or player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == Dataminer.Item then
        local playerIndex = GetPlayerIndex(player)
        local activeCount = Dataminer.ActiveForPlayers[playerIndex]

        if activeCount ~= nil and activeCount > 0 then -- they have a new use on their active
            Dataminer.BonusForPlayers[playerIndex] = {
                Damage = Dataminer.DamageBonus * activeCount,
                FireDelay = Clamp(Dataminer.FireDelayBonus * activeCount, 0.35, (Dataminer.FireDelayBonus * 3))
            }

            player.Damage = player.Damage + Dataminer.BonusForPlayers[playerIndex].Damage
            player.MaxFireDelay = player.MaxFireDelay - Dataminer.BonusForPlayers[playerIndex].FireDelay
        else -- their active is not active..... inactive, some would say.
            if Dataminer.BonusForPlayers[playerIndex] ~= nil then -- they have a bonus to remove
                player.Damage = player.Damage - Dataminer.BonusForPlayers[playerIndex].Damage
                player.MaxFireDelay = player.MaxFireDelay + Dataminer.BonusForPlayers[playerIndex].FireDelay
                Dataminer.BonusForPlayers[playerIndex] = nil
            end
        end
    end
end

---@param item CollectibleType 
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param activeSlot ActiveSlot
function Dataminer:OnUseItem(item, rng, player, useFlags, activeSlot)
    local playerIndex = GetPlayerIndex(player)

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type ~= EntityType.ENTITY_PLAYER then
            entity.SpriteRotation = entity.SpriteRotation + math.random(1, 360)
        end
    end

    if Dataminer.ActiveForPlayers[playerIndex] ~= nil then
        Dataminer.ActiveForPlayers[playerIndex] = Dataminer.ActiveForPlayers[playerIndex] + 1
    else
        Dataminer.ActiveForPlayers[playerIndex] = 1
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
    player:EvaluateItems()

    return true
end

function Dataminer:OnEnd()
    Dataminer.ActiveForPlayers = {} -- Reset the activeness

    for _, player in ipairs(GetPlayers()) do -- Update their cache
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
    end
end

BalanceMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Dataminer.OnCacheUpdate)
BalanceMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Dataminer.OnEnd)

BalanceMod:AddCallback(ModCallbacks.MC_USE_ITEM, Dataminer.OnUseItem, Dataminer.Item)


-- /////////////////// --

-- // Breath of Life // --

local BreathOfLife = {
    Item = Isaac.GetItemIdByName("Breath of Life"),
    IFrames = 50,
    InvinciblePlayers = {},
    ChargeBarPlayers = {}
}

function BreathOfLife:OnUpdate()
    for _, player in ipairs(GetPlayers()) do
        if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == BreathOfLife.Item then
            local playerIndex = GetPlayerIndex(player)
            if player:GetActiveCharge() < 1 then -- they are out of charge on  breath of life, give them iframes
                if BreathOfLife.InvinciblePlayers[playerIndex] == nil then
                    BreathOfLife.InvinciblePlayers[playerIndex] = true

                    player:SetMinDamageCooldown(BreathOfLife.IFrames)
                    local sprite = Sprite()
                    sprite:Load(ChargeBars.DefaultSprite, true)
                    BreathOfLife.ChargeBarPlayers[playerIndex] = ChargeBars:MakeCustomChargeBar(player, sprite, BreathOfLife.IFrames, BreathOfLife.IFrames, -1)
                end
            else -- its either charged or recharging
                if BreathOfLife.ChargeBarPlayers[playerIndex] ~= nil then
                    ChargeBars:DeleteCustomChargeBar(player, BreathOfLife.ChargeBarPlayers[playerIndex])
                end

                BreathOfLife.InvinciblePlayers[playerIndex] = nil
                BreathOfLife.ChargeBarPlayers[playerIndex] = nil
            end
        end
    end
end

BalanceMod:AddCallback(ModCallbacks.MC_POST_UPDATE, BreathOfLife.OnUpdate)

-- /////////////////// --

-- // Callbacks // --



-- /////////////// --
