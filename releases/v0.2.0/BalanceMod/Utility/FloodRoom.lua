local FloodRoom = {}
FloodRoom.MuteFlush = false

function FloodRoom:Flood(player)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_FLUSH)
    FloodRoom.MuteFlush = true
end

function FloodRoom:PostUpdate()
    if FloodRoom.MuteFlush and SFXManager():IsPlaying(SoundEffect.SOUND_FLUSH) then
        SFXManager():Stop(SoundEffect.SOUND_FLUSH)
        FloodRoom.MuteFlush = false
    end
end

return FloodRoom