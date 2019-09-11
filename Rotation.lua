local DMW = DMW
local Priest = DMW.Rotations.PRIEST
local Player, Buff, Debuff, Health, Power, Spell, Target, Trait, Talent, Item, GCD, CDs, HUD, Player40Y, Player40YC, Friends40Y, Friends40YC
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local ShootTime = GetTime()

local function Locals()
    Player = DMW.Player
    Buff = Player.Buffs
    Debuff = Player.Debuffs
    Health = Player.Health
    HP = Player.HP
    Power = Player.PowerPct
    Spell = Player.Spells
    Talent = Player.Talents
    Trait = Player.Traits
    Item = Player.Items
    Target = Player.Target or false
    GCD = Player:GCD()
    HUD = DMW.Settings.profile.HUD
    CDs = Player:CDs() and Target and Target.TTD > 5 and Target.Distance < 5
    Friends40Y, Friends40YC = Player:GetFriends(40)
    Player40Y, Player40YC = Player:GetEnemies(40)
    MeleeAggro = false
    for _, Unit in ipairs(Player40Y) do
        if Unit.Distance < 6 and Player.Pointer == Unit.Target then
            MeleeAggro = true
        end
    end
end

local function FiveSecond()
    if FiveSecondRuleTime == nil then
        FiveSecondRuleTime = DMW.Time 
    end
    local FiveSecondRuleCount = DMW.Time - FiveSecondRuleTime
    if FiveSecondRuleCount > 5 then
        FiveSecondRuleTime = DMW.Time 
    end
    if Setting("Five Second Rule") and (FiveSecondRuleCount) >= Setting("Five Second Cutoff") then return true end
    --print(FiveSecondRuleCount)
end

local function HEAL()
    if Friends40YC >= 1 then
        if Setting("Fort Buff Spread") then
            for _, Friend in ipairs(Friends40Y) do
                if not Buff.PowerWordFortitude:Exist(Friend) then
                    if Spell.PowerWordFortitude:Cast(Friend) then return true end
                end
            end 
        end
        for _, Friend in ipairs(Friends40Y) do
            if Setting("Party - Heal") and Friend.HP < Setting("Party - Heal Percent") and Spell.Heal:Cast(Friend) then FiveSecondRuleTime = DMW.Time
                return true end
        end
        for _, Friend in ipairs(Friends40Y) do
            if Setting("Party - Flash Heal") and Spell.FlashHeal:IsReady() and Friend.HP < Setting("Party - Flash Heal Percent") and Spell.FlashHeal:Cast(Friend) then FiveSecondRuleTime = DMW.Time
                return true end
        end
        for _, Friend in ipairs(Friends40Y) do
            if Setting("Party - Lesser Heal") and Spell.LesserHeal:IsReady() and Friend.HP < Setting("Party - Lesser Heal Percent") and Spell.LesserHeal:Cast(Friend) then FiveSecondRuleTime = DMW.Time
                return true	end
        end
        for _, Friend in ipairs(Friends40Y) do
            if Setting("Party - Shield") and Friend.HP < Setting("Party - Shield Percent") and not Buff.PowerWordShield:Exist(Friend) and not Debuff.WeakenedSoul:Exist(Friend) and Spell.PowerWordShield:Cast(Friend) then FiveSecondRuleTime = DMW.Time
                return true	end
        end
        for _, Friend in ipairs(Friends40Y) do
            if Setting("Party - Renew") and Friend.HP < Setting("Party - Renew Percent") and not Buff.Renew:Exist(Friend) and Spell.Renew:Cast(Friend) then FiveSecondRuleTime = DMW.Time
                return true	end
        end
    end
end

local function DPS()
    if Setting("Shadow Word: Pain") then
        for _, Unit in ipairs(Player40Y) do
            if Debuff.ShadowWordPain:Refresh(Unit) and (Unit.TTD - Debuff.ShadowWordPain:Remain(Unit)) > 4 or not Debuff.ShadowWordPain:Exist(Unit) then
                if Spell.ShadowWordPain:Cast(Unit) then FiveSecondRuleTime = DMW.Time
                    return true
                end
            end
        end
    end

    if Setting("Mind Blast") and not MeleeAggro and Power > Setting("Mana Cut Off") and Spell.MindBlast:IsReady() then
        if IsAutoRepeatSpell(Spell.Shoot.SpellName) then
            MoveForwardStart()
            MoveForwardStop()
            ShootTime = DMW.Time
        end
        if Spell.MindBlast:Cast(Target) then FiveSecondRuleTime = DMW.Time return true end
    end

    if Setting("Smite") and not MeleeAggro and Power > Setting("Mana Cut Off") then
        if Spell.Smite:Cast(Target) then FiveSecondRuleTime = DMW.Time return true end
    end

    if not Player.Moving and not IsAutoRepeatSpell(Spell.Shoot.SpellName) and (DMW.Time - ShootTime) > 0.7 then
        if Spell.Shoot:Cast(Target) then
            ShootTime = DMW.Time
            return true
        end
    end
end

local function DEF()
    if not Buff.PowerWordFortitude:Exist(Player) then 
        if Spell.PowerWordFortitude:Cast(Player) then return true end
    end
	if not Buff.InnerFire:Exist(Player) then 
        if Spell.InnerFire:Cast(Player) then return true end
    end
    if not Buff.Renew:Exist(Player) and Setting("Renew") and (HP <= Setting("Renew Percent") or (not Player.Combat and HP < 80)) and Power > 15 then
        if Spell.Renew:Cast(Player) then FiveSecondRuleTime = DMW.Time return true end
    end
    if Setting("Use Lesser Heal") and HP < Setting("Heal Percent") and Power > 15 then
        if Spell.LesserHeal:Cast(Player) then return true end
    end
    if Player.Combat and Setting("Power Word: Shield") and HP < Setting("Shield Percent") and Power > 30 and not Debuff.WeakenedSoul:Exist(Player) then
        if Spell.PowerWordShield:Cast(Player) then return true end
    end
end

function Priest.Rotation()
    Locals()
    if Rotation.Active() then
        if FiveSecond() then return true end
        if Setting("Pull Spell") and Target and Target.ValidEnemy and not Debuff.ShadowWordPain:Exist(Target) then
            if Spell.ShadowWordPain:Cast(Target) then
                return true
            end
        end
        if DEF() then return true end
        if HEAL() then return true end
        if Player.Combat then
            if not DMW.Player.Equipment[18] and not IsCurrentSpell(Spell.Attack.SpellID) then
                StartAttack()
            end
            if Setting("DPS Stuff") then
                Player:AutoTarget(40, true)
                if DPS() then
                    return true
                end
            end
        end
    end
end