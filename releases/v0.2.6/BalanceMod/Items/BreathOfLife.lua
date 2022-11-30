local PlayerTracker = require("BalanceMod.Utility.PlayerTracker")
local ChargeBars = require("BalanceMod.Utility.ChargeBars")
local ExtraMath = require("BalanceMod.Utility.ExtraMath")

-- // Breath of Life // --

local BreathOfLife = {
    Item = Isaac.GetItemIdByName("Breath of Life"),
    CooldownBetweenSelfDamage = 60,
    CooldownBetweenCharge = 15,
    CooldownBetweenStrikes = 30,
    MaxCharge = 4,
    TimeBeforeSelfDamage = 20,
    InvinciblePlayers = {},
    ChargeBarPlayers = {},
    VignetteColor = {0.0, 0.4, 1.0}
}

local STRENGTH_AT_MAX_VIGNETTE = 0.2 -- multiplier for the strength of the vignette. 0.3 is pretty strong, 0 is non-existant

---@param player EntityPlayer
---@param collider Entity
function BreathOfLife:PlayerContact(player, collider)
    if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == BreathOfLife.Item then
        if player:GetActiveCharge() < 1 then -- they are out of charge on  breath of life, give them iframes
            if not collider:IsActiveEnemy(false) then return end
            local data = collider:GetData().BreathOfLife
            if data == nil then
                data = {}
                collider:GetData().BreathOfLife = data
            end

            if data.LastStruck == nil or data.LastStruck < Game():GetFrameCount() then
                data.LastStruck = Game():GetFrameCount() + BreathOfLife.CooldownBetweenStrikes
                
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, collider.Position, Vector(0,0), player)
            end
        end
    end
end

function BreathOfLife:Activate()
    return {
        Discharge = false,
        Remove = false,
        ShowAnim = false
    }
end

---@param player EntityPlayer
function BreathOfLife:OnUpdate(player)
    if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == BreathOfLife.Item then
        local playerIndex = PlayerTracker:GetPlayerIndex(player)
        local playerData = player:GetData().BreathOfLife
        if playerData == nil then
            playerData = {
                NextCharge = 0,
                NextDamage = 0,
                AllowedToHold = true
            }
            player:GetData().BreathOfLife = playerData
        end

        local holdingActivate = Input.GetActionValue(ButtonAction.ACTION_ITEM, player.ControllerIndex) == 1

        if holdingActivate then
            if player:GetActiveCharge() >= 1 then
                if not BreathOfLife.InvinciblePlayers[playerIndex] and playerData.NextCharge < Game():GetFrameCount() and playerData.AllowedToHold then
                    playerData.NextCharge = Game():GetFrameCount() + BreathOfLife.CooldownBetweenCharge
                    player:SetActiveCharge(ExtraMath:Clamp(player:GetActiveCharge() - 1, 0, BreathOfLife.MaxCharge))
                end

                playerData.NextDamage = Game():GetFrameCount() + BreathOfLife.TimeBeforeSelfDamage -- consstatly set it so its good for when they let go
            end
            if playerData.NextDamage < Game():GetFrameCount() and player:GetActiveCharge() < 1 then
                playerData.NextDamage = Game():GetFrameCount() + BreathOfLife.TimeBeforeSelfDamage
                local flags = DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_MODIFIERS | DamageFlag.DAMAGE_NO_PENALTIES
                player:ResetDamageCooldown()
                player:TakeDamage(1, flags, EntityRef(player), 0)
            elseif player:GetActiveCharge() < 1 then
                player:SetMinDamageCooldown(10)
            end
        end

        

        if player:GetActiveCharge() < 1 then -- they are out of charge on  breath of life, give them iframes
            if BreathOfLife.InvinciblePlayers[playerIndex] == nil then
                BreathOfLife.InvinciblePlayers[playerIndex] = Game():GetFrameCount() + BreathOfLife.TimeBeforeSelfDamage

                local sprite = Sprite()
                sprite:Load(ChargeBars.DefaultSprite, true)
                local RenderFrames = BreathOfLife.TimeBeforeSelfDamage * 2
                BreathOfLife.ChargeBarPlayers[playerIndex] = ChargeBars:MakeCustomChargeBar(player, sprite, RenderFrames, RenderFrames, -1)
            end
            
            if not holdingActivate then
                playerData.NextCharge = Game():GetFrameCount() + BreathOfLife.CooldownBetweenCharge
                player:SetActiveCharge(ExtraMath:Clamp(player:GetActiveCharge() + 1, 0, BreathOfLife.MaxCharge))
            end
        else -- its either charged or recharging
            if BreathOfLife.ChargeBarPlayers[playerIndex] ~= nil then
                ChargeBars:DeleteCustomChargeBar(player, BreathOfLife.ChargeBarPlayers[playerIndex])
            end

            BreathOfLife.InvinciblePlayers[playerIndex] = nil
            BreathOfLife.ChargeBarPlayers[playerIndex] = nil

            if player:GetActiveCharge() == BreathOfLife.MaxCharge then
                playerData.AllowedToHold = true
            else
                if playerData.NextCharge < Game():GetFrameCount() then
                    playerData.AllowedToHold = false
                    playerData.NextCharge = Game():GetFrameCount() + BreathOfLife.CooldownBetweenCharge
                    player:SetActiveCharge(ExtraMath:Clamp(player:GetActiveCharge() + 1, 0, BreathOfLife.MaxCharge))
                end
            end
        end
    end
end

function BreathOfLife:PostRender(shaderName)
    if shaderName == "Vignette" then
        local lowestMeter
        for playerIndex = 0, Game():GetNumPlayers() - 1 do
            local player = Isaac.GetPlayer(playerIndex)
            if player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == BreathOfLife.Item then
                local timeToDamage = player:GetActiveCharge()


                if lowestMeter == nil or timeToDamage < lowestMeter then
                    lowestMeter = timeToDamage
                end
            end
        end

        if lowestMeter ~= nil then
            local multiplierToGetIdealMaxStrength = STRENGTH_AT_MAX_VIGNETTE / BreathOfLife.MaxCharge
            if lowestMeter == BreathOfLife.MaxCharge then
                return {
                    Enabled = 0,
                    Strength = 0.0,
                    VignetteColor = BreathOfLife.VignetteColor
                }
            else
                return {
                    VignetteColor = BreathOfLife.VignetteColor,
                    Strength = multiplierToGetIdealMaxStrength * math.abs(lowestMeter - BreathOfLife.MaxCharge),
                    Enabled = 1
                }
            end
        else
            return {
                Enabled = 0,
                Strength = 0.0,
                VignetteColor = BreathOfLife.VignetteColor
            }
        end
    end
end
-- /////////////////// --

return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, BreathOfLife.PlayerContact)
    BalanceMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, BreathOfLife.OnUpdate)
    BalanceMod:AddCallback(ModCallbacks.MC_POST_RENDER, BreathOfLife.PostRender)
    BalanceMod:AddCallback(ModCallbacks.MC_USE_ITEM, BreathOfLife.Activate, BreathOfLife.Item)
    BalanceMod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, BreathOfLife.PostRender)
    if EID then
        EID:addCollectible(BreathOfLife.Item, "Isaac becomes invincible while charge is completely depleted#Deplete charge by holding use#{{Warning}} Holding for too long after becoming invincible will deal damage to Isaac#Charge regenerates when not held#{{Collectible160}} Touching enemies while invincible summons a beam of light") 
    end

    return {
        OldItemId = CollectibleType.COLLECTIBLE_BREATH_OF_LIFE,
        NewItemId = BreathOfLife.Item,
    }
end