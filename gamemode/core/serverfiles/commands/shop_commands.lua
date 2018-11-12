local Player = FindMetaTable("Player")

function Player:BuyItem(Item)
	if not IsValid(self) then return end
	if not self.UseTarget.Shop or self.UseTarget:GetPos():Distance(self:GetPos()) > 100 then return end
	local NPCTable = NPCTable(self.UseTarget:GetNWString("npc"))
	local ShopTable = ShopTable(NPCTable.Shop)
	local ItemTable = ItemTable(Item)
	if NPCTable and ShopTable and ShopTable.Inventory[Item] then
		if ItemTable.QuestNeeded and not self:HasCompletedQuest(ItemTable.QuestNeeded) then return end
		local ItemInfo = ShopTable.Inventory[Item]
		local Quest = ItemInfo.QuestNeeded
		local Price = ItemInfo.Price or self:GetItemBuyPrice(Item)
		if self:HasItem("money", Price) and self:AddItem(Item, 1) then
			self:RemoveItem("money", Price)
		end
	end
end
concommand.Add("UD_BuyItem", function(ply, command, args) ply:BuyItem(args[1]) end)

function Player:SellItem(Item, Amount)
	if not IsValid(self) then return end
	if not self.UseTarget.Shop or self.UseTarget:GetPos():Distance(self:GetPos()) > 100 then return end
	Amount = Amount or 1
	local NPCTable = NPCTable(self.UseTarget:GetNWString("npc"))
	if NPCTable and NPCTable.Shop and self:HasItem(Item, Amount) then
		local ItemTable = ItemTable(Item)
		if ItemTable.SellPrice > 0 and self:RemoveItem(Item, Amount) then
			self:AddItem("money", ItemTable.SellPrice * Amount)
		end
	end
end
concommand.Add("UD_SellItem", function(ply, command, args) ply:SellItem(args[1], tonumber(args[2])) end)
