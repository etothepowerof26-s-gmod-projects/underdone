local Player = FindMetaTable("Player")

function Player:DepositItem(strItem, intAmount)
	if not IsValid(self) or not self.Data then return false end
	if not self.UseTarget.Bank or self.UseTarget:GetPos():Distance(self:GetPos()) > 100 then return end
	if self:HasItem(strItem, intAmount) and self:AddItemToBank(strItem, intAmount) then
		self:RemoveItem(strItem, intAmount)
		return true
	end
	return false
end
concommand.Add("UD_DepositItem", function(ply, command, args)
	ply:DepositItem(args[1], tonumber(args[2] or 1))
end)
function Player:WithdrawItem(strItem, intAmount)
	if not IsValid(self) then return end
	if not self.UseTarget.Bank or self.UseTarget:GetPos():Distance(self:GetPos()) > 100 then return end
	if self:HasBankItem(strItem, intAmount) and self:AddItem(strItem, intAmount) then
		self:RemoveItemFromBank(strItem, intAmount)
		return true
	end
	return false
end
concommand.Add("UD_WithdrawItem", function(ply, command, args)
	ply:WithdrawItem(args[1], tonumber(args[2] or 1))
end)

