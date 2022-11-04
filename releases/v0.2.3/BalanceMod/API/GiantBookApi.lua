-- Original:
-- https://steamcommunity.com/sharedfiles/filedetails/?id=2704939039&
-- Adapted to fit the mod by Maya
-- THANK YOU <3

local Api = {}
local game = Game()
local sfx = SFXManager()

local function GetScreenSize() -- By Kilburn himself.
    local room = game:GetRoom()
    local pos = Isaac.WorldToScreen(Vector(0,0)) - room:GetRenderScrollOffset() - game.ScreenShakeOffset
    
    local rx = pos.X + 60 * 26 / 40
    local ry = pos.Y + 140 * (26 / 40)
    
    return rx*2 + 13*26, ry*2 + 7*26
end

--GIANTBOOK ANIMATION
local bigBook = Sprite()
local maxFrames = { ["Appear"] = 33,  ["Shake"] = 36,  ["ShakeFire"] = 32,  ["Flip"] = 33 }
local bookColors = { [0] = Color(1, 1, 1, 1, 0, 0, 0), [1] = Color(1, 1, 1, 1, 0, 0, 0), [2] = Color(1, 1, 1, 1, 0, 0, 0), [3] = Color(1, 1, 1, 1, 0, 0, 0), [4] = Color(1, 1, 1, 1, 0, 0, 0), [5] = Color(1, 1, 1, 1, 0, 0, 0) }
local bookLength = 0
local bookHideBerkano = false

--layer #0 - popup
--layer #1 - screen (color 2)
--layer #2 - dust poof (color 1)
--layer #3 - dust poof (color 1)
--layer #4 - swirl poof (color 3)
--layer #5 - fire

local function doBerkanoPause()
	--do pause (thanks to kittenchilly for coming up with the idea to use berkano)
	Isaac.GetPlayer(0):UseCard(Card.RUNE_BERKANO, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	--remove the blue flies and spiders that just spawned
	for _, bluefly in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, -1, false, false)) do
		if bluefly:Exists() and bluefly.FrameCount <= 0 then
			bluefly:Remove()
		end
	end
	for _, bluespider in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER, -1, false, false)) do
		if bluespider:Exists() and bluespider.FrameCount <= 0 then
			bluespider:Remove()
		end
	end
end

function Api:PlayGiantBook(_animName, _popup, _poofColor, _bgColor, _poof2Color, _soundName, _notHide) 
	bigBook:Load("gfx/ui/giantbook/giantbook.anm2", true)
	bigBook:ReplaceSpritesheet(0, "gfx/ui/giantbook/" .. _popup)
	bigBook:LoadGraphics()
	bigBook:Play(_animName, true)
	bookLength = maxFrames[_animName]
	bookColors[1] = _bgColor
	bookColors[2] = _poofColor
	bookColors[3] = _poofColor
	bookColors[4] = _poof2Color
	bookHideBerkano = true
	if not _notHide then
		doBerkanoPause()
		--if sound exists, play it
		if (_soundName) then
			sfx:Play(_soundName, 0.8, 0, false, 1)
		end
	end
end

function Api:BookRender()
	if bookLength > 0 then
		if (Isaac.GetFrameCount() % 2 == 0) then
			bigBook:Update()
			bookLength = bookLength - 1
		end
		for i=5, 0, -1 do
			bigBook.Color = bookColors[i]
			local screenCenterX, screenCenterY = GetScreenSize()
			local screenCenter = Vector(screenCenterX/2, screenCenterY/2)
			bigBook:RenderLayer(i, screenCenter, Vector(0,0), Vector(0,0))
		end
	end
	if bookLength == 0 and bookHideBerkano then
		bookHideBerkano = false
	end
end


--giving berkano back it's visual effect
function Api:UseBerkano()
	if not bookHideBerkano  then
		Api:PlayGiantBook("Appear", "gbookapi_berkano.png", Color(0.2, 0.1, 0.3, 1, 0, 0, 0), Color(0.117, 0.0117, 0.2, 1, 0, 0, 0), Color(0, 0, 0, 0.8, 0, 0, 0), nil, true)
	end
end


--ACHIEVEMENT DISPLAY
local achievementQueue = {}
local bigPaper = Sprite()
local paperFrames = 0
local paperSwitch = false

function Api:PaperRender() --TODO: ADD SOUNDS
	if (paperFrames <= 0) then
		--setback
		if paperSwitch then
			--move on
			--Isaac.ConsoleOutput("Stopped! \n")
			for i = 1, #achievementQueue-1 do
				achievementQueue[i] = achievementQueue[i+1]
			end
			achievementQueue[#achievementQueue] = nil
			--false
			paperSwitch = false
		end
		--play in queue
		if (not paperSwitch) and (#achievementQueue > 0) then
			--play animation
			--Isaac.ConsoleOutput("Playing: " .. achievementQueue[1] .. "\n")
			bigPaper:Load("gfx/ui/achievements/achievement.anm2", true)
			bigPaper:ReplaceSpritesheet(2, "gfx/ui/achievements/" .. achievementQueue[1])
			bigPaper:LoadGraphics()
			bigPaper:Play("Idle", true)
			--set variables and pause
			paperFrames = 41
			paperSwitch = true
			bookHideBerkano = true
			doBerkanoPause()
		end
	else
	--visual
		--update sprites
		if (Isaac.GetFrameCount() % 2 == 0) then
			bigPaper:Update()
			paperFrames = paperFrames - 1
		end
		--render
		for i=0, 3, 1 do
			local screenCenterX, screenCenterY = GetScreenSize()
			local screenCenter = Vector(screenCenterX/2, screenCenterY/2)
			bigPaper:RenderLayer(i, screenCenter, Vector(0,0), Vector(0,0))
		end
	end
	
	--sound
	if bigPaper:IsEventTriggered("paperIn") then
		sfx:Play(SoundEffect.SOUND_PAPER_IN, 1, 0, false, 1)
	end
	if bigPaper:IsEventTriggered("paperOut") then
		sfx:Play(SoundEffect.SOUND_PAPER_OUT, 1, 0, false, 1)
	end
end


function Api:ShowAchievement(_drawingSprite) 
	table.insert(achievementQueue, #achievementQueue+1, _drawingSprite)
	--Isaac.ConsoleOutput("Added: " .. _drawingSprite .. "\n")
end

--CUSTOM GIANTBOOK ANIMATION
local bigCustomAnim = Sprite()
local customAnimLength = 0
function Api:PlayCustomGiantAnimation(_fileName, _animName, _soundName, _notHide)
	bigCustomAnim:Load("gfx/ui/giantbook/" .. _fileName, true)
	bigCustomAnim:LoadGraphics()
	bigCustomAnim:Play(_animName, true)
	customAnimLength = 32
	bookHideBerkano = true
	if not _notHide then
		doBerkanoPause()
		--if sound exists, play it
		if (_soundName) then
			sfx:Play(_soundName, 0.8, 0, false, 1)
		end
	end
end

function Api:CustomRender()
	if customAnimLength > 0 then
		if (Isaac.GetFrameCount() % 2 == 0) then
			bigCustomAnim:Update()
			customAnimLength = customAnimLength - 1
		end
		local screenCenterX, screenCenterY = GetScreenSize()
		local screenCenter = Vector(screenCenterX/2, screenCenterY/2)
		bigCustomAnim:Render(screenCenter, Vector(0,0), Vector(0,0))
	end
end


function Api:Init(mod)
    mod:AddCallback(ModCallbacks.MC_POST_RENDER, Api.CustomRender)
    mod:AddCallback(ModCallbacks.MC_POST_RENDER, Api.PaperRender)
    mod:AddCallback(ModCallbacks.MC_POST_RENDER, Api.BookRender)
    mod:AddCallback(ModCallbacks.MC_USE_CARD, Api.UseBerkano, Card.RUNE_BERKANO)
end

return Api