local function QuickNPC(Name, PrintName, SpawnName, Race, Distance, Model)
	local NPC = {}
	NPC.Name = Name
	NPC.PrintName = PrintName
	NPC.SpawnName = SpawnName
	NPC.Race = Race
	NPC.DistanceRetreat = Distance
	NPC.Model = Model
	return NPC
end
local function AddBool(Table, IsFrozen, IsInvincible, IsIdle)
		Table.Frozen = IsFrozen
		Table.Invincible = IsInvincible
		Table.Idle = IsIdle
	return Table
end
local function AddMultiplier(Table, Health, Damage)
	Table.HealthPerLevel = Health
	Table.DamagePerLevel = Damage
	return Table
end
local function AddDrop(Table, Name, Chance, Min, Max)
	Table.Drops = Table.Drops or {}
	Table.Drops[Name] = {Chance = Chance, Min = Min, Max = Max}
	return Table
end

local NPC = QuickNPC("combine_thumper", "Combine Thumper", "prop_physics", nil, nil, "models/props_combine/CombineThumper001a.mdl")
NPC = AddMultiplier(NPC, 5)
NPC = AddBool(NPC, true, false, false)
Register.NPC(NPC)
