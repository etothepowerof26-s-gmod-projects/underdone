local Skill = {}
Skill.Name = "skill_squadhealthregen"
Skill.PrintName = "Squad HealthRegen"
Skill.SkillNeeded = "skill_healthgen"
Skill.Icon = "icons/item_healthkit"
Skill.Desc = {}
Skill.Desc["story"] = "Your blood is purposly infected with a bacteria that allows you to heal anyone around you in your team."
Skill.Desc["SkillNeeded"] = "Blood Mutation"
Skill.Desc[1] = "Every 12 seconds, you and your squadmates who are within a 500 unit radius will receive 1% of their max health."
Skill.Tier = 5
Skill.Levels = 1
function Skill:OnSet(Player, SkillLevel, OldSkillLevel)
	local Percent = SkillLevel
	if Percent <= 0 then return end
	if #(Player.Squad or {}) < 1 then return end
	timer.Create("UD_squadhealth " .. Player:SteamID64(), 12, 0, function()
		if Percent > 0 and IsValid(Player) and Player:Alive() then
			for _, Squadmate in pairs(Player.Squad) do
				if IsValid(Squadmate) and Player:GetPos():Distance(Squadmate:GetPos()) <= 500 then
					local Health = Squadmate:Health()
					Squadmate:SetHealth(math.Clamp(Health + (Squadmate:GetMaximumHealth() * (Percent / 100)), 0, Squadmate:GetMaximumHealth()))
				end
			end
		end
	end)
end
Register.Skill(Skill)

local Skill = {}
Skill.Name = "skill_nanoweavemusles"
Skill.PrintName = "Nano weave Muscles"
Skill.SkillNeeded = "skill_hydraulicbiceps"
Skill.Icon = "icons/junk_box1"
Skill.Desc = {}
Skill.Desc["story"] = "The muscles in your body are reinforced with a nano weave of carbon."
Skill.Desc["SkillNeeded"] = "Hydraulic Biceps"
Skill.Desc[1] = "Increases strength by 9"
Skill.Desc[2] = "Increases strength by 10"
Skill.Desc[3] = "Increases strength by 12"
Skill.Tier = 5
Skill.Levels = 3
function Skill:OnSet(Player, SkillLevel, OldSkillLevel)
	local StatTable = {}
	StatTable[0] = 0
	StatTable[1] = 9
	StatTable[2] = 10
	StatTable[3] = 12
	Player:AddStat("stat_strength", StatTable[SkillLevel] - StatTable[OldSkillLevel])
end
Register.Skill(Skill)

local Skill = {}
Skill.Name = "skill_luckyace"
Skill.PrintName = "Lucky Ace"
Skill.Icon = "icons/item_beer"
Skill.Desc = {}
Skill.Desc["story"] = "You found an ace of spades in some dead guys pocket. I think it is lucky!"
Skill.Desc[1] = "Increases luck by 5"
Skill.Tier = 5
Skill.Levels = 1
function Skill:OnSet(Player, SkillLevel, OldSkillLevel)
	local StatTable = {}
	StatTable[0] = 0
	StatTable[1] = 5
	Player:AddStat("stat_luck", StatTable[SkillLevel] - StatTable[OldSkillLevel])
end
Register.Skill(Skill)
