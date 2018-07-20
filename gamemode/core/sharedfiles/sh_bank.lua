local Player = FindMetaTable("Player")

function Player:GetBankSize()
	if not IsValid(self) or not self.Data then return 0 end
	return self.BankWeight or 0
end
function Player:GetBankTotalSize() return 50 end

function Player:AddItemToBank(Item, Amount)
	if not IsValid(self) or not self.Data then return false end
	local ItemTable = ItemTable(Item)
	if not ItemTable then return false end
	if self:HasBankRoomFor({[Item] = Amount}) then
		self.Data.Bank = self.Data.Bank or {}
		local NewTotal = (self.Data.Bank[Item] or 0) + Amount
		self.Data.Bank[Item] = math.Clamp(NewTotal, 0, NewTotal)
		self.BankWeight = (self.BankWeight or 0) + (ItemTable.Weight * Amount)
		if SERVER then
			SendNetworkMessage("UD_UpdateBankItem", self, {Item, Amount})
			self:SaveGame()
		end
		if CLIENT then
			if GAMEMODE.BankMenu then GAMEMODE.BankMenu:LoadBank() end
		end
		return true
	end
	return false
end

function Player:RemoveItemFromBank(Item, Amount)
	if not IsValid(self) or not self.Data then return false end
	return self:AddItemToBank(Item, -Amount)
end

function Player:GetBank()
	if not IsValid(self) or not self.Data then return end
	return self.Data.Bank or {}
end

function Player:GetBankItem(Item)
	if not IsValid(self) or not self.Data then return end
	return self.Data.Bank[Item]
end

function Player:HasBankItem(Item, Amount)
	if not IsValid(self) or not self.Data or not self.Data.Bank then return false end
	Amount = tonumber(Amount) or 1
	return (self:GetBankItem(Item) or 0) - Amount >= 0 and Amount > 0
end

function Player:HasBankRoomFor(Items)
	if not IsValid(self) or not self.Data then return false end
	local Total = self:GetBankSize()
	for Item, Amount in pairs(Items or {}) do
		Total = Total + (ItemTable(Item).Weight * Amount)
	end
	if Total > self:GetBankTotalSize() or Total < 0 then return false end
	return true
end

if CLIENT then
	net.Receive("UD_UpdateBankItem", function()
		LocalPlayer():AddItemToBank(net.ReadString(), net.ReadInt(16))
	end)
end