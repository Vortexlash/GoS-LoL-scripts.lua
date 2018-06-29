-- Full list of functions:
-- — Combo management;
-- — Mana management;
-- — Last Hit function;
-- — Lane Clear function;
-- — Auto Level Up;

if GetObjectName(GetMyHero()) ~= "Annie" then return end

if not pcall( require, "OpenPredict" ) then PrintChat("Check if you have OpenPredict.lua installed") return end

PrintChat("Annie Script loaded successfully")

local AnnieMenu = MenuConfig("Annie", "Annie Script")
AnnieMenu:MenuConfig("Auto", "Auto")
AnnieMenu.Auto:Boolean('Use Q', 'Use Q', true)
AnnieMenu.Auto:Boolean('Use W', 'Use W', true)
AnnieMenu.Auto:Boolean('Use E', 'Use E', false)
AnnieMenu.Auto:Slider("MP","Mana-Manager", 40, 0, 100, 5)

AnnieMenu:MenuConfig("Combo", "Combo")
AnnieMenu.Combo:Boolean('Use Q', 'Use Q', true)
AnnieMenu.Combo:Boolean('Use W', 'Use W', true)
AnnieMenu.Combo:Boolean('Use E', 'Use E', true)
AnnieMenu.Combo:Boolean('Use R', 'Use R', true)

AnnieMenu.Harass:Slider("MP","Mana-Manager", 40, 0, 100, 5)

AnnieMenu:MenuConfig("LastHit", "LastHit")

AnnieMenu.LastHit:Boolean('Use Q', 'Use Q', true)

AnnieMenu:MenuConfig("Prediction", "Prediction")
AnnieMenu.Prediction:DropDown("Prediction W", "Prediction: W", 2, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})
AnnieMenu.Prediction:DropDown("Prediction R", "Prediction: R", 5, {"CurrentPos", "GoSPred", "GPrediction", "IPrediction", "OpenPredict"})

AnnieMenu:MenuConfig("Drawings", "Drawings")
AnnieMenu.Drawings:Boolean('DrawQ', 'Draw Q Range', true)
AnnieMenu.Drawings:Boolean('DrawWR', 'Draw WR Range', true)
AnnieMenu.Drawings:Boolean('DrawDMG', 'Draw Max QWR Damage', false)

AnnieMenu:MenuConfig("Misc", "Misc")
AnnieMenu.Misc:Boolean('LvlUp', 'Level-Up', true)
AnnieMenu.Misc:DropDown('AutoLvlUp', 'Level Table', 1, {"Q-W-E", "Q-E-W", "W-Q-E", "W-E-Q", "E-Q-W", "E-W-Q"})
AnnieMenu.Misc:Slider('X','Minimum Enemies: R', 1, 0, 5, 1)
AnnieMenu.Misc:Slider('HP','HP-Manager: R', 40, 0, 100, 5)
    
local AnnieQ = { range = 625 }
local AnnieW = { range = 600, angle = 50, radius = 50, width = 100, speed = math.huge, delay = 0.25, type = "cone", collision = false, source = myHero }
local AnnieR = { range = 600, radius = 290, width = 290, speed = math.huge, delay = 0.25, type = "circular", collision = false, source = myHero }
    
OnTick(function(myHero)
    target = GetCurrentTarget()
        Auto()
        Combo()
        Harass()
        LastHit()
        LaneClear()
        LevelUp()
    end)
    
OnDraw(function(myHero)
    local pos = GetOrigin(myHero)
    if AnnieMenu.Drawings.DrawQ:Value() then DrawCircle(pos,AnnieQ.range,1,25,0xff00bfff) end
    if AnnieMenu.Drawings.DrawWR:Value() then DrawCircle(pos,AnnieW.range,1,25,0xff4169e1) end
    local QDmg = (35*GetCastLevel(myHero,_Q)+45)+(0.8*GetBonusAP(myHero))
    local WDmg = (45*GetCastLevel(myHero,_W)+25)+(0.85*GetBonusAP(myHero))
    local RDmg = (125*GetCastLevel(myHero,_R)+25)+(0.65*GetBonusAP(myHero))
    local ComboDmg = QDmg + WDmg + RDmg
    local WRDmg = WDmg + RDmg
    local QRDmg = QDmg + RDmg
    local QWDmg = QDmg + WDmg
    for _, enemy in pairs(GetEnemyHeroes()) do
        if ValidTarget(enemy) then
            if AnnieMenu.Drawings.DrawDMG:Value() then
                if Ready(_Q) and Ready(_W) and Ready(_R) then
                    DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, ComboDmg), 0xff008080)
                elseif Ready(_W) and Ready(_R) then
                    DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WRDmg), 0xff008080)
                elseif Ready(_Q) and Ready(_R) then
                    DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QRDmg), 0xff008080)
                elseif Ready(_Q) and Ready(_W) then
                    DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QWDmg), 0xff008080)
                elseif Ready(_Q) then
                    DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, QDmg), 0xff008080)
                elseif Ready(_W) then
                    DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, WDmg), 0xff008080)
                elseif Ready(_R) then
                    DrawDmgOverHpBar(enemy, GetCurrentHP(enemy), 0, CalcDamage(myHero, enemy, 0, RDmg), 0xff008080)
                end
            end
        end
    end
end)
    
function useQ(target)
    CastTargetSpell(target, _Q)
end

function useW(target)
    if GetDistance(target) < AnnieW.range then
        if AnnieMenu.Prediction.PredictionW:Value() == 1 then
            CastSkillShot(_W,GetOrigin(target))
        elseif AnnieMenu.Prediction.PredictionW:Value() == 2 then
            local WPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),AnnieW.speed,AnnieW.delay*1000,AnnieW.range,AnnieW.width,false,true)
            if WPred.HitChance == 1 then
            CastSkillShot(_W, WPred.PredPos) end
        elseif AnnieMenu.Prediction.PredictionW:Value() == 3 then
            local WPred = _G.gPred:GetPrediction(target,myHero,AnnieW,true,false)
            if WPred and WPred.HitChance >= 3 then
                CastSkillShot(_W, WPred.CastPosition) end
        elseif AnnieMenu.Prediction.PredictionW:Value() == 4 then
            local WSpell = IPrediction.Prediction({name="Annie W", range=AnnieW.range, speed=AnnieW.speed, delay=AnnieW.delay, width=AnnieW.width, type="conic", collision=false})
            ts = TargetSelector()
            target = ts:GetTarget(AnnieW.range)
            local x, y = WSpell:Predict(target)
            if x > 2 then
                CastSkillShot(_W, y.x, y.y, y.z) end
        elseif AnnieMenu.Prediction.PredictionW:Value() == 5 then
            local WPrediction = GetConicAOEPrediction(target,AnnieW)
            if WPrediction.hitChance > 0.9 then
                CastSkillShot(_W, WPrediction.castPos)
            end
        end
    end
end

function useE(target)
        CastSpell(_E)
end

function useR(target)
    if GetDistance(target) < AnnieR.range then
        if AnnieMenu.Prediction.PredictionR:Value() == 1 then
            CastSkillShot(_R,GetOrigin(target))
        elseif AnnieMenu.Prediction.PredictionR:Value() == 2 then
            local RPred = GetPredictionForPlayer(GetOrigin(myHero),target,GetMoveSpeed(target),AnnieR.speed,AnnieR.delay*1000,AnnieR.range,AnnieR.width,false,true)
            if RPred.HitChance == 1 then
            CastSkillShot(_R, RPred.PredPos) end
        elseif AnnieMenu.Prediction.PredictionR:Value() == 3 then
            local RPred = _G.gPred:GetPrediction(target,myHero,AnnieR,true,false)
            if RPred and RPred.HitChance >= 3 then
                    CastSkillShot(_R, RPred.CastPosition) end
        elseif AnnieMenu.Prediction.PredictionR:Value() == 4 then
            local RSpell = IPrediction.Prediction({name="Annie R", range=AnnieR.range, speed=AnnieR.speed, delay=AnnieR.delay, width=AnnieR.width, type="circular", collision=false})
            ts = TargetSelector()
            target = ts:GetTarget(AnnieR.range)
            local x, y = RSpell:Predict(target)
            if x > 2 then
                CastSkillShot(_R, y.x, y.y, y.z) end
        elseif AnnieMenu.Prediction.PredictionR:Value() == 5 then
            local RPrediction = GetCircularAOEPrediction(target,AnnieR)
            if RPrediction.hitChance > 0.9 then
                CastSkillShot(_R, RPrediction.castPos)
            end
        end
    end
end
    
function Auto()
    if AnnieMenu.Auto.UseQ:Value() then
        if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > AnnieMenu.Auto.MP:Value() then
            if CanUseSpell(myHero,_Q) == READY then
                if ValidTarget(target, AnnieQ.range) then
                    useQ(target)
                end
            end
        end
    end
    if AnnieMenu.Auto.UseW:Value() then
        if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > AnnieMenu.Auto.MP:Value() then
            if CanUseSpell(myHero,_W) == READY then
                if ValidTarget(target, AnnieW.range) then
                    useW(target)
                end
            end
        end
    end
    if AnnieMenu.Auto.UseE:Value() then
        if 100*GetCurrentMana(myHero)/GetMaxMana(myHero) > AnnieMenu.Auto.MP:Value() then
            if CanUseSpell(myHero,_E) == READY then
                if ValidTarget(target, 1000) then
                    useE(target)
                end
            end
        end
    end
end

function LastHit()
    if Mode() == "LaneClear" then
        for _, minion in pairs(minionManager.objects) do
            if GetTeam(minion) == MINION_ENEMY then
                if ValidTarget(minion, AnnieQ.range) then
                    if AnnieMenu.LastHit.UseQ:Value() then
                        if CanUseSpell(myHero,_Q) == READY and AA == true then
                            local AnnieQDmg = (20*GetCastLevel(myHero,_Q)+60)+(0.6*GetBonusAP(myHero))
                            if GetCurrentHP(minion) < AnnieQDmg then
                                useQ(minion)
                            end
                        end
                    end
                end
            end
        end
    end
end
    
function Combo()
    if Mode() == "Combo" then
        if AnnieMenu.Combo.UseQ:Value() then
            if CanUseSpell(myHero,_Q) == READY and AA == true then
                if ValidTarget(target, AnnieQ.range) then
                    useQ(target)
                end
            end
        end
        if AnnieMenu.Combo.UseW:Value() then
            if CanUseSpell(myHero,_W) == READY and AA == true then
                if ValidTarget(target, AnnieW.range) then
                    useW(target)
                end
            end
        end
        if AnnieMenu.Combo.UseE:Value() then
            if CanUseSpell(myHero,_E) == READY then
                if ValidTarget(target, 1000) then
                    useE(target)
                end
            end
        end
        if AnnieMenu.Combo.UseR:Value() then
            if CanUseSpell(myHero,_R) == READY then
                if ValidTarget(target, AnnieR.range) then
                    if 100*GetCurrentHP(target)/GetMaxHP(target) < AnnieMenu.Misc.HP:Value() then
                        if EnemiesAround(myHero, AnnieR.range) >= AnnieMenu.Misc.X:Value() then
                            useR(target)
                        end
                    end
                end
            end
        end
    end
end
    
function LevelUp()
    if AnnieMenu.Misc.LvlUp:Value() then
        if AnnieMenu.Misc.AutoLvlUp:Value() == 1 then
            leveltable = {_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
            if GetLevelPoints(myHero) > 0 then
                DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
            end
        elseif AnnieMenu.Misc.AutoLvlUp:Value() == 2 then
            leveltable = {_Q, _E, _W, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
            if GetLevelPoints(myHero) > 0 then
                DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
            end
        elseif AnnieMenu.Misc.AutoLvlUp:Value() == 3 then
            leveltable = {_W, _Q, _E, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
            if GetLevelPoints(myHero) > 0 then
                DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
            end
        elseif AnnieMenu.Misc.AutoLvlUp:Value() == 4 then
            leveltable = {_W, _E, _Q, _W, _W, _R, _W, _E, _W, _E, _R, _E, _E, _Q, _Q, _R, _Q, _Q}
            if GetLevelPoints(myHero) > 0 then
                DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
            end
        elseif AnnieMenu.Misc.AutoLvlUp:Value() == 5 then
            leveltable = {_E, _Q, _W, _E, _E, _R, _E, _Q, _E, _Q, _R, _Q, _Q, _W, _W, _R, _W, _W}
            if GetLevelPoints(myHero) > 0 then
                DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
            end
        elseif AnnieMenu.Misc.AutoLvlUp:Value() == 6 then
            leveltable = {_E, _W, _Q, _E, _E, _R, _E, _W, _E, _W, _R, _W, _W, _Q, _Q, _R, _Q, _Q}
            if GetLevelPoints(myHero) > 0 then
                DelayAction(function() LevelSpell(leveltable[GetLevel(myHero) + 1 - GetLevelPoints(myHero)]) end, 0.5)
            end
        end
    end
end
