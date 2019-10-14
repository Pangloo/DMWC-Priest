local DMW = DMW
DMW.Rotations.PRIEST = {}
local Priest = DMW.Rotations.PRIEST
local UI = DMW.UI



function Priest.Settings()
        UI.HUD.Options = {
                [1] = {
                    TargetLock = {
                        [1] = {Text = "Enemy Target Lock |cFF00FF00On", Tooltip = ""},
                        [2] = {Text = "Enemy Target Lock |cFFFFFF00Off", Tooltip = ""}
                        }
                    }
                }
                
--[[         UI.AddHeader("General Options")
            UI.AddToggle("Auto Mage Water",nil) ]]
        UI.AddHeader("Party Healing")
            UI.AddToggle("Five Second Rule", "Set time to not break 5 second rule")
            UI.AddRange("Five Second Cutoff", "Set time to not break 5 second rule", 0, 5, 0.1, 4.5)
            UI.AddToggle("Fort Buff Spread",nil)
            UI.AddToggle("Fuck Yeah", "Be Everyones Best Friend!")
            UI.AddToggle("Party - Heal",nil)
            UI.AddRange("Party - Heal Percent", nil, 0, 100, 5 ,50)
            UI.AddToggle("Party - Flash Heal",nil)
            UI.AddRange("Party - Flash Heal Percent", nil, 0, 100, 5 ,50)
            UI.AddToggle("Party - Lesser Heal",nil)
            UI.AddRange("Party - Lesser Heal Percent", nil, 0, 100, 5 ,50)
            UI.AddToggle("Party - Shield",nil)
            UI.AddRange("Party - Shield Percent", nil, 0, 100, 5 ,50)     
            UI.AddToggle("Party - Renew",nil)
            UI.AddRange("Party - Renew Percent", nil, 0, 100, 5 ,50)
            UI.AddRange("Renew Count Limit",nil,0,10,1,3)
            UI.AddToggle("Auto Dispel",nil)
        UI.AddHeader("Spell Ranks - 0 Means MAX RANK")
            UI.AddRange("Heal Rank", nil, 0, 4, 1, 0)
            UI.AddRange("Flash Heal Rank", nil, 0, 7, 1, 0)
            UI.AddRange("Lesser Heal Rank", nil, 0, 3, 1, 0)
            UI.AddRange("Shield Rank", nil, 0, 10, 1, 0)
            UI.AddRange("Renew Rank", nil, 0, 10, 1, 0)
            UI.AddRange("Fort Rank", nil, 0, 6, 1, 1)
        UI.AddHeader("DPS")
            UI.AddToggle("DPS Stuff")
            UI.AddDropdown("Pull Spell", nil,{"Shadowword: Pain", "Smite", "Holy Fire", "Mind Blast", "Nothing"}, 5)
            UI.AddToggle("Auto Target Quest Units", nil, false)
            UI.AddToggle("Shadow Word: Pain", nil, 1)
            UI.AddToggle("Smite", nil, 1)
            UI.AddToggle("Holy Fire", nil)
            UI.AddToggle("Mind Blast", nil, 1)
            UI.AddToggle("Ignore Melee Aggro", nil)
            --UI.AddToggle("Heal", nil, 1)
            UI.AddToggle("Mind Blast Snipe", nil)
            UI.AddRange("Snipe TTD", nil, 0, 10, 0.1, 3)
            UI.AddRange("Mana Cut Off", "Mana Cut off for Smite and Mind blast", 0, 100, 1, 50)
        UI.AddHeader("Defensives")
            UI.AddToggle("Auto Inner Fire", nil)
            UI.AddToggle("Auto Shadowguard", nil)
            UI.AddToggle("Auto Fade", nil)
            UI.AddToggle("OoC Shield", nil)
            UI.AddToggle("Use Lesser Heal", nil, 1)
            UI.AddRange("Heal Percent", nil, 0, 100, 5, 40)
            UI.AddToggle("Power Word: Shield", nil, 1)
            UI.AddRange("Shield Percent", nil, 0, 100, 5, 70)
            UI.AddToggle("Renew", nil, 1)
            UI.AddRange("Renew Percent", nil, 0, 100, 5, 70)
end