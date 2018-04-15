local Player = FindMetaTable("Player")

function Player:GetTrade()
	if not IsValid(self) or not self.Data then return end
	return self.Data.Trade or {}
end

function Player:GetTradeItem(strItem)
	if not IsValid(self) or not self.Data then return end
	return self.Data.Trade[strItem]
end

function Player:AddItemTrade(strItem, intAmount)
	if not IsValid(self) or not self.Data then return false end
	local tblItemTable = ItemTable(strItem)
	if not tblItemTable then return false end
	if self:HasItem(strItem, intAmount) then
		self.Data.Trade = self.Data.Trade or {}
		local intNewTotal = (self.Data.Trade[strItem] or 0) + intAmount
		self.Data.Trade[strItem] = math.Clamp(intNewTotal, 0, intNewTotal)
		if SERVER then
			SendUsrMsg("UD_UpdateTradeItem", self, {strItem, intAmount})
		end
		if CLIENT then
			if GAMEMODE.TradeMenu then GAMEMODE.TradeMenu:LoadTrade() end
		end
		return true
	end
	return false
end

if CLIENT then
	usermessage.Hook("UD_UpdateTradeItem", function(usrMsg)
		LocalPlayer():AddItemTrade(usrMsg:ReadString(), usrMsg:ReadLong())
	end)
end