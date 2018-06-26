-- Full list of functions:
-- — Combo management;
-- — Auto Condemn Cast;
-- — Interrupt function;
-- — Auto Level Up;

if GetObjectName(GetMyHero()) ~= "Vayne" then return end

if not pcall( require, "MapPositionGOS" ) then PrintChat("Check if you have Walls Library installed") return end
if not pcall( require, "Inspired" ) then PrintChat("Check if you have Inspired.lua installed") return end
if not pcall( require, "Deftlib" ) then PrintChat("Check if you have Deftlib.lua installed") return end
if not pcall( require, "Interrupter" ) then PrintChat("Check if you have Interrupter.lua installed") return end
if not pcall( require, "AntiDangerousSpells" ) then PrintChat("Check if you have AntiDangerousSpells.lua installed") return end

PrintChat("Vayne Script loaded successfully")

local VayneMenu = MenuConfig("Vayne", "Vayne Script")
VayneMenu:Menu("Spellshot", "Spellshot")
VayneMenu.Spellshot:Menu("Q", "Q Settings")
VayneMenu.Spellshot:DropDown("Mode Q", "Cast Mode: Q", 2, {"Standard", "On Stack"})
VayneMenu.Spellshot.Q:Boolean("Use Q", "Use Q", true)

VayneMenu.Spellshot:MenuConfig("E", "E Settings")
VayneMenu.Spellshot.E:Boolean("Use E", "Use E", true)
VayneMenu.Spellshot.E:Slider("Use E", "Stun", 400, 350, 490, 1)

VayneMenu.Spellshot:MenuConfig("R", "R Settings")
VayneMenu.Spellshot.R:Boolean("Use R", "Use R", true)
VayneMenu.Spellshot.R:Slider("Use Reap", "Use R to kill", 70, 1, 100, 1)
VayneMenu.Spellshot.R:Slider("Use Run", "Use R to run", 55, 1, 100, 1)
VayneMenu.Spellshot:Slider("Use Run", "Use R", 50, 0, 100, 1)
VayneMenu.Spellshot:Slider("Use Reap", "Use R", 20, 0, 100, 1)

VayneMenu:MenuConfig("Misc", "Misc")
VayneMenu.Misc:MenuConfig("EMenu", "Auto E")
VayneMenu.Misc:KeyBinding("WallTumble1", "WallTumble1", string.byte("T"))
VayneMenu.Misc:KeyBinding("WallTumble2", "WallTumble2", string.byte("U"))

VayneMenu:MenuConfig("Execution", "Execution")
VayneMenu.Execution:Boolean("Use E", "Use E", true)

VayneMenu:MenuConfig("Interrupter", "Interrupter")
VayneMenu.Interrupter:Boolean('Use E', 'Use E', true)

VayneMenu:MenuConfig("Drawings", "Drawings")
VayneMenu.Drawings:Boolean("Q", "Drawings Q", true)
VayneMenu.Drawings:Boolean("E", "Drawings E", true)
VayneMenu.Drawings:ColorPick("color", "color", {255,255,255,0})

VayneMenu:MenuConfig("Misc", "Misc")
VayneMenu.Misc:Boolean('Level-Up', 'Level-Up', true)
VayneMenu.Misc:DropDown('AutoLvlUp', 'Level Table', 1, {"Q-W-E", "Q-E-W", "W-Q-E", "W-E-Q", "E-Q-W", "E-W-Q"})
VayneMenu.Misc:Slider('X','Minimum Enemies: R', 1, 0, 5, 1)
VayneMenu.Misc:Slider('HP','HP-Manager: R', 40, 0, 100, 5)

local VayneQ = { range = 300 }
local VayneE = { range = 550 }

local InterruptMenu = MenuConfig("Interrupt", "Interrupt")

DelayAction(function()
local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
	for i, spell in pairs(CHANELLING_SPELLS) do
		for _,k in pairs(GetEnemyHeroes()) do
			if spell["Name"] == GetObjectName(k) then
			InterruptMenu:Boolean(GetObjectName(k).."Interrupt", "Interrupt"..GetObjectName(k).." "..(type(spell.Spellslot) == 'number' and str[spell.Spellslot]), true)   
			end
		end
	end
  
	for _,k in pairs(GetEnemyHeroes()) do
		VayneMenu.Misc.EMenu:Boolean(GetObjectName(k).."Hostile", ""..GetObjectName(k).."", true)
	end		
end, 1)
  
OnDraw(function(myHero)
local col = VayneMenu.Drawings.color:Value()
	if VayneMenu.Drawings.Q:Value() then DrawCircle(myHeroPos(),GetCastRange(myHero,_Q),1,0,col) end
		if VayneMenu.Drawings.E:Value() then DrawCircle(myHeroPos(),GetCastRange(myHero,_E),1,0,col) end
			if mapID == SUMMONERS_RIFT and VayneMenu.Drawings.WT:Value() then
			DrawCircle(6962, 51, 8952,80,0,0,0xffffffff)
			DrawCircle(12060, 51, 4806,80,0,0,0xffffffff)
			end
		end)

local IsStealthed = false

OnTick(function(myHero)
	if VayneMenu.AntiGapcloser.UseE:Value() then
		if ValidTarget(target, 150) then
			if CanUseSpell(myHero,_E) == READY then
				CastTargetSpell(target, _E)
			end
		end
	end
end)
		
	if IsReady(_E) and VayneMenu.Spellshot.E.Enabled:Value() and ValidTarget(target, 710) then
	AutoCondemn(target)
	end
end

	if VayneMenu.Misc.WallTumble1:Value() and myHeroPos().x == 6962 and myHeroPos().z == 8952 then
	CastSkillShot(_Q,6667.3271484375, 51, 8794.64453125)
	elseif VayneMenu.Misc.WallTumble1:Value() then
	MoveToXYZ(6962, 51, 8952)
end
    
	if VayneMenu.Misc.WallTumble2:Value() and myHeroPos().x == 12060 and myHeroPos().z == 4806 then
	CastSkillShot(_Q,11745.198242188, 51, 4625.4379882813)
	elseif VayneMenu.Misc.WallTumble2:Value() then
	MoveToXYZ(12060, 51, 4806)
	end
end)

function Execution()
	for i,enemy in pairs(GetEnemyHeroes()) do
		if VayneMenu.Execution.UseE:Value() then
			if ValidTarget(enemy, VayneE.range) then
				if CanUseSpell(myHero,_E) == READY then
					local VayneEDmg = (40*GetCastLevel(myHero,_E)+10)+(0.5*GetBonusDmg(myHero))
					if GetCurrentHP(enemy) < VayneEDmg then
						CastTargetSpell(enemy, _E)
					end
				end
			end
		end
	end
end

addInterrupterCallback(function(target, SpellType, spell)
	if VayneMenu.Interrupter.UseE:Value() then
		if ValidTarget(target, VayneE.range) then
			if CanUseSpell(myHero,_E) == READY then
				if SpellType == GAPCLOSER_SPELLS or SpellType == CHANELLING_SPELLS then
					CastTargetSpell(target, _E)
				end
			end
		end
	end
end)
  
	if GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(myHero) and IsReady(_E) then
		if CHANELLING_SPELLS[spell.name] then
			if IsInDistance(unit, 615) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and InterruptMenu[GetObjectName(unit).."Interrupt"]:Value() then 
			CastTargetSpell(unit, _E)
		end
	end
end
end

function AutoCondemn(unit)
	local EPred = GetPredictionForPlayer(GetMousePos(),unit,GetMoveSpeed(unit),2000,250,1000,1,false,true)
	local PredPos = Vector(EPred.PredPos)
	local maxERange = PredPos - (PredPos - GetMousePos()) * ( - VayneMenu.Spellshot.E.pushdistance:Value() / GetDistance(GetMousePos(), EPred.PredPos))
	local shootLine = Line(Point(PredPos.x, PredPos.y, PredPos.z), Point(maxERange.x, maxERange.y, maxERange.z))
		for i, Pos in pairs(shootLine:__getPoints()) do
		if MapPosition:inWall(Pos) then
		CastTargetSpell(unit, _E) 
		DelayAction(function() CastSkillShot(Flash,GetMousePos()) end, 1)
		end
	end
end

function LevelUp()
	if VayneMenu.Misc.LvlUp:Value() then
		if VayneMenu.Misc.AutoLvlUp:Value() == 1 then
			leveltable = {_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end
			
		elseif VayneMenu.Misc.AutoLvlUp:Value() == 2 then
			leveltable = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end

		elseif VayneMenu.Misc.AutoLvlUp:Value() == 3 then
			leveltable = {_W, _Q, _E, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end

		elseif VayneMenu.Misc.AutoLvlUp:Value() == 4 then
			leveltable = {_W, _E, _Q, _W, _W, _R, _W, _E, _W, _E, _R, _E, _E, _Q, _Q, _R, _Q, _Q}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end

		elseif VayneMenu.Misc.AutoLvlUp:Value() == 5 then
			leveltable = {_E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end

		elseif VayneMenu.Misc.AutoLvlUp:Value() == 6 then
			leveltable = {_E, _W, _Q, _E, _E, _R, _E, _W, _E, _W, _R, _W, _W, _Q, _Q, _R, _Q, _Q}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end
		end
	end
end

addInterrupterCallback(function(target, spellType, spell)
	if VayneMenu.Interrupter.UseE:Value() then
		if ValidTarget(target, VayneE.range) then
			if CanUseSpell(myHero,_E) == READY then
				if spellType == GAPCLOSER_SPELLS or spellType == CHANELLING_SPELLS then
					CastTargetSpell(target, _E)
				end
			end
		end
	end
end)
