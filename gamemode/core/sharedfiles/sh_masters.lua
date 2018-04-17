local Player = FindMetaTable("Player")
function toMasterLevel(intExp)
	if not intExp then return end
	local intLevel = math.sqrt(tonumber(intExp) or 0)
	intLevel = intLevel / 8
	intLevel = math.Clamp(intLevel, 1, intLevel)
	intLevel = math.floor(intLevel)
	return tonumber(intLevel)
end

function toMasterExp(intLevel)
	local intExp = tonumber(intLevel) or 0
	if intExp <= 1 then intExp = 0 end
	intExp = intExp * 8
	intExp = math.pow(intExp, 2)
	intExp = math.floor(intExp)
	return tonumber(intExp)
end

function Player:SetMaster(strMaster, intExp)
	if not IsValid(self) then return false end
	self.Data.Masters = self.Data.Masters or {}
	self.Data.Masters[strMaster] = intExp
	if SERVER then
		SendUsrMsg("UD_UpdateMasters", self, {strMaster, intExp})
		self:SaveGame()
	end
	if CLIENT then
		if GAMEMODE.MainMenu then GAMEMODE.MainMenu.CharacterTab:LoadMasters() end
	end
	return true
end

function Player:GetMasterExp(strMaster)
	if not IsValid(self) or not self.Data.Masters then return 0 end
	return self.Data.Masters[strMaster] or 0
end

function Player:GetMasterExpNextLevel(strMaster)
	if not IsValid(self) then return 0 end
	return toMasterExp(self:GetMasterLevel(strMaster) + 1)
end

function Player:GetMasterLevel(strMaster)
	if not IsValid(self) or not self.Data.Masters then return 1 end
	return toMasterLevel(self.Data.Masters[strMaster] or 0)
end

function Player:AddMaster(strMaster, intGainExp, boolShowExp)
	if not IsValid(self) then return false end
	if boolShowExp and SERVER then
		self:CreateIndicator("+_" .. intGainExp .. "_" .. string.gsub(MasterTable(strMaster).PrintName, " ", "_"), self:GetPos() + Vector(0, 0, 70), "purple")
	end
	return self:SetMaster(strMaster, math.Clamp(self:GetMasterExp(strMaster) + intGainExp, 0, self:GetMasterExpNextLevel(strMaster) - 1))
end

function Player:RemoveMaster(strMaster, intRemoveExp)
	return self:AddMaster(strMaster, -intRemoveExp)
end

function Player:GetTotalMasters()
	if not IsValid(self) or not self.Data.Masters then return #GAMEMODE.DataBase.Masters end
	local intTotal = 0
	for strMaster, tblMaster in pairs(GAMEMODE.DataBase.Masters) do
		intTotal = intTotal + self:GetMasterLevel(strMaster)
	end
	return intTotal
end

if SERVER then
	function Player:BuyMasterLevel(strMaster)
		if not IsValid(self) or not self.Data.Masters then return false end
		if self:GetMasterExp(strMaster) == self:GetMasterExpNextLevel(strMaster) - 1 then
			if self:GetTotalMasters() < GAMEMODE.MaxMaxtersTiers then
				self:SetMaster(strMaster, self:GetMasterExpNextLevel(strMaster))
			end
		end
	end
	concommand.Add("UD_BuyMasterLevel", function(ply, command, args) ply:BuyMasterLevel(args[1]) end)
end

if CLIENT then
	usermessage.Hook("UD_UpdateMasters", function(usrMsg)
		LocalPlayer():SetMaster(usrMsg:ReadString(), usrMsg:ReadLong())
	end)
end
