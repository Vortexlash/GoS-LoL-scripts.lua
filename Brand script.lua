-- Full list of functions:
-- — Combo management;
-- — Mana management;
-- — Lane Clear function;
-- — Harass;
-- — Kill Secure function;
-- — Drawings;
-- — Auto Level Up;

if GetObjectName(GetMyHero()) ~= "Brand" then return end

if not pcall( require, "OpenPredict.lua" ) then PrintChat("Check if you have OpenPredict.lua installed") return end
if not pcall( require, "Inspired.lua" ) then PrintChat("Check if you have Inspired.lua installed") return end
if not pcall( require, "IPrediction.lua" ) then PrintChat("Check if you have IPrediction.lua installed") return end

PrintChat("Brand Script loaded successfully")

local BrandMenu = Menu("Brand", "Brand Script")
BrandMenu:Menu("Auto", "Auto")
BrandMenu.Auto:Boolean('Use Q', 'Use Q', false)
BrandMenu.Auto:Boolean('Use W', 'Use W', true)
BrandMenu.Auto:Boolean('Use E', 'Use E', false)
BrandMenu.Auto:Slider("MP","Mana-Manager", 40, 0, 100, 5)

BrandMenu:Menu("Combo", "Combo")
BrandMenu.Combo:Boolean('UseQ', 'Use Q', true)
BrandMenu.Combo:Boolean('UseW', 'Use W', true)
BrandMenu.Combo:Boolean('UseE', 'Use E', true)
BrandMenu.Combo:Boolean('UseR', 'Use R', true)

BrandMenu:Menu("LaneClear", "LaneClear")
BrandMenu.LaneClear:Boolean('Use Q', 'Use Q', false)
BrandMenu.LaneClear:Boolean('Use W', 'Use W', true)
BrandMenu.LaneClear:Slider("MP","Mana-Manager", 40, 0, 100, 5)

BrandMenu:Menu("Harass", "Harass")
BrandMenu.Harass:Boolean('Use Q', 'Use Q', true)
BrandMenu.Harass:Boolean('Use W', 'Use W', true)
BrandMenu.Harass:Boolean('Use E', 'Use E', true)
BrandMenu.Harass:Slider("MP","Mana-Manager", 40, 0, 100, 5)

BrandMenu:Menu("Kill Secure", "Kill Secure")
BrandMenu.KillSteal:Boolean('Use W', 'Use W', true)

BrandMenu:Menu("Prediction", "Prediction")
BrandMenu.Prediction:DropDown("PredictionQ", "Prediction: Q", 2, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
BrandMenu.Prediction:DropDown("PredictionW", "Prediction: W", 5, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
BrandMenu:Menu("Drawings", "Drawings")

BrandMenu.Drawings:Boolean('Draw Q', 'Draw Q Range', true)
BrandMenu.Drawings:Boolean('Draw W', 'Draw W Range', true)
BrandMenu.Drawings:Boolean('Draw E', 'Draw E Range', true)
BrandMenu.Drawings:Boolean('Draw R', 'Draw R Range', true)
BrandMenu.Drawings:Boolean('Draw DMG', 'Draw Combo DMG', false)

BrandMenu:Menu("Misc", "Misc")
BrandMenu.Misc:Boolean('LvlUp', 'Level-Up', true)
BrandMenu.Misc:DropDown('AutoLvlUp', 'Level Table', 3, {"Q-W-E", "Q-E-W", "W-Q-E", "W-E-Q", "E-Q-W", "E-W-Q"})
BrandMenu.Misc:Slider('X','Minimum Enemies: R', 1, 0, 5, 1)
BrandMenu.Misc:Slider('HP','HP-Manager: R', 40, 0, 100, 5)

local BrandQ = { range = 1050, radius = 60, width = 60, speed = 1600, delay = 0.25, type = "line", collision = true, source = myHero, col = {"minion","champion","yasuowall"}}
local BrandW = { range = 900, radius = 250, width = 250, speed = math.huge, delay = 0.625, type = "circular", collision = false, source = myHero }
local BrandE = { range = 625 }
local BrandR = { range = 750 }

OnTick(function(myHero)
	target = GetCurrentTarget()
	Auto()
	Combo()
	LaneClear()
	Harass()
	KillSteal()
	LevelUp()
end)

OnDraw(function(myHero)
	local pos = GetOrigin(myHero)
	if BrandMenu.Drawings.DrawQ:Value() then DrawCircle(pos,BrandQ.range,1,25,0xff00bfff) end
	if BrandMenu.Drawings.DrawW:Value() then DrawCircle(pos,BrandW.range,1,25,0xff4169e1) end
	if BrandMenu.Drawings.DrawE:Value() then DrawCircle(pos,BrandE.range,1,25,0xff1e90ff) end
	if BrandMenu.Drawings.DrawR:Value() then DrawCircle(pos,BrandR.range,1,25,0xff0000ff) end
	local QDmg = (30*GetCastLevel(myHero,_Q)+50)+(0.55*GetBonusAP(myHero))
	local WDmg = ((45*GetCastLevel(myHero,_W)+30)+(0.6*GetBonusAP(myHero)))*1.25
	local EDmg = (20*GetCastLevel(myHero,_E)+50)+(0.35*GetBonusAP(myHero))
	local RDmg = (300*GetCastLevel(myHero,_R))+(0.75*GetBonusAP(myHero))
	local ComboDmg = QDmg + WDmg + EDmg + RDmg
	local WERDmg = WDmg + EDmg + RDmg
	local QERDmg = QDmg + EDmg + RDmg
	local QWRDmg = QDmg + WDmg + RDmg
	local QWEDmg = QDmg + WDmg + EDmg
	local ERDmg = EDmg + RDmg
	local WRDmg = WDmg + RDmg
	local QRDmg = QDmg + RDmg
	local WEDmg = WDmg + EDmg
	local QEDmg = QDmg + EDmg
	local QWDmg = QDmg + WDmg
	for _, enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) then
			if BrandMenu.Drawings.DrawDMG:Value() then
				if Ready(_Q) and Ready(_W) and Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, ComboDmg), 0xff008080)
				elseif Ready(_W) and Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WERDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QERDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_W) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QWRDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_W) and Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QWEDmg), 0xff008080)
				elseif Ready(_E) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, ERDmg), 0xff008080)
				elseif Ready(_W) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WRDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QRDmg), 0xff008080)
				elseif Ready(_W) and Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WEDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QEDmg), 0xff008080)
				elseif Ready(_Q) and Ready(_W) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QWDmg), 0xff008080)
				elseif Ready(_Q) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QDmg), 0xff008080)
				elseif Ready(_W) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WDmg), 0xff008080)
				elseif Ready(_E) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, EDmg), 0xff008080)
				elseif Ready(_R) then
					DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, RDmg), 0xff008080)
				end
			end
		end
	end
end)

function useQ(target)
	if GetDistance(target) < BrandQ.range then
		if BrandMenu.Prediction.PredictionQ:Value() == 1 then
			CastSkillShot(_Q,GetOrigin(target))
		elseif BrandMenu.Prediction.PredictionQ:Value() == 2 then
			local QPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),BrandQ.speed,BrandQ.delay*1000,BrandQ.range,BrandQ.radius,true,true)
			if QPred.HitChance == 1 then
				CastSkillShot(_Q, QPred.PredPos)
			end
		elseif BrandMenu.Prediction.PredictionQ:Value() == 3 then
			local qPred = _G.gPred:GetPrediction(target,myHero,BrandQ,false,true)
			if qPred and qPred.HitChance >= 3 then
				CastSkillShot(_Q, qPred.CastPosition)
			end
		elseif BrandMenu.Prediction.PredictionQ:Value() == 4 then
			local QSpell = IPrediction.Prediction({name="BrandQ", range=BrandQ.range, speed=BrandQ.speed, delay=BrandQ.delay, width=BrandQ.radius, type="linear", collision=true})
			ts = TargetSelector()
			target = ts:GetTarget(BrandQ.range)
			local x, y = QSpell:Predict(target)
			if x > 2 then
				CastSkillShot(_Q, y.x, y.y, y.z)
			end
		elseif BrandMenu.Prediction.PredictionQ:Value() == 5 then
			local QPrediction = GetPrediction(target,BrandQ)
			if QPrediction.hitChance > 0.9 then
				CastSkillShot(_Q, QPrediction.castPos)
			end
		end
	end
end
function useW(target)
	if GetDistance(target) < BrandW.range then
		if BrandMenu.Prediction.PredictionW:Value() == 1 then
			CastSkillShot(_W,GetOrigin(target))
		elseif BrandMenu.Prediction.PredictionW:Value() == 2 then
			local WPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),BrandW.speed,BrandW.delay*1000,BrandW.range,BrandW.width,false,true)
			if WPred.HitChance == 1 then
				CastSkillShot(_W, WPred.PredPos)
			end
		elseif BrandMenu.Prediction.PredictionW:Value() == 3 then
			local WPred = _G.gPred:GetPrediction(target,myHero,BrandW,true,false)
			if WPred and WPred.HitChance >= 3 then
				CastSkillShot(_W, WPred.CastPosition)
			end
		elseif BrandMenu.Prediction.PredictionW:Value() == 4 then
			local WSpell = IPrediction.Prediction({name="BrandW", range=BrandW.range, speed=BrandW.speed, delay=BrandW.delay, width=BrandW.width, type="circular", collision=false})
			ts = TargetSelector()
			target = ts:GetTarget(BrandW.range)
			local x, y = WSpell:Predict(target)
			if x > 2 then
				CastSkillShot(_W, y.x, y.y, y.z)
			end
		elseif BrandMenu.Prediction.PredictionW:Value() == 5 then
			local WPrediction = GetCircularAOEPrediction(target,BrandW)
			if WPrediction.hitChance > 0.9 then
				CastSkillShot(_W, WPrediction.castPos)
			end
		end
	end
end
function useE(target)
	CastTargetSpell(target, _E)
end
function useR(target)
	CastTargetSpell(target, _R)
end

function Auto()
	if BrandMenu.Auto.UseE:Value() then
		if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > BrandMenu.Auto.MP:Value() then
			if CanUseSpell(myHero,_E) == READY then
				if ValidTarget(target, BrandE.range) then
					useE(target)
				end
			end
		end
	end
	if BrandMenu.Auto.UseW:Value() then
		if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > BrandMenu.Auto.MP:Value() then
			if CanUseSpell(myHero,_W) == READY then
				if ValidTarget(target, BrandW.range) then
					useW(target)
				end
			end
		end
	end
	if BrandMenu.Auto.UseQ:Value() then
		if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > BrandMenu.Auto.MP:Value() then
			if CanUseSpell(myHero,_Q) == READY then
				if ValidTarget(target, BrandQ.range) then
					useQ(target)
				end
			end
		end
	end
end

function Combo()
	if Mode() == "Combo" then
		if BrandMenu.Combo.ModeC:Value() == 1 then
			if BrandMenu.Combo.UseE:Value() then
				if CanUseSpell(myHero,_E) == READY then
					if ValidTarget(target, BrandE.range) then
						useE(target)
					end
				end
			end
			if BrandMenu.Combo.UseQ:Value() then
				if CanUseSpell(myHero,_Q) == READY then
					if ValidTarget(target, BrandQ.range) then
						useQ(target)
					end
				end
			end
			if BrandMenu.Combo.UseW:Value() then
				if CanUseSpell(myHero,_W) == READY then
					if ValidTarget(target, BrandW.range) then
						useW(target)
					end
				end
			end
		elseif BrandMenu.Combo.ModeC:Value() == 2 then
			if BrandMenu.Combo.UseE:Value() then
				if CanUseSpell(myHero,_E) == READY then
					if ValidTarget(target, BrandE.range) then
						useE(target)
					end
				end
			end
			if BrandMenu.Combo.UseW:Value() then
				if CanUseSpell(myHero,_W) == READY then
					if ValidTarget(target, BrandW.range) then
						useW(target)
					end
				end
			end
			if BrandMenu.Combo.UseQ:Value() then
				if CanUseSpell(myHero,_Q) == READY then
					if ValidTarget(target, BrandQ.range) then
						useQ(target)
					end
				end
			end
		end
		if BrandMenu.Combo.UseR:Value() then
			if CanUseSpell(myHero,_R) == READY then
				if ValidTarget(target, BrandR.range) then
					if 100*GetCurrentHP(target)/GetMaxHP(target) < BrandMenu.Misc.HP:Value() then
						if EnemiesAround(myHero, BrandR.range) >= BrandMenu.Misc.X:Value() then
							if MinionsAround(target, BrandR.range) >= 1 then
								useR(target)
							end
						end
					end
				end
			end
		end
	end
end

function Harass()
	if Mode() == "Harass" then
		if BrandMenu.Harass.ModeH:Value() == 1 then
			if BrandMenu.Harass.UseE:Value() then
				if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > BrandMenu.Harass.MP:Value() then
					if CanUseSpell(myHero,_E) == READY then
						if ValidTarget(target, BrandE.range) then
							useE(target)
						end
					end
				end
			end
			if BrandMenu.Harass.UseQ:Value() then
				if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > BrandMenu.Harass.MP:Value() then
					if CanUseSpell(myHero,_Q) == READY then
						if ValidTarget(target, BrandQ.range) then
							useQ(target)
						end
					end
				end
			end
			if BrandMenu.Harass.UseW:Value() then
				if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > BrandMenu.Harass.MP:Value() then
					if CanUseSpell(myHero,_W) == READY then
						if ValidTarget(target, BrandW.range) then
							useW(target)
						end
					end
				end
			end
		elseif BrandMenu.Harass.ModeH:Value() == 2 then
			if BrandMenu.Harass.UseE:Value() then
				if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > BrandMenu.Harass.MP:Value() then
					if CanUseSpell(myHero,_E) == READY then
						if ValidTarget(target, BrandE.range) then
							useE(target)
						end
					end
				end
			end
			if BrandMenu.Harass.UseW:Value() then
				if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > BrandMenu.Harass.MP:Value() then
					if CanUseSpell(myHero,_W) == READY then
						if ValidTarget(target, BrandW.range) then
							useW(target)
						end
					end
				end
			end
			if BrandMenu.Harass.UseQ:Value() then
				if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > BrandMenu.Harass.MP:Value() then
					if CanUseSpell(myHero,_Q) == READY then
						if ValidTarget(target, BrandQ.range) then
							useQ(target)
						end
					end
				end
			end
		end
	end
end

function KillSteal()
	for i,enemy in pairs(GetEnemyHeroes()) do
		if BrandMenu.KillSteal.UseW:Value() then
			if ValidTarget(enemy, BrandW.range) then
				if CanUseSpell(myHero,_W) == READY then
					local BrandWDmg = (45*GetCastLevel(myHero,_W)+30)+(0.6*GetBonusAP(myHero))
					if GetCurrentHP(enemy)+GetArmor(enemy)+GetDmgShield(enemy)+GetMagicResist(enemy)+GetMagicShield(enemy)+GetHPRegen(enemy)*2 < BrandWDmg then
						useW(enemy)
					end
				end
			end
		end
	end
end

function LaneClear()
	if Mode() == "LaneClear" then
		if BrandMenu.LaneClear.UseW:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > BrandMenu.LaneClear.MP:Value() then
				if CanUseSpell(myHero,_W) == READY then
					local BestPos, BestHit = GetLineFarmPosition(BrandW.range, BrandW.radius, MINION_ENEMY)
					if BestPos and BestHit > 3 then
						CastSkillShot(_W, BestPos)
					end
				end
			end
		end
		if BrandMenu.LaneClear.UseQ:Value() then
			if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > BrandMenu.LaneClear.MP:Value() then
				for _, minion in pairs(minionManager.objects) do
					if GetTeam(minion) == MINION_ENEMY then
						if ValidTarget(minion, BrandQ.range) then
							if BrandMenu.LaneClear.UseQ:Value() then
								if CanUseSpell(myHero,_Q) == READY then
									useQ(minion)
								end
							end
						end
					end
				end
			end
		end
	end
end

function LevelUp()
	if BrandMenu.Misc.LvlUp:Value() then
		if BrandMenu.Misc.AutoLvlUp:Value() == 1 then
			leveltable = {_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end
		elseif BrandMenu.Misc.AutoLvlUp:Value() == 2 then
			leveltable = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end
		elseif BrandMenu.Misc.AutoLvlUp:Value() == 3 then
			leveltable = {_W, _Q, _E, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end
		elseif BrandMenu.Misc.AutoLvlUp:Value() == 4 then
			leveltable = {_W, _E, _Q, _W, _W, _R, _W, _E, _W, _E, _R, _E, _E, _Q, _Q, _R, _Q, _Q}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end
		elseif BrandMenu.Misc.AutoLvlUp:Value() == 5 then
			leveltable = {_E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end
		elseif BrandMenu.Misc.AutoLvlUp:Value() == 6 then
			leveltable = {_E, _W, _Q, _E, _E, _R, _E, _W, _E, _W, _R, _W, _W, _Q, _Q, _R, _Q, _Q}
			if GetLevelPoints(myHero) > 0 then
				DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
			end
		end
	end
end