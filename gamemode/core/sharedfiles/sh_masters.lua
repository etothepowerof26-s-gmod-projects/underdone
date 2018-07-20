local Player = FindMetaTable("Player")
function toMasterLevel(Exp)
	if not Exp then return end
	return math.floor(math.max((math.sqrt(tonumber(Exp) or 0) / 8), 1))
end

function toMasterExp(Level)
	local Exp = math.floor(math.pow((tonumber(Level) or 0) * 8, 2))
	if Exp <= 1 then Exp = 0 end
	return Exp
end

function Player:SetMaster(MasterName, Exp)
	if not IsValid(self) then return false end
	self.Data.Masters = self.Data.Masters or {}
	self.Data.Masters[MasterName] = Exp
	if SERVER then
		SendNetworkMessage("UD_UpdateMasters", self, {MasterName, Exp})
		self:SaveGame()
	end
	if CLIENT then
		if GAMEMODE.MainMenu then
			GAMEMODE.MainMenu.CharacterTab:LoadMasters()
		end
	end
	return true
end

function Player:GetMasterExp(MasterName)
	if not IsValid(self) or not self.Data.Masters then return 0 end
	return self.Data.Masters[MasterName] or 0
end

function Player:GetMasterExpNextLevel(MasterName)
	if not IsValid(self) then return 0 end
	return toMasterExp(self:GetMasterLevel(MasterName) + 1)
end

function Player:GetMasterLevel(MasterName)
	if not IsValid(self) or not self.Data.Masters then return 1 end
	return toMasterLevel(self.Data.Masters[MasterName] or 0)
end

function Player:AddMaster(MasterName, ExpGain, ShowExp)
	if not IsValid(self) then return false end
	if ShowExp and SERVER then
		self:CreateIndicator("+_" .. ExpGain .. "_" .. string.gsub(MasterTable(MasterName).PrintName, " ", "_"), self:GetPos() + Vector(0, 0, 70), "purple")
	end
	return self:SetMaster(MasterName, math.Clamp(self:GetMasterExp(MasterName) + ExpGain, 0, self:GetMasterExpNextLevel(MasterName) - 1))
end

function Player:RemoveMaster(MasterName, intRemoveExp)
	return self:AddMaster(MasterName, -intRemoveExp)
end

function Player:GetTotalMasters()
	if not IsValid(self) or not self.Data.Masters then return #GAMEMODE.DataBase.Masters end
	local Total = 0
	for MasterName, Master in pairs(GAMEMODE.DataBase.Masters) do
		Total = Total + self:GetMasterLevel(MasterName)
	end
	return Total
end

if SERVER then
	function Player:BuyMasterLevel(MasterName)
		if not IsValid(self) or not self.Data.Masters then return false end
		if self:GetMasterExp(MasterName) == self:GetMasterExpNextLevel(MasterName) - 1 then
			if self:GetTotalMasters() < GAMEMODE.MaxMaxtersTiers then
				self:SetMaster(MasterName, self:GetMasterExpNextLevel(MasterName))
			end
		end
	end
	concommand.Add("UD_BuyMasterLevel", function(ply, command, args) ply:BuyMasterLevel(args[1]) end)
end

if CLIENT then
	net.Receive("UD_UpdateMasters", function()
		LocalPlayer():SetMaster(net.ReadString(), net.ReadInt(16))
	end)
end
