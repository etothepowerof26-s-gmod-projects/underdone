local Player = FindMetaTable("Player")

function Player:DepositItem(Item, Amount)
	if not IsValid(self) or not self.Data then return false end
	if not self.UseTarget.Bank or self.UseTarget:GetPos():Distance(self:GetPos()) > 100 then return end
	if self:HasItem(Item, Amount) and self:AddItemToBank(Item, Amount) then
		self:RemoveItem(Item, Amount)
		return true
	end
	return false
end
concommand.Add("UD_DepositItem", function(ply, command, args)
	ply:DepositItem(args[1], tonumber(args[2] or 1))
end)
function Player:WithdrawItem(Item, Amount)
	if not IsValid(self) then return end
	if not self.UseTarget.Bank or self.UseTarget:GetPos():Distance(self:GetPos()) > 100 then return end
	if self:HasBankItem(Item, Amount) and self:AddItem(Item, Amount) then
		self:RemoveItemFromBank(Item, Amount)
		return true
	end
	return false
end
concommand.Add("UD_WithdrawItem", function(ply, command, args)
	ply:WithdrawItem(args[1], tonumber(args[2] or 1))
end)

