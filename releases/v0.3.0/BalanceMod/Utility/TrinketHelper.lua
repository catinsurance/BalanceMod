-- after a trinket pool is exhausted, it pulls trinkets it is not supposed to
-- this is a workaround to prevent that

local Exhaustion = {}

local removedTrinkets = {}
local callbacks = {}

local function findInTable(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

-- Spawns a trinket. Use this instead of Isaac.Spawn if you don't want the trinket to be rerolled upon spawn
---@param trinketId integer
---@param position Vector
---@param velocity Vector
function Exhaustion:SpawnTrinket(trinketId, position, velocity)
    local trinket = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, trinketId, position, velocity, Isaac.GetPlayer(0)) -- it doesn't matter what player
    trinket:GetData().SpawnedByBalanceMod = true
    return trinket
end

function Exhaustion:RemoveOnSpawn(trinketId)
    table.insert(removedTrinkets, trinketId)
    table.insert(removedTrinkets, trinketId + TrinketType.TRINKET_GOLDEN_FLAG)
end

function Exhaustion:AddShouldRemoveCallback(trinketId, func)
    callbacks[trinketId] = func
end

---@param pickup EntityPickup
function Exhaustion:OnTrinketInit(pickup)
    local trinketShouldBeRemoved = findInTable(removedTrinkets, pickup.SubType)

    if callbacks[pickup.SubType] then
        trinketShouldBeRemoved = callbacks[pickup.SubType](pickup)
    end

    if trinketShouldBeRemoved and not pickup:GetData().SpawnedByBalanceMod then
        pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, true, true, false)
        Exhaustion:OnTrinketInit(pickup)
    end
end

function Exhaustion:OnGameStart()
    for _, thing in ipairs(Isaac.GetRoomEntities()) do
        if thing.Type == EntityType.ENTITY_PICKUP and thing.Variant == PickupVariant.PICKUP_TRINKET then
            ---@diagnostic disable-next-line: param-type-mismatch
            Exhaustion:OnTrinketInit(thing)
        end
    end
end

BalanceMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, Exhaustion.OnTrinketInit, PickupVariant.PICKUP_TRINKET)
BalanceMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Exhaustion.OnGameStart)
BalanceMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Exhaustion.OnGameStart)

return Exhaustion