------------------- ABOUT ----------------------
--
-- In the desert planet Hero will have to explore
-- the dunes below the surface and find the hidden
-- crates. It is told that one crate contains the
-- lost part.

-- TODO
-- maybe use same name in missionName and frontend mission name..
-- in this map I have to track the weapons the player has in checkpoints
-- GENERAL NOTE: change hats :D

HedgewarsScriptLoad("/Scripts/Locale.lua")
HedgewarsScriptLoad("/Scripts/Animate.lua")

----------------- VARIABLES --------------------
-- globals
local campaignName = loc("A Space Adventure")
local missionName = loc("Desert planet, lost in sand!")
local heroIsInBattle = false
local ongoingBattle = 0
local checkPointReached = 1 -- 1 is normal spawn
-- dialogs
local dialog01 = {}
-- mission objectives
local goals = {
	[dialog01] = {missionName, loc("Getting ready"), loc("The part is hidden in one of the crates! Go and get it!"), 1, 4500},
}
-- crates
local btorch1Y = 60
local btorch1X = 2700
local btorch2Y = 1800
local btorch2X = 1010
local btorch3Y = 980
local btorch3X = 3260
local rope1Y = 970
local rope1X = 3200
local rope2Y = 1900
local rope2X = 680
local rope3Y = 1850
local rope3X = 2460
local portalY = 480
local portalX = 1465
local constructY = 1630
local constructX = 3350
-- hogs
local hero = {}
local ally = {}
local smuggler1 = {}
local smuggler2 = {}
local smuggler3 = {}
-- teams
local teamA = {}
local teamB = {}
local teamC = {}
-- hedgehogs values
hero.name = "Hog Solo"
hero.x = 1740
hero.y = 40
hero.dead = false
ally.name = "Chief Sandologist"
ally.x = 1660
ally.y = 40
smuggler1.name = "Sanndy"
smuggler1.x = 400
smuggler1.y = 235
smuggler2.name = "Spike"
smuggler2.x = 736
smuggler2.y = 860
smuggler3.name = "Sandstorm"
smuggler3.x = 1940
smuggler3.y = 1625
teamA.name = loc("PAotH")
teamA.color = tonumber("FF0000",16) -- red
teamB.name = loc("Smugglers")
teamB.color = tonumber("0033FF",16) -- blues
teamC.name = loc("Hog Solo")
teamC.color = tonumber("38D61C",16) -- green

-------------- LuaAPI EVENT HANDLERS ------------------

function onGameInit()
	Seed = 1
	TurnTime = 20000
	CaseFreq = 0
	MinesNum = 0
	MinesTime = 1
	Explosives = 0
	Delay = 3
	HealthCaseAmount = 30
	Map = "desert01_map"
	Theme = "Desert"
	
	-- get the check point
	if tonumber(GetCampaignVar("Desert01CheckPoint")) then
		checkPointReached = tonumber(GetCampaignVar("Desert01CheckPoint"))
	end
	-- get hero health
	local heroHealth = 100
	if checkPointReached > 1 and tonumber(GetCampaignVar("HeroHealth")) then
		heroHealth = tonumber(GetCampaignVar("HeroHealth"))
	end
	
	-- Hog Solo
	AddTeam(teamC.name, teamC.color, "Bone", "Island", "HillBilly", "cm_birdy")
	hero.gear = AddHog(hero.name, 0, heroHealth, "war_desertgrenadier1")
	AnimSetGearPosition(hero.gear, hero.x, hero.y)
	HogTurnLeft(hero.gear, true)
	-- PAotH undercover scientist and chief Sandologist
	AddTeam(teamA.name, teamA.color, "Bone", "Island", "HillBilly", "cm_birdy")
	ally.gear = AddHog(ally.name, 0, 100, "war_desertgrenadier1")
	AnimSetGearPosition(ally.gear, ally.x, ally.y)
	-- Smugglers
	AddTeam(teamB.name, teamB.color, "Bone", "Island", "HillBilly", "cm_birdy")
	smuggler1.gear = AddHog(smuggler1.name, 1, 100, "tophats")
	AnimSetGearPosition(smuggler1.gear, smuggler1.x, smuggler1.y)
	smuggler2.gear = AddHog(smuggler2.name, 1, 100, "tophats")
	AnimSetGearPosition(smuggler2.gear, smuggler2.x, smuggler2.y)	
	smuggler3.gear = AddHog(smuggler3.name, 1, 100, "tophats")
	AnimSetGearPosition(smuggler3.gear, smuggler3.x, smuggler3.y)	
	
	if checkPointReached == 1 then
		-- Start of the game
	elseif checkPointReached == 2 then
		AnimSetGearPosition(hero.gear, 1050, 615)
		HogTurnLeft(hero.gear, true)
	end
	
	AnimInit()
	AnimationSetup()	
end

function onGameStart()
	AnimWait(hero.gear, 3000)
	FollowGear(hero.gear)
	
	AddEvent(onHeroDeath, {hero.gear}, heroDeath, {hero.gear}, 0)
	AddEvent(onHeroAtFirstBattle, {hero.gear}, heroAtFirstBattle, {hero.gear}, 1)
	AddEvent(onHeroFleeFirstBattle, {hero.gear}, heroFleeFirstBattle, {hero.gear}, 1)
	AddEvent(onHeroAtCheckpoint2, {hero.gear}, heroAtCheckpoint2, {hero.gear}, 0)
	
	-- smugglers ammo
	AddAmmo(smuggler1.gear, amBazooka, 2)
	AddAmmo(smuggler1.gear, amGrenade, 2)
	AddAmmo(smuggler1.gear, amDEagle, 2)
	
	-- spawn crates	
	SpawnAmmoCrate(btorch1X, btorch1Y, amBlowTorch)
	SpawnAmmoCrate(btorch2X, btorch2Y, amBlowTorch)
	SpawnAmmoCrate(btorch3X, btorch3Y, amBlowTorch)
	SpawnAmmoCrate(rope1X, rope1Y, amRope)
	SpawnAmmoCrate(rope2X, rope2Y, amRope)
	SpawnAmmoCrate(rope3X, rope3Y, amRope)
	SpawnAmmoCrate(portalX, portalY, amPortalGun)
	SpawnAmmoCrate(constructX, constructY, amConstruction)
	
	SpawnHealthCrate(3300, 970)
	SpawnHealthCrate(680, 460)
	
	-- adding mines - BOOM!
	AddGear(1280, 460, gtMine, 0, 0, 0, 0)
	AddGear(270, 460, gtMine, 0, 0, 0, 0)
	AddGear(3460, 60, gtMine, 0, 0, 0, 0)
	AddGear(3500, 240, gtMine, 0, 0, 0, 0)
	AddGear(3410, 670, gtMine, 0, 0, 0, 0)
	AddGear(3450, 720, gtMine, 0, 0, 0, 0)
	
	local x = 800
	while x < 1650 do
		AddGear(x, 900, gtMine, 0, 0, 0, 0)
		x = x + math.random(8,20)
	end
	x = 1890
	while x < 2988 do
		AddGear(x, 760, gtMine, 0, 0, 0, 0)
		x = x + math.random(8,20)
	end
	x = 2480
	while x < 3300 do
		AddGear(x, 1450, gtMine, 0, 0, 0, 0)
		x = x + math.random(8,20)
	end
	x = 1570
	while x < 2900 do
		AddGear(x, 470, gtMine, 0, 0, 0, 0)
		x = x + math.random(8,20)
	end
	
	if checkPointReached == 1 then
		-- hero ammo
		AddAmmo(hero.gear, amRope, 2)
		AddAmmo(hero.gear, amBazooka, 3)
		AddAmmo(hero.gear, amParachute, 1)
		AddAmmo(hero.gear, amGrenade, 6)
		AddAmmo(hero.gear, amDEagle, 4)
	
		AddAnim(dialog01)
	elseif checkPointReached == 2 then
		ShowMission(campaignName, missionName, loc("The part is hidden in one of the crates! Go and get it!"), -amSkip, 0)
		-- hero ammo
		local ammo = GetCampaignVar("HeroAmmo")
		AddAmmo(hero.gear, amRope, tonumber(ammo:sub(3,3)))
		AddAmmo(hero.gear, amBazooka, tonumber(ammo:sub(1,1)))
		AddAmmo(hero.gear, amParachute, tonumber(ammo:sub(4,4)))
		AddAmmo(hero.gear, amGrenade, tonumber(ammo:sub(2,2)))
		AddAmmo(hero.gear, amDEagle, tonumber(ammo:sub(5,5)))
		AddAmmo(hero.gear, amBlowTorch, tonumber(ammo:sub(6,6)))
		-- weird, if 0 bazooka isn't displayed in the weapons menu
		if tonumber(ammo:sub(7,7)) > 0 then
			AddAmmo(hero.gear, amConstruction, tonumber(ammo:sub(7,7)))
		end
		AddAmmo(hero.gear, amPortalGun, tonumber(ammo:sub(8,8)))
		
		-- second battle
		heroIsInBattle = true
		ongoingBattle = 2
	end
	
	SendHealthStatsOff()
end

function onNewTurn()
	if CurrentHedgehog ~= hero.gear and not heroIsInBattle then
		TurnTimeLeft = 0
	elseif CurrentHedgehog == hero.gear and not heroIsInBattle then
		TurnTimeLeft = -1
	elseif (CurrentHedgehog == smuggler2.gear or CurrentHedgehog == smuggler3.gear) and ongoingBattle == 1 then
		AnimSwitchHog(hero.gear)
		TurnTimeLeft = 0
	elseif (CurrentHedgehog == smuggler1.gear or CurrentHedgehog == smuggler3.gear) and ongoingBattle == 2 then
		AnimSwitchHog(hero.gear)
		TurnTimeLeft = 0
	elseif CurrentHedgehog == ally.gear then
		TurnTimeLeft = 0
	end
	WriteLnToConsole("CURRENT HEDGEHOG IS "..CurrentHedgehog)
end

function onGameTick()
	AnimUnWait()
	if ShowAnimation() == false then
		return
	end
	ExecuteAfterAnimations()
	CheckEvents()
end

function onAmmoStoreInit()
	SetAmmo(amBlowTorch, 0, 0, 0, 1)
	SetAmmo(amRope, 0, 0, 0, 1)
	SetAmmo(amPortalGun, 0, 0, 0, 1)	
	SetAmmo(amConstruction, 0, 0, 0, 1)
end

function onGearDelete(gear)
	if gear == hero.gear then
		hero.dead = true
	elseif (gear == smuggler1.gear or gear == smuggler2.gear or gear == smuggler3.gear) and heroIsInBattle then
		heroIsInBattle = false
		ongoingBattle = 0
	end
end

function onPrecise()
	if GameTime > 3000 then
		SetAnimSkip(true)   
	end
end

-------------- EVENTS ------------------

function onHeroDeath(gear)
	if hero.dead then
		return true
	end
	return false
end

function onHeroAtFirstBattle(gear)
	if not hero.dead and not heroIsInBattle and GetX(hero.gear) <= 1450 
			and GetY(hero.gear) <= GetY(smuggler1.gear)+5 and GetY(hero.gear) >= GetY(smuggler1.gear)-5 then
		return true
	end
	return false
end

function onHeroFleeFirstBattle(gear)
	if not hero.dead and GetHealth(smuggler1.gear) and heroIsInBattle and ongoingBattle == 1 and (GetX(hero.gear) > 1450 
			or (GetY(hero.gear) < GetY(smuggler1.gear)-80 or GetY(hero.gear) > smuggler1.y+300)) then
		return true
	end
	return false
end

-- saves the location of the hero and prompts him for the second battle
function onHeroAtCheckpoint2(gear)
	if not hero.dead and GetX(hero.gear) > 1000 and GetX(hero.gear) < 1100
			and GetY(hero.gear) > 590 then
		return true
	end
	return false
end

-------------- OUTCOMES ------------------

function heroDeath(gear)
	SendStat('siGameResult', loc("Hog Solo lost, try again!")) --1
	SendStat('siCustomAchievement', loc("To win the game you have to find the right crate")) --11
	SendStat('siCustomAchievement', loc("You can avoid some battles")) --11
	SendStat('siCustomAchievement', loc("Use your ammo wisely")) --11
	SendStat('siPlayerKills','1',teamB.name)
	SendStat('siPlayerKills','0',teamC.name)
	EndGame()
end

function heroAtFirstBattle(gear)
	WriteLnToConsole("**HERO AT FIRST BATTLE")
	AnimCaption(hero.gear, loc("A smuggler! Prepare for battle"), 5000)
	TurnTimeLeft = 0
	heroIsInBattle = true
	ongoingBattle = 1	
	AnimSwitchHog(smuggler1.gear)
	TurnTimeLeft = 0
end

function heroFleeFirstBattle(gear)
	WriteLnToConsole("++HERO FLEE FIRST BATTLE")
	AnimSay(smuggler1.gear, loc("Run away you coward!"), SAY_SHOUT, 4000)
	TurnTimeLeft = 0
	heroIsInBattle = false
	ongoingBattle = 0
end

function heroAtCheckpoint2(gear)
	-- save checkpoint
	SaveCampaignVar("Desert01CheckPoint", "2")	
	SaveCampaignVar("HeroHealth", GetHealth(hero.gear))
	-- bazooka - grenade - rope - parachute - deagle - btorch - construct - portal
	SaveCampaignVar("HeroAmmo", GetAmmoCount(hero.gear, amBazooka)..GetAmmoCount(hero.gear, amGrenade)..
			GetAmmoCount(hero.gear, amRope)..GetAmmoCount(hero.gear, amParachute)..GetAmmoCount(hero.gear, amDEagle)..
			GetAmmoCount(hero.gear, amBlowTorch)..GetAmmoCount(hero.gear, amConstruction)..GetAmmoCount(hero.gear, amPortalGun))
	AnimCaption(hero.gear, loc("Checkpoint reached!"), 5000)
	
	-- second battle
	heroIsInBattle = true
	ongoingBattle = 2
	AnimSay(smuggler2.gear, loc("This is seems like a wealthy hedgehog, nice..."), SAY_THINK, 5000)
end

-------------- ANIMATIONS ------------------

function Skipanim(anim)
	if goals[anim] ~= nil then
		ShowMission(unpack(goals[anim]))
    end
    AnimSwitchHog(hero.gear)
end

function AnimationSetup()
	-- DIALOG 01 - Start, getting info about the device
	AddSkipFunction(dialog01, Skipanim, {dialog01})
	table.insert(dialog01, {func = AnimWait, args = {hero.gear, 3000}})
	table.insert(dialog01, {func = AnimCaption, args = {hero.gear, loc("In the planet of sand, you have to double check your moves..."), 5000}})
	table.insert(dialog01, {func = AnimSay, args = {ally.gear, loc("Finaly you are here..."), SAY_SAY, 2000}})
	table.insert(dialog01, {func = AnimWait, args = {hero.gear, 2000}})
	table.insert(dialog01, {func = AnimSay, args = {hero.gear, loc("Thank you for meeting me in such a short notice!"), SAY_SAY, 3000}})
	table.insert(dialog01, {func = AnimWait, args = {ally.gear, 4000}})
	table.insert(dialog01, {func = AnimSay, args = {ally.gear, loc("No problem, I would do anything for M!"), SAY_SAY, 4000}})
	table.insert(dialog01, {func = AnimSay, args = {ally.gear, loc("Now listen carefully! Below us there are tunnels that have been created naturally over the years"), SAY_SAY, 4000}})
	table.insert(dialog01, {func = AnimSay, args = {ally.gear, loc("I have heared the local tribes saying that many years ago some PAotH scientists were dumping their waste here"), SAY_SAY, 5000}})
	table.insert(dialog01, {func = AnimSay, args = {ally.gear, loc("M confimed that there isn't such a PAotH activity logged"), SAY_SAY, 4000}})
	table.insert(dialog01, {func = AnimSay, args = {ally.gear, loc("So, I believe that it's a good place to start"), SAY_SAY, 3000}})
	table.insert(dialog01, {func = AnimSay, args = {ally.gear, loc("Beware though! Many smugglers come often to explore these tunnels and scavage whatever valuable item they can find"), SAY_SAY, 5000}})
	table.insert(dialog01, {func = AnimSay, args = {ally.gear, loc("They won't hesitate to attack you in order to take your valuables!"), SAY_SAY, 4000}})
	table.insert(dialog01, {func = AnimWait, args = {hero.gear, 6000}})
	table.insert(dialog01, {func = AnimSay, args = {hero.gear, loc("OK, I'll be extra careful!"), SAY_SAY, 4000}})
	table.insert(dialog01, {func = AnimWait, args = {ally.gear, 2000}})
	table.insert(dialog01, {func = AnimSay, args = {ally.gear, loc("There is the tunnel entrance"), SAY_SAY, 3000}})
	table.insert(dialog01, {func = AnimSay, args = {ally.gear, loc("Good luck!"), SAY_SAY, 3000}})
	table.insert(dialog01, {func = AnimWait, args = {hero.gear, 500}})
	table.insert(dialog01, {func = AnimSwitchHog, args = {hero.gear}})	
end
