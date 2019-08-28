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
        if Unit.Distance < 10 and Player.Pointer == Unit.Target then
            MeleeAggro = true
        end
    end
end

local function DPS()
    if Setting("Shadow Word: Pain") then
        for _, Unit in ipairs(Player40Y) do
            if Debuff.ShadowWordPain:Refresh(Unit) and (Unit.TTD - Debuff.ShadowWordPain:Remain(Unit)) > 4 or not Debuff.ShadowWordPain:Exist(Unit) then
                if Spell.ShadowWordPain:Cast(Unit) then
                    return true
                end
            end
        end
    end

    if Setting("Smite") and Target and Target.ValidEnemy and not MeleeAggro and Power > Setting("Mana Cut Off") then
        Spell.Smite:Cast(Target)
    end

    if not Player.Moving and not IsCurrentSpell(Spell.Shoot.SpellID) and (DMW.Time - ShootTime) > 0.6 then
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
    if not Buff.Renew:Exist(Player) and Setting("Renew") and (HP < Setting("Renew Percent") or (not Player.Combat and HP < 80)) and Power > 15 then
        if Spell.Renew:Cast(Player) then return true end
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
        if Setting("Pull Spell") and Target and Target.ValidEnemy and not Debuff.ShadowWordPain:Exist(Target) then
            if Spell.ShadowWordPain:Cast(Target) then
                return true
            end
        end
        if DEF() then return true end
        if Player.Combat then
            Player:AutoTarget(40, true)
            if DPS() then
                return true
            end
        end
    end
end