local VectorZero = Vector(0, 0)
local game = Game()

local ChargeBar = {}
local ChargeBarData = {}

local ChargeBarOffset = Vector(-19, -54)
local ChargeBarOverlapOffset = Vector(-20, 0)
local ChargeBarFrameCount = 101
local ChargeBarDeleteFrameCount = 9
local ChargeBarChargedFrameCount = 6
local ChargeBarStartChargedFrameCount = 12
local ChargeBarState = {
    Normal = 0,
    Deleting = 1,
    ChargedStart = 2,
    ChargedAnimDone = 3
}

-- // Constants // --

ChargeBar.DefaultSprite = "gfx/chargebar.anm2"
ChargeBar.ChargeBarOffset = ChargeBarOffset
ChargeBar.ChargeBarOverlapOffset = ChargeBarOverlapOffset
ChargeBar.ChargeBarFrameCount = ChargeBarFrameCount
ChargeBar.ChargeBarDeleteFrameCount = ChargeBarDeleteFrameCount
ChargeBar.ChargeBarChargedFrameCount = ChargeBarChargedFrameCount
ChargeBar.ChargeBarStartChargedFrameCount = ChargeBarStartChargedFrameCount
ChargeBar.ChargeBarState = ChargeBarState

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

-- // Main // --

---@param sprite Sprite
function ChargeBar:MakeCustomChargeBar(player, sprite, charge, maxCharge, incrementValue) -- returns index of charge bar in the player's ChargeBarData ~ increment value is how much the charge goes up per frame
    local playerIndex = GetPlayerIndex(player)

    if ChargeBarData[playerIndex] == nil then
        ChargeBarData[playerIndex] = {}
    end

    local index = GetTableLength(ChargeBarData[playerIndex]) + 1

    ChargeBarData[playerIndex][index] = {
        Index = index,
        State = ChargeBarState.Normal,
        Sprite = sprite,
        Charge = charge,
        MaxCharge = maxCharge,
        IncrementValue = incrementValue
    }

    return index
end

function ChargeBar:UpdateCustomBarState(player, barId, state)
    local playerIndex = GetPlayerIndex(player)
    local playerData = ChargeBarData[playerIndex]
    
    if not playerData then
        return
    end

    if playerData[barId] == nil then
        return
    end

    playerData[barId].State = Clamp(state, ChargeBarState.Normal, ChargeBarState.ChargedAnimDone)

    if state == ChargeBarState.Deleting then
        playerData[barId].Sprite:Play("Disappear", true)
    elseif state == ChargeBarState.ChargedStart then
        playerData[barId].Sprite:Play("StartCharged", true)
    elseif state == ChargeBarState.ChargedAnimDone then
        playerData[barId].Sprite:Play("Charged", true)
    elseif state == ChargeBarState.Normal then
        playerData[barId].Sprite:Play("Charging", true)
    end
end

function ChargeBar:GetCustomChargeBarCharge(player, barId)
    local playerIndex = GetPlayerIndex(player)
    local playerData = ChargeBarData[playerIndex]
    
    if not playerData then
        return nil
    end

    local bar = playerData[barId]

    if bar == nil then
        return nil
    end

    return bar.Charge, bar.MaxCharge, bar.IncrementValue
end

---@param player EntityPlayer
function ChargeBar:UpdateCustomChargeBar(player, barId) -- draws and increments charge bar
    local playerIndex = GetPlayerIndex(player)
    
    if ChargeBarData[playerIndex] == nil then
        ChargeBarData[playerIndex] = {}
    end

    if ChargeBarData[playerIndex][barId] == nil then
        return -- it doesnt exist
    end

    -- update bar 

    -- increment charge depending on what state we are in
    if ChargeBarData[playerIndex][barId].State == ChargeBarState.Normal then
        ChargeBarData[playerIndex][barId].Charge = Clamp(ChargeBarData[playerIndex][barId].Charge + ChargeBarData[playerIndex][barId].IncrementValue, 1, ChargeBarData[playerIndex][barId].MaxCharge)
    end

    local bar = ChargeBarData[playerIndex][barId]    

    if bar.State == ChargeBarState.Deleting then
        if bar.Sprite:IsFinished("Disappear") then
            ChargeBarData[playerIndex][barId] = nil
            bar = nil
            return
        end
    end

    --rendering stuff now
    
    local flyingOffset = player:GetFlyingOffset()

    local sizeOffset = player.SpriteScale * ChargeBarOffset

    local overlapOffset = ChargeBarOverlapOffset * (bar.Index - 1) -- move the bar depending on how where it is in the array

    local adjustedPosition = player.Position + overlapOffset + flyingOffset + sizeOffset

    -- now actually draw the bar
    
    if bar.State == ChargeBarState.Normal then
        local frameAmountPerCharge = ChargeBarFrameCount / bar.MaxCharge
        local frame = Clamp(Round(bar.Charge * frameAmountPerCharge), 1, ChargeBarFrameCount)
        bar.Sprite:SetFrame("Charging", frame)
    else
        if game:GetFrameCount() % 2 == 0 then
            bar.Sprite:Update()
        end
    end
    
    local finalPosition = game:GetRoom():WorldToScreenPosition(adjustedPosition)
    bar.Sprite:Render(finalPosition, VectorZero, VectorZero)

end

function ChargeBar:UpdateAllCustomChargeBars()
    for _, player in ipairs(GetPlayers()) do
        local playerIndex = GetPlayerIndex(player)
        local playerData = ChargeBarData[playerIndex]

        if playerData == nil then
            ChargeBarData[playerIndex] = {}
            playerData = {}
        end

        for _, bar in pairs(playerData) do
            ChargeBar:UpdateCustomChargeBar(player, bar.Index)
        end
    end
end

---@param player EntityPlayer
function ChargeBar:UpdateChargeBarsForPlayer(player)
    local playerIndex = GetPlayerIndex(player)
    local playerData = ChargeBarData[playerIndex]

    if playerData == nil then
        ChargeBarData[playerIndex] = {}
        playerData = {}
    end

    for _, bar in pairs(playerData) do
        ChargeBar:UpdateCustomChargeBar(player, bar.Index)
    end
end

function ChargeBar:DeleteCustomChargeBar(player, index)
    ChargeBar:UpdateCustomBarState(player, index, ChargeBarState.Deleting)
end

-- //////////////////// --

return ChargeBar