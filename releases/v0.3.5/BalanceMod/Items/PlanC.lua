local PlayerTracker = require("BalanceMod.Utility.PlayerTracker")

-- // Plan C // --

local PlanC = {
    Item = Isaac.GetItemIdByName("Plan C"),
    FloodedFlag = (1 << 8) -- i couldnt figure out how to get this from the game
}

function PlanC:NewRoom()
    local save = BalanceMod.GetRunPersistentSave()

    if not save then
        return
    end

    local playersToKill = save.PlanC

    if playersToKill == nil then
        return -- no players to kill
    end

    for _, player in ipairs(PlayerTracker:GetPlayers()) do
        local playerIndex = PlayerTracker:GetPlayerIndex(player)
        if playersToKill[playerIndex] ~= nil then
           player:Kill()
           playersToKill[playerIndex] = nil

            save.PlanC = playersToKill
        end
    end
end

function PlanC:OnUse(_, _, player)
    local roomHadEnemies = false
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:IsEnemy() then
            roomHadEnemies = true
            entity:BloodExplode()
            entity:TakeDamage(9999999, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(entity), 0)
        end
    end

    if roomHadEnemies then
        
        Game():GetRoom():EmitBloodFromWalls(30, 10)

        if PlanC.PlayersToKill == nil then
            PlanC.PlayersToKill = {}
        end

        PlanC.PlayersToKill[PlayerTracker:GetPlayerIndex(player)] = true
        BalanceMod.GetRunPersistentSave().PlanC = PlanC.PlayersToKill

        return {
            Remove = true,
            ShowAnim = true
        }
    end
end

function PlanC:OnRunEnd()
    PlanC.PlayersToKill = nil
end

-- /////////////////// --

BalanceMod:AddCallback(ModCallbacks.MC_USE_ITEM, PlanC.OnUse, PlanC.Item)
BalanceMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PlanC.NewRoom)
if EID then
    EID:addCollectible(PlanC.Item, "Kills all enemies in the room#Kills the player upon entering the next room#Consumed on use")

end

return {
    OldItemId = CollectibleType.COLLECTIBLE_PLAN_C,
    NewItemId = PlanC.Item,
}