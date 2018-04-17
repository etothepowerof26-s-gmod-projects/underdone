local Player = FindMetaTable("Player")
local intSkillPointsPerLevel = 1

function Player:SetSkill(strSkill, intAmount)
	local tblSkillTable = SkillTable(strSkill)
	if tblSkillTable then
		intAmount = intAmount or 0
		intAmount = math.Clamp(intAmount, 0, tblSkillTable.Levels)
		self.Data.Skills = self.Data.Skills or {}
		local intOldSkill = self.Data.Skills[strSkill] or 0
		self.Data.Skills[strSkill] = intAmount
		if SERVER then
			if tblSkillTable.OnSet then
				tblSkillTable:OnSet(self, intAmount, intOldSkill)
			end
			SendUsrMsg("UD_UpdateSkills", self, {strSkill, intAmount})
		end
		if CLIENT then
			if GAMEMODE.MainMenu then GAMEMODE.MainMenu.CharacterTab:LoadSkills() end
			if GAMEMODE.MainMenu then GAMEMODE.MainMenu.InventoryTab:LoadInventory() end
		end
	end
end

function Player:GetSkill(strSkill)
	self.Data.Skills = self.Data.Skills or {}
	return self.Data.Skills[strSkill] or 0
end

function Player:CanHaveSkill(strSkill)
	local tblSkillTable = SkillTable(strSkill)
	local SkillNeeded = SkillTable(strSkill).SkillNeeded
	if SkillNeeded and self:GetSkill(SkillNeeded) == 0 then return false end
	if not tblSkillTable then return false end
	return self:GetLevel() >= ((tblSkillTable.Tier - 1) * 5)
end

function Player:HasSkill(strSkill)
	if not self.Data.Skills then return end
	for skill,skilllevel in pairs(self.Data.Skills) do
		if skilllevel > 0 then
			if SkillTable(skill).Name == strSkill then
				return true
			else
				return false
			end
		end
	end
end

function Player:GetDeservedSkillPoints()
	local intSkillPoints = self:GetLevel() * intSkillPointsPerLevel
	for strSkill, intAmount in pairs(self.Data.Skills or {}) do
		intSkillPoints = math.Clamp(intSkillPoints - intAmount, 0, self:GetLevel())
	end
	return intSkillPoints
end

function Player:CallSkillHook(strHook, ...)
	local tblReturnTable = {...}
	for strSkill, intSkillLevel in pairs(self.Data.Skills or {}) do
		local tblSkillTable = SkillTable(strSkill)
		if self:GetSkill(strSkill) > 0 and tblSkillTable.Hooks and tblSkillTable.Hooks[strHook] then
			tblReturnTable = {tblSkillTable.Hooks[strHook](self, self:GetSkill(strSkill), unpack(tblReturnTable))}
		end
	end
	return unpack(tblReturnTable)
end

if SERVER then
	hook.Add("UD_Hook_PlayerLevelUp", "PlayerLevelUp_SkillPoints", function(plyPlayer, intLevels)
		plyPlayer:SetNWInt("SkillPoints", plyPlayer:GetNWInt("SkillPoints") + (intSkillPointsPerLevel * intLevels))
	end)

	function Player:BuySkill(strSkill, intAmount)
		local tblSkillTable = SkillTable(strSkill)
		if not tblSkillTable then return false end
		intAmount = math.Clamp(intAmount or 1, 0, tblSkillTable.Levels - self:GetSkill(strSkill))
		intAmount = math.Clamp(intAmount or 1, 0, self:GetNWInt("SkillPoints"))
		if intAmount <= 0 then return false end
		if self:CanHaveSkill(strSkill) then
			self:SetNWInt("SkillPoints", self:GetNWInt("SkillPoints") - intAmount)
			self:SetSkill(strSkill, self:GetSkill(strSkill) + intAmount)
			self:SaveGame()
			return true
		end
	end
	concommand.Add("UD_BuySkill", function(ply, command, args) ply:BuySkill(args[1]) end)
end
if CLIENT then
	usermessage.Hook("UD_UpdateSkills", function(usrMsg)
		LocalPlayer():SetSkill(usrMsg:ReadString(), usrMsg:ReadLong())
	end)
end