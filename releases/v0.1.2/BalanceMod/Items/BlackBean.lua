local a=require("BalanceMod.Utility.ExtraMath")local b={Item=Isaac.GetItemIdByName("The Black Bean"),PushbackForce=50,RadiusInTiles=3,DecayRateInTiles=2,PickupMultiplier=0.3,DecayAmount=20,BlacklistedEntities={[EntityType.ENTITY_EFFECT]=true,[EntityType.ENTITY_PLAYER]=true,[EntityType.ENTITY_FAMILIAR]=true}}function b:OnHurt(c)local d=c:ToPlayer()if d:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_BEAN)then Game():ButterBeanFart(d.Position,a:TilesToUnits(b.RadiusInTiles),d,true,true)end end;return function(e)e:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,b.OnHurt,EntityType.ENTITY_PLAYER)if EID then EID:addCollectible(b.Item,"Isaac will fart upon taking damage#Fart deals poison damage#{{Collectible"..b.Item.."}} Fart pushes enemies things away very strongly")end;return false end