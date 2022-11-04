local Dung = {
    Item = Isaac.GetTrinketIdByName("Ball of Dung")
}

---@param player EntityPlayer
---@param cacheFlags CacheFlag
function Dung:CacheUpdate(player, cacheFlags)
    if cacheFlags == CacheFlag.CACHE_ALL then
        
    end
end

return function (BalanceMod)
    
end