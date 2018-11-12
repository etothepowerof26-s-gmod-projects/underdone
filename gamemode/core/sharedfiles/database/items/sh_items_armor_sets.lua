local function AddBuff(AddTable, Buff, Amount)
	AddTable.Buffs = AddTable.Buffs or {}
	AddTable.Buffs[Buff] = Amount
	return AddTable
end

local EquipmentSet = {}
EquipmentSet.Name = "armor_antlion"
EquipmentSet.PrintName = "Antlion Warrior"
EquipmentSet.Items = {}
EquipmentSet.Items[1] = "armor_chest_antlion"
EquipmentSet.Items[2] = "armor_helm_antlionhelm"
EquipmentSet.Items[3] = "armor_shoulder_antlion"
EquipmentSet.Items[4] = "armor_belt_antlion"
AddBuff(EquipmentSet, "stat_maxhealth", 25)
AddBuff(EquipmentSet, "stat_strength", 2)
Register.EquipmentSet(EquipmentSet)

local EquipmentSet = {}
EquipmentSet.Name = "armor_cyborg"
EquipmentSet.PrintName = "Biomechanical Being"
EquipmentSet.Items = {}
EquipmentSet.Items[1] = "armor_chest_cyborg"
EquipmentSet.Items[2] = "armor_helm_cyborg"
EquipmentSet.Items[3] = "armor_shoulder_cyborg"
EquipmentSet.Items[4] = "armor_belt_cyborg"
AddBuff(EquipmentSet, "stat_dexterity", 5)
AddBuff(EquipmentSet, "stat_agility", 3)
Register.EquipmentSet(EquipmentSet)

local EquipmentSet = {}
EquipmentSet.Name = "twisted_souls"
EquipmentSet.PrintName = "Twisted Souls"
EquipmentSet.Items = {}
EquipmentSet.Items[1] = "armor_shield_skele"
EquipmentSet.Items[2] = "weapon_melee_skele"
AddBuff(EquipmentSet, "stat_strength", 10)
AddBuff(EquipmentSet, "stat_agility", 5)
Register.EquipmentSet(EquipmentSet)

local EquipmentSet = {}
EquipmentSet.Name = "wraith"
EquipmentSet.PrintName = "The Wraith"
EquipmentSet.Items = {}
EquipmentSet.Items[1] = "armor_chest_skele"
EquipmentSet.Items[2] = "armor_helm_skele"
EquipmentSet.Items[3] = "armor_shoulder_skele"
EquipmentSet.Items[4] = "armor_belt_skele"
AddBuff(EquipmentSet, "stat_strength", 30)
AddBuff(EquipmentSet, "stat_maxhealth", 50)
Register.EquipmentSet(EquipmentSet)

local EquipmentSet = {}
EquipmentSet.Name = "ofdefence"
EquipmentSet.PrintName = "The Clash"
EquipmentSet.Items = {}
EquipmentSet.Items[1] = "armor_shield_tyrant"
EquipmentSet.Items[2] = "weapon_melee_tyrant"
AddBuff(EquipmentSet, "stat_maxhealth", 25)
Register.EquipmentSet(EquipmentSet)

local EquipmentSet = {}
EquipmentSet.Name = "armor_tyrant"
EquipmentSet.PrintName = "The Tyrant"
EquipmentSet.Items = {}
EquipmentSet.Items[1] = "armor_chest_tyrant"
EquipmentSet.Items[2] = "armor_helm_tyrant"
EquipmentSet.Items[3] = "armor_shoulder_tyrant"
EquipmentSet.Items[4] = "armor_belt_tyrant"
AddBuff(EquipmentSet, "stat_maxhealth", 250)
Register.EquipmentSet(EquipmentSet)

local EquipmentSet = {}
EquipmentSet.Name = "overseer"
EquipmentSet.PrintName = "The Overseer"
EquipmentSet.Items = {}
EquipmentSet.Items[1] = "armor_chest_bio"
EquipmentSet.Items[2] = "armor_helm_bio"
EquipmentSet.Items[3] = "armor_shoulder_bio"
EquipmentSet.Items[4] = "armor_belt_bio"
AddBuff(EquipmentSet, "stat_dexterity", 30)
AddBuff(EquipmentSet, "stat_maxhealth", 50)
Register.EquipmentSet(EquipmentSet)