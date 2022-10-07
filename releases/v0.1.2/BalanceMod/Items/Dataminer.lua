local a=require("BalanceMod.Utility.PlayerTracker")local b=require("BalanceMod.Utility.ExtraMath")local c={Item=Isaac.GetItemIdByName("Dataminer"),ActiveForPlayers={},BonusForPlayers={},DamageBonus=1,FireDelayBonus=0.5}function c:OnCacheUpdate(d,e)if d:GetActiveItem(ActiveSlot.SLOT_PRIMARY)==c.Item or d:GetActiveItem(ActiveSlot.SLOT_SECONDARY)==c.Item then local f=a:GetPlayerIndex(d)local g=c.ActiveForPlayers[f]if g~=nil and g>0 then c.BonusForPlayers[f]={Damage=c.DamageBonus*g,FireDelay=b:Clamp(c.FireDelayBonus*g,0.35,c.FireDelayBonus*3)}d.Damage=d.Damage+c.BonusForPlayers[f].Damage;d.MaxFireDelay=d.MaxFireDelay-c.BonusForPlayers[f].FireDelay else if c.BonusForPlayers[f]~=nil then d.Damage=d.Damage-c.BonusForPlayers[f].Damage;d.MaxFireDelay=d.MaxFireDelay+c.BonusForPlayers[f].FireDelay;c.BonusForPlayers[f]=nil end end end end;function c:OnUseItem(h,i,d,j,k)local f=a:GetPlayerIndex(d)for l,m in ipairs(Isaac.GetRoomEntities())do if m.Type~=EntityType.ENTITY_PLAYER then m.SpriteRotation=m.SpriteRotation+math.random(1,360)end end;if c.ActiveForPlayers[f]~=nil then c.ActiveForPlayers[f]=c.ActiveForPlayers[f]+1 else c.ActiveForPlayers[f]=1 end;d:AddCacheFlags(CacheFlag.CACHE_DAMAGE|CacheFlag.CACHE_FIREDELAY)d:EvaluateItems()return true end;function c:OnEnd()c.ActiveForPlayers={}for l,d in ipairs(a:GetPlayers())do d:AddCacheFlags(CacheFlag.CACHE_DAMAGE|CacheFlag.CACHE_FIREDELAY)d:EvaluateItems()end end;return function(n)n:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,c.OnCacheUpdate)n:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,c.OnEnd)n:AddCallback(ModCallbacks.MC_USE_ITEM,c.OnUseItem,c.Item)if EID then EID:addCollectible(c.Item,"On use:#{{ArrowUp}} +1 Damage#{{ArrowUp}} +0.5 Firerate#{{Warning}} Rotates all enemies#Effect only lasts for the room#Does not affect hitboxes")end;return{OldItemId=CollectibleType.COLLECTIBLE_DATAMINER,NewItemId=c.Item}end