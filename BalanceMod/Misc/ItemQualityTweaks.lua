-- // Item Quality tweaks // --

-- Structured like this:
--[[

    {
        [itemVariant] = "itemName" -- The clone of the item in items.xml
    }

]]

local QualityTweaks = {
    Tweaks = {
        [CollectibleType.COLLECTIBLE_MONSTROS_LUNG] = Isaac.GetItemIdByName("Monstro's Lung"),
    }
    
}

---@param player EntityPlayer
function QualityTweaks:PlayerUpdate(player)
    local oldId
    local newId

    for item, replacement in pairs(QualityTweaks.Tweaks) do
        if player:HasCollectible(replacement) then
            oldId = item
            newId = replacement
            break
        end
    end

    if oldId and newId then
        player:RemoveCollectible(newId)
        player:AddCollectible(oldId)
    end
end

function QualityTweaks:GameStart()
    if BalanceMod.IsSettingEnabled("QualityTweaks") then
        local itemPool = Game():GetItemPool()
        for item, data in pairs(QualityTweaks.Tweaks) do
            itemPool:RemoveCollectible(item)
        end
    end
end

BalanceMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, QualityTweaks.GameStart)
BalanceMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, QualityTweaks.PlayerUpdate)

if EID then
    for oldItem, newItem in pairs(QualityTweaks.Tweaks) do
        local description = EID:getDescriptionObj(5, 100, oldItem, nil, true)
        EID:addCollectible(newItem, description.Description, description.Name, EID:getLanguage())
    end
end