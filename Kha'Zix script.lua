-- Full list of functions:
-- — Combo management;
-- — Jungle Clear function;
-- — Auto Level Up;

if GetObjectName(GetMyHero()) ~= "Kha'Zix" then return end

if not pcall( require, "OpenPredict" ) then PrintChat("Check if you have OpenPredict.lua installed") return end

PrintChat("Kha'Zix Script loaded successfully")

local KhaZixMenu = MenuConfig("KhaZix", "KhaZix Script") 
KhaZixMenu:SubMenu("Combo", "Combo")
KhaZixMenu.Combo:Boolean("Q", "Use Q", true)
KhaZixMenu.Combo:Boolean("W", "Use W", true)
KhaZixMenu.Combo:Boolean("E", "Use E", true)
KhaZixMenu.Combo:Boolean("R", "Use R", true)
KhaZixMenu.Combo:Boolean("QKS", "Killsteal with Q", true) 
KhaZixMenu.Combo:Boolean("WKS", "Killsteal with W", true)
KhaZixMenu.Combo:Slider("R", "R Settings", 3, 1, 5, 1)

KhaZixMenu:Menu("JungleClear", "JungleClear")
KhaZixMenu.JungleClear:Boolean('UseQ', 'Use Q', true)
KhaZixMenu.JungleClear:Boolean('UseW', 'Use W', true)
KhaZixMenu.JungleClear:Boolean('UseE', 'Use E', true)

KhaZixMenu:Menu("Misc", "Misc")
KhaZixMenu.Misc:Boolean('Level-Up', 'Level-Up', true)
KhaZixMenu.Misc:DropDown('AutoLvlUp', 'Level Table', 1, {"Q-W-E"})
KhaZixMenu.Misc:Slider('X','Minimum Enemies: R', 1, 0, 5, 1)
KhaZixMenu.Misc:Slider('HP','HP-Manager: R', 40, 0, 100, 5)


local KhaZixW = { delay = .5, range = 1000, width = 250, speed = 828.5 }
local KhaZixE = { delay = .5, range = 900, width = 300, speed = 1300 }

OnTick(function () 
    local target = GetCurrentTarget()     
    if IOW:Mode() == "Combo" then
        if KhaZixMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 375) then 
            CastTargetSpell(target , _Q)
        end
    if KhaZixMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, 1000) then 
    local WPred = GetPrediction(target,KhaZixW)
        if WPred.hitChance > 0.2 and not WPred:mCollision(1) then 
            CastSkillShot(_W,WPred.castPos)
        end
    end 
    if KhaZixMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, 900) then
    local EPred = GetPrediction(target,KhazixE)
        if EPred.hitChance > 0.2 then 
            CastSkillShot(_E,EPred.castPos)
        end
    end
    if Ready(_R) and EnemiesAround(myHero, 200) >= KhaZixMenu.Combo.RM:Value() and KhaZixMenu.Combo.R:Value() then
        CastSpell(_R)
    end
end

function JungleClear()
	if Mode() == "JungleClear" then
		for _,mob in pairs(minionManager.objects) do
			if GetTeam(mob) == 300 then
				if CanUseSpell(myHero,_Q) == READY then
					if ValidTarget(mob, KhaZixQ.range) then
						if KhaZixMenu.JungleClear.UseQ:Value() then
							CastSkillShot(_Q,GetOrigin(mob))
						end
					end
				end
				if CanUseSpell(myHero,_W) == READY then
					if ValidTarget(mob, KhaZixW.range) then
						if KhaZixMenu.JungleClear.UseW:Value() then	   
							CastTargetSpell(mob, _W)
						end
					end
				end
				if CanUseSpell(myHero,_E) == READY then
					if ValidTarget(mob, KhaZixE.range) then
						if KhaZixMenu.JungleClear.UseE:Value() then
							CastSkillShot(_E,GetOrigin(mob))
						end
					end
				end
			end
		end
	end
end

function LevelUp()
	if KhaZixMenu.Misc.LvlUp:Value() then
		if KhaZixMenu.Misc.AutoLvlUp:Value() == 1 then
			leveltable = {_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end
		elseif KhaZixMenu.Misc.AutoLvlUp:Value() == 2 then
			leveltable = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end
		elseif KhaZixMenu.Misc.AutoLvlUp:Value() == 3 then
			leveltable = {_W, _Q, _E, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end
		elseif KhaZixMenu.Misc.AutoLvlUp:Value() == 4 then
			leveltable = {_W, _E, _Q, _W, _W, _R, _W, _E, _W, _E, _R, _E, _E, _Q, _Q, _R, _Q, _Q}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end
		elseif KhaZixMenu.Misc.AutoLvlUp:Value() == 5 then
			leveltable = {_E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end
		elseif KhaZixMenu.Misc.AutoLvlUp:Value() == 6 then
			leveltable = {_E, _W, _Q, _E, _E, _R, _E, _W, _E, _W, _R, _W, _W, _Q, _Q, _R, _Q, _Q}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end
		end
	end
end

local DPS = 0

local function GetDMG(target)
	if IsIsolated(target) == true then
		return CalcDamage(myHero,target, 58.5 + 32.5*GetCastLevel(myHero,_Q) + GetBonusDmg(myHero)*2.6 + 10*GetLevel(myHero), 0) 
	else
		return CalcDamage(myHero,target, 45 + 25*GetCastLevel(myHero,_Q) + GetBonusDmg(myHero)*1.2 , 0)
	end
end

OnDraw(function ()
    local target = GetCurrentTarget()
    if ValidTarget(target, 1400) and GetCurrentHP(target) + GetDmgShield(target) <= DPS then
      	local hppos = GetHPBarPos(target) 
      	DrawText("Kill Secured", 22, hppos.x + 35, hppos.y+ 24, ARGB(255,135,219,129))
    end
end)
   
for _, enemy in pairs(GetEnemyHeroes()) do
    if KhaZixMenu.Combo.Q:Value() and KhaZixMenu.Combo.QKS:Value() and Ready(_Q) and ValidTarget(enemy, 375) then
        if GetCurrentHP(enemy) < CalcDamage(myHero, enemy, 0, 45 + 25 * GetCastLevel(myHero,_Q) + GetBonusDmg(myHero) * 1.2, 0) then
            CastTargetSpell(enemy , _Q)    
        end
    end
        if KhaZixMenu.Combo.W:Value() and KhaZixMenu.Combo.WKS:Value() and Ready(_W) and ValidTarget(enemy, 1000) then
            if GetCurrentHP(enemy) < CalcDamage(myHero, enemy, 0, 80 + 30 * GetCastLevel(myHero,_W) + GetBonusDmg(myHero) * 1.0, 0) then
                CastSkillShot(enemy , _W)   				
            end
        end
    end 
end) 
