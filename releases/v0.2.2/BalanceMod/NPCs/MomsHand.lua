-- // Mom's Hand // --

local MomsHand = {
    Enemy = Isaac.GetEntityTypeByName("Mom's Hand"),
    WasTouched = false,
    RoomTarget = nil
}

---@param entity EntityNPC
function MomsHand:OnUpdate(entity)
    local sprite = entity:GetSprite()
    if entity.FrameCount == 1 and entity.Type == EntityType.ENTITY_MOMS_HAND then
        sprite:Play("JumpUp", true)
    end

    if MomsHand.WasTouched and MomsHand.RoomTarget == nil then
        local lastRoom = Game():GetLevel():GetLastRoomDesc()
        local data = lastRoom.Data
        if data.Type == RoomType.ROOM_CURSE or data.Type == RoomType.ROOM_ERROR then
            MomsHand.RoomTarget = Game():GetLevel():GetStartingRoomIndex()
        else
            MomsHand.RoomTarget = Game():GetLevel():GetPreviousRoomIndex()
        end
    end
end

function MomsHand:Reset()
    MomsHand.RoomTarget = nil -- reset after game end
    MomsHand.WasTouched = false
end

function MomsHand:OnNewRoom()
    if MomsHand.RoomTarget ~= nil and MomsHand.WasTouched then
        MomsHand.WasTouched = false
        Game():ChangeRoom(MomsHand.RoomTarget)
        MomsHand.RoomTarget = nil
    end
end

---@param collider EntityNPC
function MomsHand:OnPlayerTouch(_, collider)
    if collider.Type == EntityType.ENTITY_MOMS_HAND and MomsHand.WasTouched == false then
        MomsHand.WasTouched = true
    end
end

-- /////////////////// --

return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, MomsHand.OnUpdate)
    BalanceMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, MomsHand.Reset)
    BalanceMod:AddCallback(ModCallbacks.MC_POST_GAME_END, MomsHand.Reset)
    BalanceMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, MomsHand.OnNewRoom)
    BalanceMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, MomsHand.OnPlayerTouch)
end