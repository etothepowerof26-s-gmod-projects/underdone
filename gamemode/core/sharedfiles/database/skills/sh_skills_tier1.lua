local Skill = {}
Skill.Name = "skill_basictraining"
Skill.PrintName = "Basic Training"
Skill.Icon = "icons/weapon_pistol"
Skill.Desc = {}
Skill.Desc["story"] = "It's time for basic training!"
Skill.Desc[1] = "Increases dexterity by 2"
Skill.Desc[2] = "Increases dexterity by 4"
Skill.Desc[3] = "Increases dexterity by 7"
Skill.Tier = 1
Skill.Levels = 3
function Skill:OnSet(Player, SkillLevel, OldSkillLevel)
	local StatTable = {}
	StatTable[0] = 0
	StatTable[1] = 2
	StatTable[2] = 4
	StatTable[3] = 7
	Player:AddStat("stat_dexterity", StatTable[SkillLevel] - StatTable[OldSkillLevel])
end
Register.Skill(Skill)

local Skill = {}
Skill.Name = "skill_closecombat"
Skill.PrintName = "Close Quarters Combat"
Skill.Icon = "icons/junk_gnome"
Skill.Desc = {}
Skill.Desc["story"] = "Be trained by the pros."
Skill.Desc[1] = "Increases strength by 1"
Skill.Desc[2] = "Increases strength by 3"
Skill.Desc[3] = "Increases strength by 5"
Skill.Tier = 1
Skill.Levels = 3
function Skill:OnSet(Player, SkillLevel, OldSkillLevel)
	local StatTable = {}
	StatTable[0] = 0
	StatTable[1] = 1
	StatTable[2] = 3
	StatTable[3] = 5
	Player:AddStat("stat_strength", StatTable[SkillLevel] - StatTable[OldSkillLevel])
end
Register.Skill(Skill)

local Skill = {}
Skill.Name = "skill_hexbones"
Skill.PrintName = "Hexagonal Leg Bones"
Skill.Icon = "icons/junk_shoe"
Skill.Desc = {}
Skill.Desc["story"] = "Your regular leg bone structure is bio-modded to a hexagonal, lighter one."
Skill.Desc[1] = "Increases agility by 1"
Skill.Desc[2] = "Increases agility by 2"
Skill.Tier = 1
Skill.Levels = 2
function Skill:OnSet(Player, SkillLevel, OldSkillLevel)
	local StatTable = {}
	StatTable[0] = 0
	StatTable[1] = 1
	StatTable[2] = 2
	Player:AddStat("stat_agility", StatTable[SkillLevel] - StatTable[OldSkillLevel])
end
Register.Skill(Skill)

local Skill = {}
Skill.Name = "skill_consumeless"
Skill.PrintName = "Consume Less!"
Skill.Icon = "icons/junk_metalcan2"
Skill.Desc = {}
Skill.Desc["story"] = "More sustenance from less food (health kits too)."
Skill.Desc[1] = "You get 15% more health"
Skill.Tier = 1
Skill.Levels = 1
Skill.Hooks = {}
Skill.Hooks["food_mod"] = function(Player, SkillLevel, HealthToAdd)
	if SkillLevel > 0 then
		HealthToAdd = HealthToAdd + (HealthToAdd * (15 / 100))
	end
	return HealthToAdd
end
Register.Skill(Skill)

local Skill = {}
Skill.Name = "skill_barter"
Skill.PrintName = "Barter"
Skill.Icon = "icons/item_cash"
Skill.Desc = {}
Skill.Desc["story"] = "You know how to bargain with the shop keeper."
Skill.Desc[1] = "You get a 3% discount on all items"
Skill.Desc[2] = "You get a 5% discount on all items"
Skill.Tier = 1
Skill.Levels = 2
Skill.Hooks = {}
Skill.Hooks["price_mod"] = function(Player, SkillLevel, Price)
	if SkillLevel > 0 then
		local Discount = 3
		if SkillLevel == 2 then Discount = 5 end
		Price = Price - (Price * (Discount / 100))
	end
	return Price
end
Register.Skill(Skill)

local Skill = {}
Skill.Name = "skill_scavange"
Skill.PrintName = "Scavanger"
Skill.Icon = "icons/item_wood"
Skill.Desc = {}
Skill.Desc["story"] = "You become more experienced at scavenging for resources."
Skill.Desc[1] = "Increases max resources found by 1"
Skill.Desc[2] = "Increases max resources found by 2"
Skill.Tier = 1
Skill.Levels = 2
Skill.Hooks = {}
Skill.Hooks["resouce_mod"] = function(Player, SkillLevel, Item, MaxAmount)
	if SkillLevel > 0 then
		local AddMaxAmount = 1
		if SkillLevel == 2 then AddMaxAmount = 2 end
		MaxAmount = MaxAmount + AddMaxAmount
	end
	return Item, MaxAmount
end
Register.Skill(Skill)
