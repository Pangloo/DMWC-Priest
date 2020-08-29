local DMW = DMW
local Priest = DMW.Rotations.PRIEST
local Player, Buff, Debuff, Health, Power, Spell, Target, Trait, Talent, Item, GCD, CDs, HUD, Player40Y, Player40YC, Friends40Y, Friends40YC
local Rotation = DMW.Helpers.Rotation
local Setting = DMW.Helpers.Rotation.Setting
local ShootTime = GetTime()
--test


--------------
----Locals----
--------------
local function Locals()
    Player = DMW.Player
    Buff = Player.Buffs
    Debuff = Player.Debuffs
    Health = Player.Health
    HP = Player.HP
    Power = Player.PowerPct
    Spell = Player.Spells
    DispelSpell = DMW.Enums.DispelSpells
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
    Hastar = Target and Target.ValidEnemy and Target.Facing
    for _, Unit in ipairs(Player40Y) do
        if Unit.Distance < 6 and Player.Pointer == Unit.Target then
            MeleeAggro = true
        end
    end
end


----------------
--Smart Recast--
----------------
local function smartRecast(spell,unit,rank)
    if rank == 0 then
        rank = nil
    end
    if (not Spell[spell]:LastCast() or (DMW.Player.LastCast[1].SuccessTime and (DMW.Time - DMW.Player.LastCast[1].SuccessTime) > 0.7) or 
        not UnitIsUnit(Spell[spell].LastBotTarget, unit.Pointer)) then 
            if Spell[spell]:Cast(unit,rank) then return true end
    end
end


--------------
--5 Sec Rule--
--------------
local function FiveSecond()
    if FiveSecondRuleTime == nil then
        FiveSecondRuleTime = DMW.Time 
    end
    local FiveSecondRuleCount = DMW.Time - FiveSecondRuleTime
    if FiveSecondRuleCount > 6.5 then
        FiveSecondRuleTime = DMW.Time 
    end
    if Setting("Five Second Rule") and ((FiveSecondRuleCount) >= Setting("Five Second Cutoff") or (FiveSecondRuleCount <= 0.4)) then return true end
    --print(FiveSecondRuleCount)
end

---------------
----Healing----
---------------
local function HEAL()
    if Friends40YC > 1 then
        -- Fort Buff on Party   
        if Setting("Fort Buff Spread") and not Player.Combat then
            for _, Friend in ipairs(Friends40Y) do
                if not Buff.PowerWordFortitude:Exist(Friend) and Friend:LineOfSight() then
                    return smartRecast("PowerWordFortitude",Friend,nil)
                end
            end 
        end
        if HUD.Dispel == 1 then
            for _, Friend in ipairs(Friends40Y) do
                if Friend:Dispel(Spell.DispelMagic) then return smartRecast("DispelMagic",Friend,nil) end
            end
        end
        -- Cycle Party HP Values
        for _, Friend in ipairs(Friends40Y) do
            if Friend:LineOfSight() then
                --Party Renew
                if Setting("Party - Renew") and Friend.HP <= Setting("Party - Renew Percent") and not Buff.Renew:Exist(Friend) and Friend:IsTanking() and Buff.Renew:Count() < Setting("Renew Count Limit") then
                    FiveSecondRuleTime = DMW.Time return smartRecast("Renew",Friend,Setting("Renew Rank"))
                end
                -- Party Flash Heal
                if Setting("Party - Flash Heal") and not Player.Moving and Spell.FlashHeal:IsReady() and Friend.HP <= Setting("Party - Flash Heal Percent") then
                    FiveSecondRuleTime = DMW.Time return smartRecast("FlashHeal",Friend,Setting("Flash Heal Rank"))
                end
                -- Party Heal
                if Setting("Party - Heal") and not Player.Moving and Friend.HP <= Setting("Party - Heal Percent") then
                    FiveSecondRuleTime = DMW.Time return smartRecast("Heal",Friend,Setting("Heal Rank"))
                end
                -- Party Lesser Heal
                if Setting("Party - Lesser Heal") and not Player.Moving and Spell.LesserHeal:IsReady() and Friend.HP <= Setting("Party - Lesser Heal Percent") then
                    FiveSecondRuleTime = DMW.Time return smartRecast("LesserHeal",Friend,Setting("Lesser Heal Rank"))
                end
                -- Party Shield
                if Setting("Party - Shield") and Friend.HP <= Setting("Party - Shield Percent") and not Buff.PowerWordShield:Exist(Friend) and not Debuff.WeakenedSoul:Exist(Friend) then
                    FiveSecondRuleTime = DMW.Time return smartRecast("PowerWordShield",Friend,Setting("Shield Rank"))
                end
            end
        end
    end
end

--[[ local function Drink()
    for Bag = 0, 4, 1 do
        for Slot = 1, GetContainerNumSlots(Bag), 1 do
            local ItemID = GetContainerItemID(Bag, Slot)
            if ItemID and ItemID == 21072 then
                UseContainerItem(Bag, Slot)
            end
        end
    end
end ]]

--------------
---DPS Code---
--------------
local function DPS()
    --Shadow Word Pain Spread
    if Setting("Shadow Word: Pain") then
        for _, Unit in ipairs(Player40Y) do
            if not Debuff.ShadowWordPain:Exist(Unit) then FiveSecondRuleTime = DMW.Time
                return smartRecast("ShadowWordPain",Unit)
            end
        end
    end
    --Holy Fire On Target
    if Hastar and not Player.Moving and Setting("Holy Fire") and Spell.HolyFire:IsReady() and Power > Setting("Mana Cut Off") and not Debuff.HolyFire:Exist(Target) then 
        return smartRecast("HolyFire",Target)
    end
    --Mind Blast Cast
    if Hastar and not Player.Moving and Setting("Mind Blast") and (not MeleeAggro or Setting("Ignore Melee Aggro"))  and Power > Setting("Mana Cut Off") and Spell.MindBlast:IsReady() then
            return smartRecast("MindBlast",Target)
    end
    --Smite Cast
    if Hastar and not Player.Moving and Setting("Smite") and (not MeleeAggro or Setting("Ignore Melee Aggro")) and Power > Setting("Mana Cut Off") then
        FiveSecondRuleTime = DMW.Time return Spell.Smite:Cast(Target)
    end
    -- Auto Wand Management
    if Hastar and not Player.Moving and not IsAutoRepeatSpell(Spell.Shoot.SpellName) and (DMW.Time - ShootTime) > 0.3 then
        ShootTime = DMW.Time
        return Spell.Shoot:Cast(Target)
    end
end

local function DEF()
    --Lulwtf
    if Setting("Fuck Yeah") then
        for _, Unit in pairs(DMW.Units) do
            if Unit.Player and Unit.Distance < 30 and Unit:LineOfSight() and not Buff.PowerWordFortitude:Exist(Unit) and not Buff.PrayerOfFortitude:Exist(Unit) then
                return smartRecast("PowerWordFortitude",Unit,Setting("Fort Rank"))
            end
        end
    end
    --Auto Fade
    if Setting("Auto Fade") and Player:IsTanking() and MeleeAggro and Friends40YC > 1 and Spell.Fade:IsReady() then
        return Spell.Fade:Cast(Player)
    end

    --Fortitude Self Check
    if not Buff.PowerWordFortitude:Exist(Player) then 
        return Spell.PowerWordFortitude:Cast(Player)
    end
    --Inner Fire Self Check
	if Setting("Auto Inner Fire") and not Buff.InnerFire:Exist(Player) then 
        return Spell.InnerFire:Cast(Player)
    end
    --ShadowGuard Self Check
    if Setting("Auto Shadowguard") and not Buff.Shadowguard:Exist(Player) then
        return Spell.Shadowguard:Cast(Player)
    end
    --Defensive Renew
    if not Buff.Renew:Exist(Player) and Setting("Renew") and (HP <= Setting("Renew Percent") or (not Player.Combat and HP < 80)) and Power > 15 then
        FiveSecondRuleTime = DMW.Time return smartRecast("Renew",Player,Setting("Renew Rank"))
    end
    --Defensive Lesser Heal
    if Setting("Use Lesser Heal") and HP <= Setting("Heal Percent") and Power > 15 and not Player.moving then
        return smartRecast("LesserHeal",Player,Setting("Lesser Heal Rank"))
    end
    --Defensive Shield
    if (Player.Combat or Setting("OoC Shield")) and Hastar and Setting("Power Word: Shield") and HP <= Setting("Shield Percent") and Power > 30 and not Debuff.WeakenedSoul:Exist(Player) then
        return smartRecast("PowerWordShield",Player,Setting("Shield Rank"))
    end
end

local function Pull()
    if Target and Target.ValidEnemy then
        if Setting("Pull Spell") == 1 and not Debuff.ShadowWordPain:Exist(Target) then
            return smartRecast("ShadowWordPain",Target)
        elseif Setting("Pull Spell") == 2 then
            return smartRecast("Smite",Target)
        elseif Setting("Pull Spell") == 3 then
            return smartRecast("HolyFire",Target)
        elseif Setting("Pull Spell") == 4 then
            return smartRecast("MindBlast",Target)
        end
    end

end

function Priest.Rotation()
    -- Init Locals
    Locals()
    if Rotation.Active() then
        -----------------
        --Out Of Combat--
        -----------------
		        -- Call Defensive Actionlist
        if DEF() then return end
        -- Call Healing Actionlist
        if HEAL() then return end
        if FiveSecond() then return end
		--quest targeting
		if Setting("Auto Target Quest Units") and Player.HP > 90 and Player.PowerPct > 80 then
            if Player:AutoTargetQuest(30, true) then
                return true
            end
        end
        --Cast SWP on target, regardless of combat
        if not Player.Combat then
--[[             if Setting("Auto Mage Water")then
                if Drink() then return end
            end ]]
            if Pull() then return end
        end
        --Mind Blast Snipe (WIP)
        for _, Unit in ipairs(Player40Y) do
            if Hastar and not Player.Moving and Setting("Mind Blast Snipe") and Unit.TTD <= Setting("Snipe TTD") and not Spell.MindBlast:LastCast() then
                if Spell.MindBlast:Cast(Unit) then FiveSecondRuleTime = DMW.Time return end
            end
        end
        -----------------
        -----Combat------
        -----------------
        if Player.Combat then
            -- Auto attack if no wand is equipped
            if Setting("DPS Stuff") then
                -- Auto Target Enemy regardless of target
                Player:AutoTarget(40, true)
                if not DMW.Player.Equipment[18] and not IsCurrentSpell(Spell.Attack.SpellID) and Hastar then
                    StartAttack()
                end
                if HUD.TargetLock == 1 and UnitIsFriend("player", "target") then
                    TargetLastEnemy()
                end
                -- Call DPS Actionlist
                if DPS() then
                    return
                end
            end
        end
    end
end
