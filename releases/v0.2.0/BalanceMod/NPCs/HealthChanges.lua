-- // Enemy health tweaks // --

-- Structured like this:
--[[

    {
        [entitySubtype] = {
            [entityVariant] = maxhealth
        }
    }

]]
local HealthTweaks = {
    Tweaks = {
        [15] = {
            [3] = 16
        },
        [94] = {
            [0] = 15
        },
        [86] = {
            [0] = 33
        },
        [892] = {
            [0] = 16
        },
        [921] = {
            [0] = 468
        }
    }
}


local ChampionAdjusters = {
    [ChampionColor.RED] = 2.6,
    [ChampionColor.YELLOW] = 1.5,
    [ChampionColor.GREY] = (2/3),
    [ChampionColor.TINY] = (2/3),
    [ChampionColor.GIANT] = 3,
    [ChampionColor.KING] = 6,
    [ChampionColor.RAINBOW] = 3
}

---@param entity EntityNPC
function HealthTweaks:NPCUpdate(entity)
    if entity.FrameCount == 1 then
        local entityTweaked = HealthTweaks.Tweaks[entity.Type]
        if entityTweaked then
            
            local subTypeTweaked = entityTweaked[entity.SubType]
            if subTypeTweaked then
                local multiplier = 1
                if entity:IsChampion() then
                    multiplier = ChampionAdjusters[entity:GetChampionColorIdx()] or 1
                end
                entity.MaxHitPoints = subTypeTweaked * multiplier
                entity.HitPoints = subTypeTweaked * multiplier
            end
        end
    end
end

return function (BalanceMod)
    BalanceMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, HealthTweaks.NPCUpdate)
end