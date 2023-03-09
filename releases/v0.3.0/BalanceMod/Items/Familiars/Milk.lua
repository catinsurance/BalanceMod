local PlayerTracker = include("BalanceMod.Utility.PlayerTracker")

-- // Abel // --

local Milk = {
    Item = Isaac.GetItemIdByName("Milk!"),
    Familiar = Isaac.GetEntityVariantByName("Milk! Familiar"),
    Creep = 549364164,
    DropEvent = "Drop",
    BonusFireRateInCreep = 6,
    CreepSize = 80,
}

Milk.FamiliarStatus = {
    MilkFollowing = 0,
    MilkDropping = 1,
    MilkDropped = 2,
    MilkDroppingStart = 3,
}

local function RealignFamiliars()
    local caboose
    ---@param entity EntityFamiliar
    for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR)) do
        if entity.Child == nil and entity.IsFollower then
            if caboose == nil then
                caboose = entity
            else
                if caboose.FrameCount < entity.FrameCount then
                    caboose.Parent = entity
                    entity.Child = caboose
                else
                    caboose.Child = entity
                    entity.Parent = caboose
                end
            end
        end
    end
end

---@param effect EntityEffect
function Milk:EffectUpdate(effect)
    if effect.SubType ~= Milk.Creep then return end
    
    local players = PlayerTracker:GetPlayers()
    effect:GetSprite():Play("BiggestBlood02", true)
    effect.Timeout = 10 
    effect.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    
    ---@param player EntityPlayer
    for _, player in ipairs(players) do
        if player.Position:Distance(effect.Position) <= Milk.CreepSize then
            local data = player:GetData().MilkStatus

            if data then
                if not data.HasBuff then
                    data.HasBuff = true
                    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                    player:EvaluateItems()
                end
            end

            
        else 

            local data = player:GetData().MilkStatus

            if data then
                if data.HasBuff then
                    data.HasBuff = false
                    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                    player:EvaluateItems()
                end
            end

        end
    end
end

---@param familiar EntityFamiliar
function Milk:FamiliarUpdate(familiar)
    local sprite = familiar:GetSprite()
    local player = familiar.Player
    local data = player:GetData().MilkStatus

    if not data then
        player:GetData().MilkStatus = {
            Status = Milk.FamiliarStatus.MilkFollowing,
            HasBuff = false,
        }
        data = player:GetData().MilkStatus
    end

    if data.Status == Milk.FamiliarStatus.MilkFollowing then
        familiar:FollowParent()
        familiar.Visible = true
        sprite:Play("Idle")
    end

    if data.Status == Milk.FamiliarStatus.MilkDroppingStart then
        data.Status = Milk.FamiliarStatus.MilkDropping
        familiar:FollowPosition(familiar.Position)
        sprite:Play("Drop")
    end

    if sprite:IsEventTriggered(Milk.DropEvent) then
        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, Milk.Creep, familiar.Position, Vector(0, 0), familiar)
        SFXManager():Play(SoundEffect.SOUND_GLASS_BREAK)
    end

    if sprite:IsFinished("Drop") then
        familiar.Visible = false
        data.Status = Milk.FamiliarStatus.MilkDropped
    end
end

---@param entity Entity
function Milk:EntityDamage(entity, _, _, sourceRef)
    local source = sourceRef.Entity
    if source and source.Type == EntityType.ENTITY_EFFECT and source.Variant == EffectVariant.PLAYER_CREEP_RED then
        if source.SubType == Milk.Creep then
            return false
        end
    end

    local player = entity:ToPlayer()
    if player then
        if player:HasCollectible(Milk.Item) then
            local data = player:GetData().MilkStatus
            if not data then
                player:GetData().MilkStatus = {
                    Status = Milk.FamiliarStatus.MilkFollowing,
                    HasBuff = false,
                }
                data = player:GetData().MilkStatus
            end

            if data.Status == Milk.FamiliarStatus.MilkFollowing then
                data.Status = Milk.FamiliarStatus.MilkDroppingStart
            end
        end
    end
end

local function Clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    else
        return value
    end
end

---@param player EntityPlayer
function Milk:CacheUpdate(player, cacheFlag)
    if cacheFlag == CacheFlag.CACHE_FAMILIARS then
        local count = player:GetCollectibleNum(Milk.Item) + player:GetEffects():GetCollectibleEffectNum(Milk.Item)
        player:CheckFamiliar(Milk.Familiar, Clamp(count, 0, 1), RNG(), Isaac.GetItemConfig():GetCollectible(Milk.Item))
        RealignFamiliars()
    end

    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
        local data = player:GetData().MilkStatus
        if data then
            if data.HasBuff then
                player.MaxFireDelay = math.max(player.MaxFireDelay - Milk.BonusFireRateInCreep, 0.2)
            end
        end
    end
end

function Milk:Cleanup()
    for _, player in ipairs(PlayerTracker:GetPlayers()) do
        local data = player:GetData().MilkStatus
        if data then
            if data.HasBuff then
                data.HasBuff = false
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                player:EvaluateItems()
            end

            data.Status = Milk.FamiliarStatus.MilkFollowing
            RealignFamiliars()
        end
    end
end

BalanceMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Milk.FamiliarUpdate, Milk.Familiar)
BalanceMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, Milk.EntityDamage)
BalanceMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, Milk.EffectUpdate, EffectVariant.PLAYER_CREEP_RED)
BalanceMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Milk.CacheUpdate)
BalanceMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Milk.Cleanup)
BalanceMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Milk.Cleanup)
BalanceMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, Milk.Cleanup)

if EID then
    EID:addCollectible(Milk.Item, "#Gives Isaac a familiar that drops milk when he takes damage for the first time in a room#Standing in the milk increases fire rate by +6")
end

return {
    OldItemId = CollectibleType.COLLECTIBLE_MILK,
    NewItemId = Milk.Item,
}