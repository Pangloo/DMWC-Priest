local DMW = DMW
DMW.Rotations.PRIEST = {}
local Priest = DMW.Rotations.PRIEST
local UI = DMW.UI



function Priest.Settings()
        UI.AddHeader("DPS")
        UI.AddToggle("Pull Spell", nil, 1)
        UI.AddToggle("Shadow Word: Pain", nil, 1)
        UI.AddToggle("Smite", nil, 1)
        UI.AddToggle("Heal", nil, 1)
        UI.AddRange("Mana Cut Off", nil, 0, 100, 1, 50)
        UI.AddHeader("Defensives")
        UI.AddToggle("Use Lesser Heal", nil, 1)
        UI.AddRange("Heal Percent", nil, 0, 100, 5, 40)
        UI.AddToggle("Power Word: Shield", nil, 1)
        UI.AddRange("Shield Percent", nil, 0, 100, 5, 70)
        UI.AddToggle("Renew", nil, 1)
        UI.AddRange("Renew Percent", nil, 0, 100, 5, 70)
end