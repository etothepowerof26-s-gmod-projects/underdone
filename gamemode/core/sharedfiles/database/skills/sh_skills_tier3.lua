local Skill = {}
Skill.Name = "skill_healthgen"
Skill.PrintName = "Blood Mutation"
Skill.SkillNeeded = "skill_mechheart"
Skill.Icon = "icons/item_healthkit"
Skill.Desc = {}
Skill.Desc["story"] = "Your blood is purposely infected with a bacteria that heals you."
Skill.Desc["SkillNeeded"] = "Mech Heart"
Skill.Desc[1] = "Every 6 seconds, your health goes up by 1% of its max amount"
Skill.Desc[2] = "Every 6 seconds, your health goes up by 2% of its max amount"
Skill.Tier = 3
Skill.Levels = 2
function Skill:OnSet(Player, SkillLevel, OldSkillLevel)
	local Percent = SkillLevel
	timer.Create("UD_health " .. Player:SteamID64(), 6, 0, function()
		if Percent > 0 and IsValid(Player) and Player:Alive() then
			Player:SetHealth(math.Clamp(Player:Health() + (Player:GetMaxHealth() * (Percent / 100)), 0, Player:GetMaxHealth()))
		end
	end)
end
Register.Skill(Skill)

local Skill = {}
Skill.Name = "skill_warriorsfire"
Skill.PrintName = "Warriors Fire"
Skill.SkillNeeded = "skill_paralyzepoison"
Skill.Icon = "icons/weapon_axe"
Skill.Desc = {}
Skill.Desc["story"] = "The fire within you burns hot."
Skill.Desc["SkillNeeded"] = "Paralyze poison"
Skill.Desc[1] = "Every melee attack has a 6% chance to burn for 3 seconds"
Skill.Desc[2] = "Every melee attack has a 8% chance to burn for 7 seconds"
Skill.Tier = 3
Skill.Levels = 2
function Skill:BulletCallBack(Player, Skill, Trace, DamageInfo)
	if not SERVER then return end
	if Player:IsMelee() and Skill > 0 and Trace.Entity:IsNPC() and Trace.Entity.Race ~= "human" and Trace.Entity.Race ~= "antlion" then
		local Chance = 0
		local Time = 0
		if Skill == 1 then Chance = 6 Time = 3 end
		if Skill == 2 then Chance = 8 Time = 7 end
		if  math.random(1, 100 / Chance) == 1 then
			Trace.Entity:IgniteFor(Time, 1, Player)
		end
	end
end
Register.Skill(Skill)

local Skill = {}
Skill.Name = "skill_bulletleech"
Skill.PrintName = "Bullet Leech"
Skill.SkillNeeded = "skill_mechheart"
Skill.Icon = "icons/item_pistolammobox"
Skill.Desc = {}
Skill.Desc["story"] = "Nano-bots are installed on your bullets giving you a chance of stealing some health."
Skill.Desc["SkillNeeded"] = "Mech Heart"
Skill.Desc[1] = "Every bullet has a 8% chance at stealing 4% of the target's health"
Skill.Desc[2] = "Every bullet has a 12% chance at stealing 5% of the target's health"
Skill.Desc[3] = "Every bullet has a 14% chance at stealing 7% of the target's health"
Skill.Tier = 3
Skill.Levels = 3
function Skill:BulletCallBack(Player, Skill, Trace, DamageInfo)
	if not SERVER then return end
	local entEntity = Trace.Entity
	if not Player:IsMelee() and Skill > 0 and entEntity:IsNPC() and entEntity.Race ~= "human" then
		local Chance = 0
		local Percent = 0
		if Skill == 1 then Chance = 8 Percent = 4 end
		if Skill == 2 then Chance = 12 Percent = 5 end
		if Skill == 3 then Chance = 14 Percent = 7 end
		if math.random(1, 100 / Chance) == 1 then
			local HealthToSteal = math.ceil(entEntity:Health() * (Percent / 100))
			DamageInfo:SetDamage(DamageInfo:GetDamage() + HealthToSteal)
			Player:SetHealth(math.Clamp(Player:Health() + HealthToSteal, 0, Player:GetMaxHealth()))
			Player:CreateIndicator("+_" .. HealthToSteal .. "HP", Player:GetPos() + Vector(0, 0, 70), "purple")
		end
	end
end
Register.Skill(Skill)

local Skill = {}
Skill.Name = "skill_eagleeye"
Skill.PrintName = "Eagle Eye"
Skill.Icon = "icons/weapon_sniper1"
Skill.SkillNeeded = "skill_marksman"
Skill.Desc = {}
Skill.Desc["story"] = "The sprit of the eagle flows within you. Feel the power."
Skill.Desc["SkillNeeded"] = "Marks Man"
Skill.Desc[1] = "Increases dexterity by 5"
Skill.Desc[2] = "Increases dexterity by 7"
Skill.Tier = 3
Skill.Levels = 2
function Skill:OnSet(Player, SkillLevel, OldSkillLevel)
	local StatTable = {}
	StatTable[0] = 0
	StatTable[1] = 5
	StatTable[2] = 7
	Player:AddStat("stat_dexterity", StatTable[SkillLevel] - StatTable[OldSkillLevel])
end
Register.Skill(Skill)

local Skill = {}
Skill.Name = "skill_hydraulicbiceps"
Skill.PrintName = "Hydraulic Biceps"
Skill.SkillNeeded = "skill_brutal"
Skill.Icon = "icons/junk_box1"
Skill.Desc = {}
Skill.Desc["story"] = "When human arms just doesn't cut it any more."
Skill.Desc["SkillNeeded"] = "Brutal"
Skill.Desc[1] = "Increases strength by 6"
Skill.Desc[2] = "Increases strength by 10"
Skill.Tier = 3
Skill.Levels = 2
function Skill:OnSet(Player, SkillLevel, OldSkillLevel)
	local StatTable = {}
	StatTable[0] = 0
	StatTable[1] = 5
	StatTable[2] = 10
	Player:AddStat("stat_strength", StatTable[SkillLevel] - StatTable[OldSkillLevel])
end
Register.Skill(Skill)
