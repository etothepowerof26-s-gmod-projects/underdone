local Player = FindMetaTable("Player")

concommand.Add("UD_PrivateMessage", function(ply, command, args)
	if not IsValid(ply) then return end

	local plyTargetPlayer = player.GetByID(tonumber(table.remove(args, 1)))
	if not IsValid(plyTargetPlayer) then return end

	local msg = table.concat(args, " ")

	-- believe it or not, this isn't for spying, we don't care, it's just to catch spammers
	-- and advertisers
	MsgN(string.format("pm %s -> %s: %s", ply:Nick(), plyTargetPlayer:Nick(), msg))
	plyTargetPlayer:ChatPrint(string.format("[PM] %s: %s", ply:Nick(), msg))
	ply:ChatPrint(string.format("[PM] To %s: %s", plyTargetPlayer:Nick(), msg))
end)

local distSqr = 100^2
function Player:UserChangeModel(model)
	if not IsValid(self) or not model then return end
	if not self.UseTarget.Appearance or self.UseTarget:GetPos():DistToSqr(self:GetPos()) > distSqr then return end

	if not GAMEMODE.PlayerModels[model] then return end

	self:SetModel(model)

	self.Data.Model = model
	self:SaveGame()
end

concommand.Add("UD_UserChangeModel", function(ply, command, args)
	if not IsValid(ply) then return end

	ply:UserChangeModel(args[1])
end)
