local Player = FindMetaTable("Player")

function Player:GetItemBuyPrice(Item)
	local item = ItemTable(Item)
	if item and item.SellPrice then
		local BuyPrice = item.SellPrice * 2.7
		BuyPrice = self:CallSkillHook("price_mod", BuyPrice)
		return math.floor(BuyPrice)
	end
end
