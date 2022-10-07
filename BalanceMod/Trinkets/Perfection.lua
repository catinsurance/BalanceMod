-- // Perfection // --

local guide = "#Drops a tier when Isaac takes non-self damage#Tier 5 (Perfection): +10 Luck)#Tier 4 (Excellence): +8 Luck#Tier 3 (Mediocrity): +6 Luck#Tier 2 (Incompetence): +4 Luck#Tier 1 (Failure): +2 Luck"

local Perfection = {
    Trinkets = {
        Perfection = Isaac.GetTrinketIdByName("Perfection"),
        Excellence = Isaac.GetTrinketIdByName("Excellence"),
        Mediocrity = Isaac.GetTrinketIdByName("Mediocrity"),
        Incompetence = Isaac.GetTrinketIdByName("Incompetence"),
        Failure = Isaac.GetTrinketIdByName("Failure"),
    },
}

Perfection.Tiers = {
    [5] = Perfection.Trinkets.Perfection,
    [4] = Perfection.Trinkets.Excellence,
    [3] = Perfection.Trinkets.Mediocrity,
    [2] = Perfection.Trinkets.Incompetence,
    [1] = Perfection.Trinkets.Failure,
}

local function GetTrinketTier(trinket)
    for tier, id in pairs(Perfection.Tiers) do
        if id == trinket then
            return tier
        end
    end
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
        local slotOne, slotTwo = player:GetTrinket(0), player:GetTrinket(1)
        local tier = GetTrinketTier(slotOne) or GetTrinketTier(slotTwo)
        if tier then
            local nextTier = Perfection.Tiers[tier - 1]
            player:TryRemoveTrinket(Perfection.Tiers[tier])
            if nextTier then
                player:AddTrinket(nextTier)
            end
        end
    end
end

function Perfection:RunStart()
    local pool = Game():GetItemPool()
    for _, trinket in pairs(Perfection.Trinkets) do
        pool:RemoveTrinket(trinket)
    end
end

-- /////////////////// --

return function (BalanceMod)
    if not EID then return end

    BalanceMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Perfection.UpdateCache, CacheFlag.CACHE_LUCK)
    BalanceMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Perfection.TakeDamage, EntityType.ENTITY_PLAYER)
    BalanceMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Perfection.RunStart)

    EID:addTrinket(Perfection.Trinkets.Perfection, "{{ArrowUp}} +10 Luck" .. guide)
    EID:addTrinket(Perfection.Trinkets.Excellence, "{{ArrowUp}} +8 Luck" .. guide)
    EID:addTrinket(Perfection.Trinkets.Mediocrity, "{{ArrowUp}} +6 Luck" .. guide)
    EID:addTrinket(Perfection.Trinkets.Incompetence, "{{ArrowUp}} +4 Luck" .. guide)
    EID:addTrinket(Perfection.Trinkets.Failure, "{{ArrowUp}} +2 Luck" .. guide)
end