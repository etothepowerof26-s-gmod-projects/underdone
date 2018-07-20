local Stat = {}
Stat.Name = "stat_maxhealth"
Stat.PrintName = "Max Health"
Stat.Desc = "The maximum amount of health you can have."
Stat.Default = 100
function Stat:OnSet(ply, intMaxHealth, intOldMaxHealth)
	ply:SetMaxHealth(intMaxHealth)
	ply:SetNWInt("MaxHealth", intMaxHealth)
	if ply:Health() > ply:GetMaxHealth() then
		ply:SetHealth(ply:GetMaxHealth())
	end
end
function Stat:OnSpawn(ply, intMaxHealth)
	ply:SetHealth(intMaxHealth)
end
hook.Add("UD_Hook_PlayerLoad", "PlayerLoadHealth", function(ply)
	ply:SetHealth(ply:GetStat("stat_maxhealth"))
end)
Register.Stat(Stat)

local Stat = {}
Stat.Name = "stat_maxweight"
Stat.Hide = true
Stat.Default = 30
Register.Stat(Stat)

local Stat = {}
Stat.Name = "stat_strength"
Stat.PrintName = "Strength"
Stat.Desc = "The more you have, the more damage your melee attacks will do."
Stat.Default = 1
function Stat:OnSet(ply, Strength, OldStrength)
	--ply:AddStat("stat_maxhealth", (Strength - OldStrength) * 1.5)
end
function Stat:DamageMod(ply, Strength, Damage)
	if ply:IsMelee() then
		Damage = Damage * math.Clamp(Strength / 3, 1, Strength)
	end
	return Damage
end
Register.Stat(Stat)

local Stat = {}
Stat.Name = "stat_dexterity"
Stat.PrintName = "Dexterity"
Stat.Desc = "The more you have, the more damage your ranged attacks will do."
Stat.Default = 1
function Stat:DamageMod(ply, Dexterity, Damage)
	if not ply:IsMelee() then
		Damage = Damage * math.Clamp(Dexterity / 3, 1, Dexterity)
	end
	return Damage
end
Register.Stat(Stat)

local Stat = {}
Stat.Name = "stat_intellect"
Stat.PrintName = "Intellect"
Stat.Desc = ""
Stat.Default = 1
Register.Stat(Stat)

local Stat = {}
Stat.Name = "stat_agility"
Stat.PrintName = "Agility"
Stat.Desc = "The higher this is, the faster you run, reload and attack."
Stat.Default = 1
function Stat:OnSet(ply, Agility, OldAgility)
	ply:AddMoveSpeed((Agility - OldAgility) * 10)
end
function Stat:FireRateMod(ply, Agility, FireRate)
	if not FireRate then return end
	
	FireRate = FireRate * math.Clamp(Agility / 5, 1, Agility)
	return FireRate
end
Register.Stat(Stat)

local Stat = {}
Stat.Name = "stat_luck"
Stat.PrintName = "Luck"
Stat.Desc = "You find yourself to be more lucky. Increased chance of critical hits."
Stat.Default = 1
Register.Stat(Stat)
