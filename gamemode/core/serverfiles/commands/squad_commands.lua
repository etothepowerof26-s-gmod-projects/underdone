concommand.Add("UD_InvitePlayer", function(ply, command, args)
	local Player = player.GetByID(tonumber(args[1]))
	if not IsValid(ply) or not IsValid(Player) then return false end
	if #(ply.Squad or {}) >= 5 then return false end
	Player:UpdateInvites(ply, 1)
end)
concommand.Add("UD_KickSquadPlayer", function(ply, command, args)
	local Player = player.GetByID(tonumber(args[1]))
	if not IsValid(ply) or not IsValid(Player) then return false end
	if ply:GetNWEntity("SquadLeader") ~= ply or not ply:IsInSquad(Player) then return end
	Player:SetNWEntity("SquadLeader", Player)
	timer.Simple(0.5, function()
		for _, Player in pairs(player.GetAll()) do
			Player:UpdateSquadTable()
		end
	end)
end)
concommand.Add("UD_LeaveSquad", function(ply, command, args)
	if not IsValid(ply) then return false end
	ply:SetNWEntity("SquadLeader", ply)
	timer.Simple(0.5, function()
		for _, Player in pairs(player.GetAll()) do
			Player:UpdateSquadTable()
		end
	end)
end)
concommand.Add("UD_AcceptInvite", function(ply, command, args)
	local Inviter = player.GetByID(tonumber(args[1]))
	if not IsValid(ply) or not IsValid(Inviter) then return false end
	if not ply.Invites[Inviter] == 1 then return end
	Inviter:SetNWEntity("SquadLeader", Inviter)
	ply:SetNWEntity("SquadLeader", Inviter)
	ply:UpdateInvites(Inviter, 0)
	timer.Simple(0.5, function()
		for _, Player in pairs(player.GetAll()) do
			Player:UpdateSquadTable()
		end
	end)
end)
