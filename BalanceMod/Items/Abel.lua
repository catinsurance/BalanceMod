-- // Abel // --

local Abel = {
    Item = Isaac.GetItemIdByName("Abel"),
    Familiar = Isaac.GetEntityVariantByName("Abel"),
    FireDelay = 10, -- every x frames
    Damage = 3.5,
    CainDamage = 7.5,
    MaxDistance = 100,
    EnemyTargetFlags = 2 | 1,
    FrameInterval = 13,
    DirectionOpposites = {
        [Direction.DOWN] = Direction.UP,
        [Direction.UP] = Direction.DOWN,
        [Direction.LEFT] = Direction.RIGHT,
        [Direction.RIGHT] = Direction.LEFT
    },
    ChestPickup = {
        [PickupVariant.PICKUP_CHEST] = true,
        [PickupVariant.PICKUP_REDCHEST] = true,
        [PickupVariant.PICKUP_SPIKEDCHEST] = true,
        [PickupVariant.PICKUP_MIMICCHEST] = true,
        [PickupVariant.PICKUP_WOODENCHEST] = true,
        [PickupVariant.PICKUP_OLDCHEST] = true,
    },
    ValidPickup = {
        [PickupVariant.PICKUP_COIN] = true,
        [PickupVariant.PICKUP_KEY] = true,
        [PickupVariant.PICKUP_BOMB] = true,
        [PickupVariant.PICKUP_PILL] = true,
        [PickupVariant.PICKUP_TRINKET] = true,
        [PickupVariant.PICKUP_TAROTCARD] = true,
    },
    HeartsToChecks = {
        [HeartSubType.HEART_BLACK] = function (player)
            return player:CanPickSoulHearts()
        end,
        [HeartSubType.HEART_DOUBLEPACK] = function (player)
            return player:CanPickRedHearts()
        end,
        [HeartSubType.HEART_FULL] = function (player)
            return player:CanPickRedHearts()
        end,
        [HeartSubType.HEART_HALF] = function (player)
            return player:CanPickRedHearts()
        end,
        [HeartSubType.HEART_SCARED] = function (player)
            return player:CanPickRedHearts()
        end,
        [HeartSubType.HEART_SOUL] = function (player)
            return player:CanPickSoulHearts()
        end,
        [HeartSubType.HEART_ETERNAL] = function (player)
            return true
        end,
        [HeartSubType.HEART_BLENDED] = function (player)
            return player:CanPickRedHearts() or player:CanPickSoulHearts()
        end,
        [HeartSubType.HEART_BONE] = function (player)
            return player:CanPickBoneHearts()
        end,
        [HeartSubType.HEART_ROTTEN] = function (player)
            return player:CanPickRottenHearts()
        end,
        [HeartSubType.HEART_GOLDEN] = function (player)
            return player:CanPickGoldenHearts()
        end
    }
}

---@param familiar EntityFamiliar
function Abel:OnUpdate(familiar)
    local player = familiar.Player
    local room = Game():GetRoom()
    local topLeft = room:GetTopLeftPos()
    local bottomRight = room:GetBottomRightPos()
    
    local center = Vector((topLeft.X + bottomRight.X) / 2, (topLeft.Y + bottomRight.Y) / 2)
    local positionRelative = (player.Position - center)
    
    familiar.Position = center - positionRelative
    familiar.Velocity = Vector.Zero

    -- look for pickups to pick up
    local pickups = Isaac.FindInRadius(familiar.Position, 5, EntityPartition.PICKUP)
    if #pickups > 0 then
        for _, pickupEntity in ipairs(pickups) do
            if pickupEntity.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then
                local pickup = pickupEntity:ToPickup()
                
                if Abel.ChestPickup[pickup.Variant] then
                    pickup:PlayPickupSound()
                    pickup:TryOpenChest(player)
                elseif Abel.ValidPickup[pickup.Variant] then
                    pickup:PlayPickupSound()
                    pickup.Position = player.Position
                elseif pickup.Variant == PickupVariant.PICKUP_GRAB_BAG then
                    pickup:PlayPickupSound()
                    pickup:TryOpenChest(player)
                    pickup:Remove()
                elseif pickup.Variant == PickupVariant.PICKUP_HEART then
                    if Abel.HeartsToChecks[pickup.SubType](player) then
                        pickup:PlayPickupSound()
                        pickup.Position = player.Position
                    end
                elseif pickup.Variant == PickupVariant.PICKUP_LIL_BATTERY then
                    if player:NeedsCharge() then
                        pickup:PlayPickupSound()
                        pickup.Position = player.Position
                    end
                end
            end
        end
    end

    if familiar.FrameCount % Abel.FireDelay == 0 then
        local enemiesInRange = Isaac.FindInRadius(familiar.Position, Abel.MaxDistance, EntityPartition.ENEMY)
        
        if #enemiesInRange > 0 then
            local lowestDistance = Abel.MaxDistance
            local closestEnemy = nil

            for _, enemy in ipairs(enemiesInRange) do
                if enemy:IsVulnerableEnemy() then
                    local distance = (enemy.Position - familiar.Position):Length()
                    if distance < lowestDistance then
                        lowestDistance = distance
                        closestEnemy = enemy
                    end
                end
            end

            if not closestEnemy then
                return
            end

            local directionToFire = (closestEnemy.Position - familiar.Position):Normalized()
            local enemyRelativeToFamiliar = familiar.Position - closestEnemy.Position
            local tear = familiar:FireProjectile(directionToFire):ToTear()

            local isCain = (player:GetPlayerType() == PlayerType.PLAYER_CAIN_B or player:GetPlayerType() == PlayerType.PLAYER_CAIN)

            if isCain then
                tear:ChangeVariant(TearVariant.BLOOD)
            end

            local direction = Direction.NO_DIRECTION
            if enemyRelativeToFamiliar.X > 50 then
                direction = Direction.LEFT
            elseif enemyRelativeToFamiliar.X < -50 then
                direction = Direction.RIGHT
            elseif directionToFire.Y < 0 then
                direction = Direction.UP
            elseif directionToFire.Y > 0 then
                direction = Direction.DOWN
            end

            familiar:PlayShootAnim(direction)

            tear.CollisionDamage = isCain and Abel.CainDamage or Abel.Damage
            tear.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            tear.Velocity = directionToFire * 10
        else -- no enemies in range
            familiar:PlayFloatAnim(Abel.DirectionOpposites[player:GetHeadDirection()])
        end
    end
end

---@param player EntityPlayer
function Abel:OnCacheUpdate(player, cacheFlag)
    if cacheFlag == CacheFlag.CACHE_FAMILIARS then
        player:CheckFamiliar(Abel.Familiar, player:GetCollectibleNum(Abel.Item) + player:GetEffects():GetCollectibleEffectNum(Abel.Item), RNG(), Isaac.GetItemConfig():GetCollectible(Abel.Item))
    end  
end

-- /////////////////// --

return function (BalanceMod, eid)
    BalanceMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, Abel.OnUpdate, Abel.Familiar)
    BalanceMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Abel.OnCacheUpdate)
end