-- // Perfection // --

local guide = "#Drops a tier when Isaac takes non-self damage#Luck increase changes depending on the tier"

local Perfection = {
    Trinkets = {
        Perfection = Isaac.GetTrinketIdByName("Perfection"),
        Excellence = Isaac.GetTrinketIdByName("Excellence"),
        Mediocrity = Isaac.GetTrinketIdByName("Mediocrity"),
        Incompetence = Isaac.GetTrinketIdByName("Incompetence"),
        Failure = Isaac.GetTrinketIdByName("Failure"),
    },
}

local TrinketHelper = BalanceMod.TrinketHelper

Perfection.Tiers = {
    [5] = Perfection.Trinkets.Perfection,
    [3] = Perfection.Trinkets.Excellence,
    [1] = Perfection.Trinkets.Mediocrity
}

Perfection.SelfDamageFlags = {
    DamageFlag.DAMAGE_DEVIL,
    DamageFlag.DAMAGE_IV_BAG,
    DamageFlag.DAMAGE_CURSED_DOOR,
    DamageFlag.DAMAGE_IV_BAG,
    DamageFlag.DAMAGE_FAKE,
    DamageFlag.DAMAGE_CHEST,
    DamageFlag.DAMAGE_NO_PENALTIES
}

local function GetTrinketTier(trinket)
    for tier, id in pairs(Perfection.Tiers) do
        if id == trinket then
            return tier
        end
    end
end

local function WasSelfDamage(flags)
    local blacklisted = false
    for _, flag in pairs(Perfection.SelfDamageFlags) do
        if flags & flag == flag then
            blacklisted = true
            break
        end
    end

    return blacklisted
end

local function DropTrinket(playerRef, trinketType)
    local player = playerRef.Entity:ToPlayer()
    player:TryRemoveTrinket(trinketType)
    local velocityX = math.random(-10, 10)
    local velocityY = math.random(-10, 10)
    local trinket = TrinketHelper:SpawnTrinket(trinketType, player.Position, Vector(velocityX, velocityY))
    trinket = trinket:ToPickup()
    trinket.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    trinket.Timeout = 30
    trinket.Wait = 120
end


function Perfection:UpdateCache(player)
    local slotOne, slotTwo = player:GetTrinket(0), player:GetTrinket(1)
    local tier = GetTrinketTier(slotOne) or GetTrinketTier(slotTwo)
    if tier then
        player.Luck = player.Luck + (2 * tier)
    end
end

---@param entity Entity
function Perfection:TakeDamage(entity, amount, flags)
    local player = entity:ToPlayer()
    if player then

        if WasSelfDamage(flags) then
            return
        end

        local tier
        for _, trinket in pairs(Perfection.Trinkets) do
            if player:HasTrinket(trinket) then
                tier = GetTrinketTier(trinket)
                break
            end
        end

        if tier then
            SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN)
            DropTrinket(EntityRef(player), Perfection.Tiers[tier])
            
            local nextTier = Perfection.Tiers[tier - 2]
            if nextTier then
                player:AddTrinket(nextTier, true)
            end
        end
    end
end

---@param entity EntityPickup
function Perfection:PickupSpawned(entity)
    if entity.SubType == TrinketType.TRINKET_PERFECTION then
        entity:GetData().SpawnedByBalanceMod = true
        entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, Perfection.Trinkets.Perfection, true)
    end
end

function Perfection:RunStart()
    local pool = Game():GetItemPool()
    for _, trinket in pairs(Perfection.Trinkets) do
        pool:RemoveTrinket(trinket)
    end
end

TrinketHelper:AddShouldRemoveCallback(Perfection.Trinkets.Perfection, function (trinket)
    -- make sure it was spawned by a boss
    local perfectionDropped = Game():GetStateFlag(GameStateFlag.STATE_PERFECTION_SPAWNED)
    return not (perfectionDropped and (trinket.SpawnerEntity and trinket.SpawnerEntity.Type ~= EntityType.ENTITY_PLAYER))
end)

TrinketHelper:RemoveOnSpawn(Perfection.Trinkets.Excellence)
TrinketHelper:RemoveOnSpawn(Perfection.Trinkets.Mediocrity)
TrinketHelper:RemoveOnSpawn(Perfection.Trinkets.Incompetence)
TrinketHelper:RemoveOnSpawn(Perfection.Trinkets.Failure)

-- /////////////////// --

if not EID then return end

BalanceMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Perfection.UpdateCache, CacheFlag.CACHE_LUCK)
BalanceMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Perfection.TakeDamage, EntityType.ENTITY_PLAYER)
BalanceMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, Perfection.PickupSpawned, PickupVariant.PICKUP_TRINKET)
BalanceMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Perfection.RunStart)

EID:addTrinket(Perfection.Trinkets.Perfection, "{{ArrowUp}} +10 Luck" .. guide)
EID:addTrinket(Perfection.Trinkets.Excellence, "{{ArrowUp}} +8 Luck" .. guide)
EID:addTrinket(Perfection.Trinkets.Mediocrity, "{{ArrowUp}} +6 Luck" .. guide)
EID:addTrinket(Perfection.Trinkets.Incompetence, "{{ArrowUp}} +4 Luck" .. guide)
EID:addTrinket(Perfection.Trinkets.Failure, "{{ArrowUp}} +2 Luck" .. guide)