local PoolHelper = require("BalanceMod.Utility.PoolHelper")

-- // D10 // --

local D10 = {
    Item = Isaac.GetItemIdByName("D10"),
    RerolledEntities = false,
    EnemiesToRemove = {},
    ChampionsToLoot = { --kms
        [ChampionColor.RED] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, PoolHelper.PickupNullIndex, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.YELLOW] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, PoolHelper.PickupNullIndex, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.GREEN] = function (ref, rng)
            ---@type EntityNPC
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, PillColor.PILL_NULL, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.ORANGE] = function (ref, rng)
            local npc = ref.Entity
            for _ = 0, 1 do
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, PoolHelper.PickupNullIndex, npc.Position, Vector(0, 0), npc)
            end
        end,
        [ChampionColor.BLUE] = function (ref, rng, playerRef)
            local npc = ref.Entity
            ---@type EntityPlayer
            local player = playerRef.Entity:ToPlayer() 
            player:AddBlueFlies(3, player.Position, player)
        end,
        [ChampionColor.BLACK] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Explode(npc.Position, npc, 100)
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, PoolHelper.PickupNullIndex, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.WHITE] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ETERNAL, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.GREY] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, PoolHelper.PickupNullIndex, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.TRANSPARENT] = function (ref, rng)
            local npc = ref.Entity
            local megaChestChance = 0.01 -- 1%
            if megaChestChance > rng:RandomFloat() then
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_MEGACHEST, ChestSubType.CHEST_CLOSED, npc.Position, Vector(0, 0), npc)
            else
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LOCKEDCHEST, ChestSubType.CHEST_CLOSED, npc.Position, Vector(0, 0), npc)
            end
        end,
        [ChampionColor.FLICKER] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_REDCHEST, ChestSubType.CHEST_CLOSED, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.PINK] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Game():GetItemPool():GetCard(rng:GetSeed(), true, false, false), npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.PURPLE] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, PoolHelper.PickupNullIndex, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.DARK_RED] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_DOUBLEPACK, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.LIGHT_BLUE] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.CAMO] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Game():GetItemPool():GetCard(rng:GetSeed(), false, true, true), npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.PULSE_GREEN] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, PoolHelper.PickupNullIndex, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.PULSE_GREY] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLENDED, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.FLY_PROTECTED] = function (ref, rng, playerRef)
            local npc = ref.Entity
            ---@type EntityPlayer
            local player = playerRef.Entity:ToPlayer()
            for i = 0, 2 do
                player:AddBlueSpider(player.Position)
            end
        end,
        [ChampionColor.TINY] = function (ref, rng)
            local npc = ref.Entity
            local pool = Game():GetItemPool()
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, pool:ForceAddPillEffect(PillEffect.PILLEFFECT_SMALLER), npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.GIANT] = function (ref, rng)
            local npc = ref.Entity
            local pool = Game():GetItemPool()
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, pool:ForceAddPillEffect(PillEffect.PILLEFFECT_LARGER), npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.PULSE_RED] = function (ref, rng)
            local npc = ref.Entity
            Game():SpawnParticles(npc.Position, EffectVariant.PLAYER_CREEP_RED, 10, 0, Color(1, 0, 0, 1, 0, 0, 0), 0)
        end,
        [ChampionColor.SIZE_PULSE] = function (ref, rng, playerRef)
            local npc = ref.Entity
            local player = playerRef.Entity:ToPlayer()
            for i = 0, 1 do
                Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, LocustSubtypes.LOCUST_OF_WRATH, player.Position, Vector(0, 0), player)
            end
        end,
        [ChampionColor.KING] = function (ref, rng)
            local npc = ref.Entity
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_DIME, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.DEATH] = function (ref, rng)
            local npc = ref.Entity
           Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, npc.Position, Vector(0, 0), npc)
        end,
        [ChampionColor.BROWN] = function (ref, rng)
            local npc = ref.Entity
            Game():Fart(npc.Position)
        end,
        [ChampionColor.RAINBOW] = function (ref, rng)
            local npc = ref.Entity
            local game = Game()
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, game:GetItemPool():GetCollectible(ItemPoolType.POOL_SHOP, true, rng:GetSeed()), npc.Position, Vector(0, 0), npc)
        end
    }
}

---@param player EntityPlayer
function D10:OnUse(_, rng, player)
    local entities = Isaac.GetRoomEntities()
    for _, entity in ipairs(entities) do
        local npc = entity:ToNPC()
        if npc then
            if npc:CanReroll() and npc:IsEnemy() and npc:IsChampion() then
                local championColor = npc:GetChampionColorIdx()
                D10.ChampionsToLoot[championColor](EntityRef(npc), rng, EntityRef(player))
                Game():RerollEnemy(entity)

                D10.RerolledEntities = true
            end
        end
    end

    return true
end

function D10:OnRoomLeft()
    D10.RerolledEntities = false
    D10.EnemiesToRemove = {}
end

function D10:GameUpdate() -- on game update
    if D10.RerolledEntities then
        local entities = Isaac.GetRoomEntities()
        for _, entity in ipairs(entities) do
            local npc = entity:ToNPC()
            if npc then
                if npc:IsEnemy() and npc:IsChampion() then
                    npc:Remove()

                    local ent = Isaac.Spawn(npc.Type, npc.Variant, npc.SubType, npc.Position, Vector(0, 0), npc)
                
                    if npc:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
                        ent:AddConfusion(EntityRef(npc), 60, true)
                    end
                end
            end
        end

        D10.RerolledEntities = false
    end
end

-- /////////////////// --

BalanceMod:AddCallback(ModCallbacks.MC_USE_ITEM, D10.OnUse, D10.Item)
BalanceMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, D10.OnRoomLeft)
BalanceMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, D10.OnRoomLeft)
BalanceMod:AddCallback(ModCallbacks.MC_POST_UPDATE, D10.GameUpdate)
BalanceMod:AddCallback(ModCallbacks.MC_POST_GAME_END, D10.OnRoomLeft)

if EID then
    EID:addCollectible(D10.Item, "Rerolls champions on use#Rerolled champions will become non-champions#Rerolled champions will drop special loot based on their color")
end

return {
    OldItemId = CollectibleType.COLLECTIBLE_D10,
    NewItemId = D10.Item,
}