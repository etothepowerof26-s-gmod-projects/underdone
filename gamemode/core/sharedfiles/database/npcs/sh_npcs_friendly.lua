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
local function AddDrop(Table, Name, Chance, Min, Max,strDefaultChance)
	Table.Drops = Table.Drops or {}
	Table.Drops[Name] = {Chance = Chance, Min = Min, Max = Max}
	return Table
end

local NPC = QuickNPC("rebel_smg", "Rebel Guard", "npc_combine_s", "human", 50, "models/Humans/Group03/Male_02.mdl")
NPC = AddBool(NPC, false, true, false)
NPC = AddMultiplier(NPC, 100, 7)
NPC.Weapon = "weapon_smg1"
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("human_turret(f)", "Human Turret(Floor)", "npc_turret_floor", "human")
NPC = AddMultiplier(NPC, 20, 3)
NPC = AddBool(NPC, true, false, false)
NPC.Accuracy = WEAPON_PROFICIENCY_POOR
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("shop_general", "Jay", "npc_eli", "human")
NPC = AddBool(NPC, false, true, true)
NPC.Shop = "shop_general"
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("shop_ranged", "Becky", "npc_breen", "human", nil, "models/Humans/Group03/Female_06.mdl")
NPC = AddBool(NPC, false, true, true)
NPC.Shop = "shop_ranged"
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("shop_melee", "Patrick", "npc_breen", "human", nil, "models/Humans/Group03/Male_05.mdl")
NPC = AddBool(NPC, false, true, true)
NPC.Shop = "shop_melee"
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("shop_armor", "Crystal", "npc_breen", "human", nil, "models/Humans/Group03/Female_04.mdl")
NPC = AddBool(NPC, false, true, true)
NPC.Shop = "shop_armor"
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("bank_npc", "Egmont", "npc_citizen", "human", nil, "models/Humans/Group03/Male_01.mdl")
NPC = AddBool(NPC, false, true, true)
NPC.Bank = true
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("appearance_npc", "Faith", "npc_breen", "human", nil, "models/alyx.mdl")
NPC = AddBool(NPC, false, true, true)
NPC.Appearance = true
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("npc_auctionhouse", "Camron", "npc_citizen", "human", nil, "models/Humans/Group03/Male_05.mdl")
NPC = AddBool(NPC, false, true, true)
NPC.Auction = true
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("shop_books", "Richard", "npc_citizen", "human", nil, "models/Humans/Group03/Male_02.mdl")
NPC = AddBool(NPC, false, true, true)
NPC.Shop = "shop_books"
NPC.Deathdistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("quest_Odessa", "Odessa", "npc_breen", "human", nil, "models/odessa.mdl")
NPC = AddBool(NPC, false, true, true)
NPC.Quest = {"quest_killantlionboss"}
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("quest_Adam", "Adam", "npc_breen", "human", nil, "models/Humans/Group03/Male_02.mdl")
NPC = AddBool(NPC, false, true, true)
NPC.Quest = {"quest_killzombies", "quest_monkeybusiness", "quest_killantlion",
"quest_zombieblood", "quest_beer", "quest_killelite", "quest_killzombine",
"quest_cooking"}
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("quest_kleiner", "Dr. Kleiner", "npc_kleiner", "human")
NPC = AddBool(NPC, false, true, true)
NPC.Quest = {"quest_killcombinethumper", "quest_arsenalupgrade", "quest_killcombine",
"quest_toolwrench", "quest_revolver", "quest_armorupgrade","quest_missionthors",
"quest_fortification","quest_oil", "quest_crafting",}
NPC.DeathDistance = 14
Register.NPC(NPC)

local NPC = QuickNPC("quest_charple", "Some Burnt Guy", "npc_citizen", "human", nil, "models/player/charple.mdl")
NPC = AddBool(NPC, false, true, true)
NPC.Quest = { "quest_cquest1", "quest_cquest2", "quest_detergentq"}
NPC.Deathdistance = 14
Register.NPC(NPC)
