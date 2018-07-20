local Skill = {}
Skill.Name = "skill_paralyzepoison"
Skill.PrintName = "Paralyze poison"
Skill.Icon = "icons/weapon_axe"
Skill.Desc = {}
Skill.Desc["story"] = "Augments your blade with a deadly paralyzing poison"
Skill.Desc[1] = "Every melee attack has a 5% chance to paralyze for 2 seconds"
Skill.Desc[2] = "Every melee attack has a 8% chance to paralyze for 4 seconds"
Skill.Tier = 2
Skill.Levels = 2
function Skill:BulletCallBack(Player, Skill, Trace, DamageInfo)
	if not SERVER then return end
	local TraceEntity = Trace.Entity
	if Player:IsMelee() and Skill > 0 and TraceEntity:IsNPC() and TraceEntity.Race ~= "human" then
		local Chance = 0
		local Time = 0
		if Skill == 1 then Chance = 5 Time = 2 end
		if Skill == 2 then Chance = 8 Time = 4 end
		if  math.random(1, 100 / Chance) == 1 then
			TraceEntity:Stun(Time, 0.1 / Skill)
		end
	end
end
Register.Skill(Skill)

local Skill = {}
Skill.Name = "skill_marksman"
Skill.PrintName = "Marks Man"
Skill.Icon = "icons/weapon_sniper1"
Skill.SkillNeeded = "skill_basictraining"
Skill.Desc = {}
Skill.Desc["story"] = "Learn to master ranged weapons."
Skill.Desc["SkillNeeded"] = "Basic Training"
Skill.Desc[1] = "Increases dexterity by 4"
Skill.Desc[2] = "Increases dexterity by 5"
Skill.Desc[3] = "Increases dexterity by 7"
Skill.Desc[4] = "Increases dexterity by 10"
Skill.Tier = 2
Skill.Levels = 4
function Skill:OnSet(Player, SkillLevel, OldSkillLevel)
	local StatTable = {}
	StatTable[0] = 0
	StatTable[1] = 4
	StatTable[2] = 5
	StatTable[3] = 7
	StatTable[4] = 10
	Player:AddStat("stat_dexterity", StatTable[SkillLevel] - StatTable[OldSkillLevel])
end
Register.Skill(Skill)

local Skill = {}
Skill.Name = "skill_brutal"
Skill.PrintName = "Brutal"
Skill.SkillNeeded = "skill_closecombat"
Skill.Icon = "icons/weapon_pipe"
Skill.Desc = {}
Skill.Desc["story"] = "Your anger and brutality give you power."
Skill.Desc["SkillNeeded"] = "Close Quarters Combat"
Skill.Desc[1] = "Increases strength by 3"
Skill.Desc[2] = "Increases strength by 4"
Skill.Desc[3] = "Increases strength by 8"
Skill.Tier = 2
Skill.Levels = 3
function Skill:OnSet(Player, SkillLevel, OldSkillLevel)
	local StatTable = {}
	StatTable[0] = 0
	StatTable[1] = 3
	StatTable[2] = 4
	StatTable[3] = 8
	Player:AddStat("stat_strength", StatTable[SkillLevel] - StatTable[OldSkillLevel])
end
Register.Skill(Skill)

local Skill = {}
Skill.Name = "skill_mechheart"
Skill.PrintName = "Mech Heart"
Skill.Icon = "icons/item_healthkit"
Skill.SkillNeeded = "skill_consumeless"
Skill.Desc = {}
Skill.Desc["story"] = "Your old heart is enhanced by hydraulics, increasing blood flow and overall health."
Skill.Desc["SkillNeeded"] = "Consume Less!"
Skill.Desc[1] = "Increases max health by 10"
Skill.Desc[2] = "Increases max health by 20"
Skill.Desc[3] = "Increases max health by 35"
Skill.Tier = 2
Skill.Levels = 3
function Skill:OnSet(Player, SkillLevel, OldSkillLevel)
	local StatTable = {}
	StatTable[0] = 0
	StatTable[1] = 10
	StatTable[2] = 20
	StatTable[3] = 35
	Player:AddStat("stat_maxhealth", StatTable[SkillLevel] - StatTable[OldSkillLevel])
end
Register.Skill(Skill)

local Skill = {}
Skill.Name = "skill_momentum"
Skill.PrintName = "Momentum"
Skill.Icon = "icons/junk_gnome"
Skill.Desc = {}
Skill.Desc["story"] = "Learn to use your momentum as a weapon."
Skill.Desc[1] = "Every melee attack has a 0.2% more damage for every kilogram of weight in your inventory"
Skill.Tier = 2
Skill.Levels = 1
Skill.Hooks = {}
Skill.Hooks["damage_mod"] = function(Player, SkillLevel, Damage)
	if Player:IsMelee() and SkillLevel > 0 then
		Damage = Damage + (Damage * ((0.2 * (Player.Weight or 0)) / 100))
	end
	return Damage
end
Register.Skill(Skill)

local Skill = {}
Skill.Name = "skill_leadcurrency"
Skill.PrintName = "Lead Currency"
Skill.Icon = "icons/item_pistolammobox"
Skill.Desc = {}
Skill.Desc["story"] = "You can recover your old bullets from the bodies of the fallen, but it can be expensive."
Skill.Desc[1] = "10% more ammo drops but 5% less money drops"
Skill.Tier = 2
Skill.Levels = 1
Skill.Hooks = {}
Skill.Hooks["drop_mod"] = function(Player, SkillLevel, Item, Info)
	if SkillLevel > 0 then
		local ItemTable = ItemTable(Item)
		if ItemTable.AmmoAmount then
			Player.Chance = math.Clamp(Info.Chance + 10, 0, 100)
		end
		if ItemTable.Name == "money" then
			Player.Chance = math.Clamp(Info.Chance - 5, 0, 100)
		end
	end
	return Item, Info
end
Register.Skill(Skill)
