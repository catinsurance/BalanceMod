-- // D10 // --

local D10 = {
    Item = Isaac.GetItemIdByName("D10"),
    WasRerolled = false,
    EnemiesToRemove = {}
}

function D10:OnUse(player)
    D10.WasRerolled = true
    EnemiesToRemove = {}
end

function D10:OnRoomLeft()
    D10.WasRerolled = false -- reset
    EnemiesToRemove = {}
end

---@param npc EntityNPC
function D10:OnNPCSpawn(npc) -- on npc update
    if D10.EnemiesToRemove[GetPtrHash(npc)] then
        npc:Remove()
        if not npc:Exists() then
            D10.EnemiesToRemove[GetPtrHash(npc)] = nil
        end
        return
    end
    if npc.FrameCount == 0 and D10.WasRerolled then -- just now spawned
        local rng = RNG()
        rng:SetSeed(npc.InitSeed, 35)
        if npc:IsChampion() then
            Isaac.Spawn(npc.Type, npc.Variant, npc.SubType, npc.Position, npc.Velocity, npc.Parent)
            D10.EnemiesToRemove[GetPtrHash(npc)] = true
        end
    end
end

-- /////////////////// --

return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, D10.OnUse, D10.Item)
    BalanceMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, D10.OnRoomLeft)
    BalanceMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, D10.OnNPCSpawn)
    BalanceMod:AddCallback(ModCallbacks.MC_POST_GAME_END, D10.OnRoomLeft)
end