local Entity = FindMetaTable("Entity")
local Player = FindMetaTable("Player")

function Entity:AddItem(strItem, intAmount)
	if not IsValid(self) then return false end
	local tblItemTable = GAMEMODE.DataBase.Items[strItem]
	if not tblItemTable then return false end
	intAmount = tonumber(intAmount) or 1
	self.Data = self.Data or {}
	self.Data.Inventory = self.Data.Inventory or {}
	self.Data.Inventory[strItem] = self.Data.Inventory[strItem] or 0
	self.Weight = self.Weight or 0
	local intMaxItems = math.Clamp(math.floor((self:GetMaxWeight() - self.Weight) / tblItemTable.Weight), 0, intAmount)
	intAmount = math.Clamp(intAmount, -self.Data.Inventory[strItem], intMaxItems)
	if intAmount == 0 then return false end
	if SERVER then
		if self.Data.Paperdoll and intAmount < 0 then
			if self.Data.Inventory[strItem] == 1 and self.Data.Paperdoll[tblItemTable.Slot] == strItem then
				self:UseItem(strItem)
			end
		end
	end
	self.Data.Inventory[strItem] = self.Data.Inventory[strItem] + intAmount
	self.Weight = self.Weight + (tblItemTable.Weight * intAmount)
	if SERVER and self:GetClass() == "player" then
		SendUsrMsg("UD_UpdateItem", self, {strItem, intAmount})
		self:SaveGame()
	end
	if CLIENT then
		if GAMEMODE.MainMenu then GAMEMODE.MainMenu.InventoryTab:LoadInventory() end
		if GAMEMODE.ShopMenu then GAMEMODE.ShopMenu:LoadShop() end
		if GAMEMODE.ShopMenu then GAMEMODE.ShopMenu:LoadPlayer() end
		if GAMEMODE.BankMenu then GAMEMODE.BankMenu:LoadPlayer() end
		if GAMEMODE.UpdateHotBar then GAMEMODE:UpdateHotBar() end
	end
	return true
end

function Entity:RemoveItem(strItem, intAmount)
	return self:AddItem(strItem, -intAmount)
end

function Entity:GetItem(strItem)
	if not IsValid(self) then return 0 end
	self.Data.Inventory = self.Data.Inventory or {}
	return self.Data.Inventory[strItem] or 0
end

function Entity:TransferItem(objTarget, strItem1, intAmount1, strItem2, intAmount2)
	intAmount1 = tonumber(intAmount1) or 1
	intAmount2 = tonumber(intAmount2) or 0
	if strItem1 then if not objTarget:HasItem(strItem1, intAmount1) then return false end end
	if strItem2 then if not self:HasItem(strItem2, intAmount2) then return false end end
	if strItem1 then if self:AddItem(strItem1, intAmount1) then objTarget:AddItem(strItem1, -intAmount1) end end
	if strItem2 then if objTarget:AddItem(strItem2, intAmount2) then self:AddItem(strItem2, -intAmount2) end end
end

function Entity:HasItem(strItem, intAmount)
	if not self.Data.Inventory then return false end
	intAmount = tonumber(intAmount) or 1
	return (self:GetItem(strItem) or 0) - intAmount >= 0 and intAmount > 0
end

function Entity:HasRoomFor(tblItems, intAddtionalConstant)
	local intWeight = self:TotalWeightOf(tblItems)
	if intWeight + (intAddtionalConstant or 0) <= self:GetMaxWeight() then return true end
end

function Entity:TotalWeightOf(tblItems)
	local intWeight = self.Weight or 0
	for strItem, intAmount in pairs(tblItems or {}) do
		local tblItemTable = ItemTable(strItem)
		intWeight = intWeight + (tblItemTable.Weight * intAmount)
	end
	return intWeight
end

function Entity:GiveItems(tblItems)
	for strItem, intAmount in pairs(tblItems or {}) do
		self:AddItem(strItem, intAmount)
	end
end

function Entity:TakeItems(tblItems)
	for strItem, intAmount in pairs(tblItems or {}) do
		if not self:RemoveItem(strItem, intAmount) then return false end
	end
end


if CLIENT then
	usermessage.Hook("UD_UpdateItem", function(usrMsg)
		LocalPlayer():AddItem(usrMsg:ReadString(), usrMsg:ReadLong())
	end)
end