local VectorZero = Vector(0, 0)
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

    print(ChargeBarData[playerIndex][index].Charge)

    return index
end

function ChargeBar:UpdateCustomBarState(player, barId, state) -- setting state overwrites the charge, but not the max charge
    local playerIndex = GetPlayerIndex(player)
    local playerData = ChargeBarData[playerIndex]
    
    if not playerData then
        return
    end

    local bar = playerData[barId]

    if bar == nil then
        return
    end

    bar.State = Clamp(state, ChargeBarState.Normal, ChargeBarState.Charged)
    bar.Charge = 0
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
    elseif ChargeBarData[playerIndex][barId].State == ChargeBarState.Charged then
        ChargeBarData[playerIndex][barId].Charge = Clamp( ChargeBarData[playerIndex][barId].Charge, 1, ChargeBarChargedFrameCount)
    elseif ChargeBarData[playerIndex][barId].State == ChargeBarState.Deleting then
        ChargeBarData[playerIndex][barId].Charge = Clamp( ChargeBarData[playerIndex][barId].Charge, 1, ChargeBarDeleteFrameCount)
    end

    local bar = ChargeBarData[playerIndex][barId]    

    --rendering stuff now
    
    local flyingOffset = player:GetFlyingOffset()

    local sizeOffset = player.SpriteScale * ChargeBarOffset

    local overlapOffset = ChargeBarOverlapOffset * (bar.Index - 1) -- move the bar depending on how where it is in the array

    local adjustedPosition = player.Position + overlapOffset + flyingOffset + sizeOffset

    -- now actually draw the bar
    local frameAmountPerCharge = ChargeBarFrameCount / bar.MaxCharge
    local frame
    
    if bar.State == ChargeBarState.Normal then
        frame = Clamp(Round(bar.Charge * frameAmountPerCharge), 1, ChargeBarFrameCount)
        bar.Sprite:SetFrame("Charging", frame)
    elseif bar.State == ChargeBarState.Deleting then
        frame = Clamp(bar.Charge + 1, 1, ChargeBarDeleteFrameCount)
        bar.Sprite:SetFrame("Disappear", frame)
    elseif bar.State == ChargeBarState.ChargedAnimDone then
        frame = Clamp(bar.Charge + 1, 1, ChargeBarChargedFrameCount)
        bar.Sprite:SetFrame("Charged", frame)
    elseif bar.State == ChargeBarState.ChargedStart then
        frame = Clamp(bar.Charge + 1, 1, ChargeBarStartChargedFrameCount)
        bar.Sprite:SetFrame("StartCharged", frame)
    end
    
    local finalPosition = Game():GetRoom():WorldToScreenPosition(adjustedPosition)
    bar.Sprite:Render(finalPosition, VectorZero, VectorZero)

    if bar.State == ChargeBarState.Deleting then
        if bar.Charge >= ChargeBarDeleteFrameCount then
            local playerIndex = GetPlayerIndex(player)
            if ChargeBarData[playerIndex] == nil then
                ChargeBarData[playerIndex] = {}
            end

            ChargeBarData[playerIndex][barId] = nil
        end
    end
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
    ChargeBar:UpdateCustomBarState(player, index, ChargeBar.ChargeBarState.Deleting)
end

-- //////////////////// --

return ChargeBar