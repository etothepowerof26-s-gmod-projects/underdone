local Player = FindMetaTable("Player")

function Player:UseItem(Item)
	local ItemTable = ItemTable(Item)
	if ItemTable and ItemTable.Use and self:HasItem(Item) then
		ItemTable:Use(self, ItemTable)
		return true
	end
	return false
end
concommand.Add("UD_UseItem", function(ply, command, args)
	ply:UseItem(tostring(args[1]))
end)

function Player:DropItem(Item, Amount)
	Amount = math.floor(Amount)
	local ItemTable = ItemTable(Item)
	if self:HasItem(Item, Amount) and ItemTable.Dropable then
		local Position = self:EyePos() + (self:GetAimVector() * 25)
		local trace = self:GetEyeTrace()
		if trace.HitPos:Distance(self:GetPos()) < 80 then  Position = trace.HitPos end
		local DropedItem = CreateWorldItem(Item, Amount, Position)
		self:AddItem(Item, -Amount)
		return true
	end
	return false
end

concommand.Add("UD_DropItem", function(ply, command, args)
	local amount = math.Clamp(tonumber(args[2]), 1, ply.Data.Inventory[args[1]]) or 1
	ply:DropItem(args[1], amount)
end)

function Player:GiveItem(Item, Amount, Target)
	Amount = math.floor(Amount)
	local ItemTable = ItemTable(Item)
	if not ItemTable.Giveable then return false end
	Target:TransferItem(self, Item, Amount)
	Target:CreateNotification(self:Nick() .. " Gave you " .. tostring(math.Round(Amount)) .. " " .. ItemTable.PrintName)
end
concommand.Add("UD_GiveItem", function(ply, command, args) ply:GiveItem(args[1], args[2], player.GetByID(tonumber(args[3]))) end)
