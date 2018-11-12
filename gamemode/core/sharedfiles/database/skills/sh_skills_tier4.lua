local Skill = {}
Skill.Name = "skill_mule"
Skill.PrintName = "Mule"
Skill.Icon = "icons/junk_box1"
Skill.Desc = {}
Skill.Desc["story"] = "You learn the way of the mule and can carry more stuff in your inventory."
Skill.Desc[1] = "Increases max weight by 3"
Skill.Desc[2] = "Increases max weight by 5"
Skill.Desc[3] = "Increases max weight by 8"
Skill.Tier = 4
Skill.Levels = 3
function Skill:OnSet(Player, SkillLevel, OldSkillLevel)
	local StatTable = {}
	StatTable[0] = 0
	StatTable[1] = 3
	StatTable[2] = 5
	StatTable[3] = 8
	Player:AddStat("stat_maxweight", StatTable[SkillLevel] - StatTable[OldSkillLevel])
end
Register.Skill(Skill)

local Skill = {}
Skill.Name = "skill_soldier"
Skill.PrintName = "Soldier"
Skill.Icon = "icons/weapon_sniper1"
Skill.Desc = {}
Skill.Desc["story"] = "You become proficient with ranged weapons that use rifle ammo."
Skill.Desc[1] = "Every weapon that uses rifle ammo does 3% more damage"
Skill.Desc[2] = "Every weapon that uses rifle ammo does 7% more damage"
Skill.Tier = 4
Skill.Levels = 2
Skill.Hooks = {}
Skill.Hooks["damage_mod"] = function(Player, SkillLevel, Damage)
	if not Player:IsMelee() and Player:GetActiveAmmoType() == "ar2" and SkillLevel > 0 then
		local Percent = 3
		if SkillLevel == 2 then Percent = 7 end
		Damage = Damage + (Damage * (Percent / 100))
	end
	return Damage
end
Register.Skill(Skill)

local Skill = {}
Skill.Name = "skill_gunslinger"
Skill.PrintName = "Gun Slingger"
Skill.Icon = "icons/weapon_pistol"
Skill.Desc = {}
Skill.Desc["story"] = "Weapons that use small ammo just click with you."
Skill.Desc[1] = "Every weapon that uses small ammo does 6% more damage"
Skill.Desc[2] = "Every weapon that uses small ammo does 12% more damage"
Skill.Tier = 4
Skill.Levels = 2
Skill.Hooks = {}
Skill.Hooks["damage_mod"] = function(Player, SkillLevel, Damage)
	if not Player:IsMelee() and Player:GetActiveAmmoType() == "smg1" and SkillLevel > 0 then
		local Percent = 6
		if SkillLevel == 2 then Percent = 12 end
		Damage = Damage + (Damage * (Percent / 100))
	end
	return Damage
end
Register.Skill(Skill)

local Skill = {}
Skill.Name = "skill_hunter"
Skill.PrintName = "Hunter"
Skill.Icon = "icons/weapon_shotgun"
Skill.Desc = {}
Skill.Desc["story"] = "After hundreds of hunting trips, you are a master of the shotgun."
Skill.Desc[1] = "Every weapon that uses buckshot ammo does 5% more damage"
Skill.Desc[2] = "Every weapon that uses buckshot ammo does 7% more damage"
Skill.Desc[3] = "Every weapon that uses buckshot ammo does 10% more damage"
Skill.Tier = 4
Skill.Levels = 3
Skill.Hooks = {}
Skill.Hooks["damage_mod"] = function(Player, SkillLevel, Damage)
	if not Player:IsMelee() and Player:GetActiveAmmoType() == "buckshot" and SkillLevel > 0 then
		local Percent = 5
		if SkillLevel == 2 then Percent = 7 end
		if SkillLevel == 3 then Percent = 10 end
		Damage = Damage + (Damage * (Percent / 100))
	end
	return Damage
end
Register.Skill(Skill)
