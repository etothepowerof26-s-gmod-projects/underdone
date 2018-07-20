local Player = FindMetaTable("Player")

function Player:UpdateInvites(plyInviter, intAddRemove)
	if not IsValid(self) then return false end
	self.Invites = self.Invites or {}
	self.Invites[plyInviter] = intAddRemove
	if SERVER then
		SendNetworkMessage("UD_UpdateInvites", self, {plyInviter, intAddRemove})
	end
	if CLIENT and intAddRemove == 1 then
		GAMEMODE:OpenInvitePrompt(plyInviter)
	end
end

function Player:UpdateSquadTable()
	if not IsValid(self) then return false end
	self.Squad = {}
	if self:GetNWEntity("SquadLeader"):GetNWEntity("SquadLeader") == self:GetNWEntity("SquadLeader") then
		for _, plyPlayer in pairs(player.GetAll()) do
			if plyPlayer:GetNWEntity("SquadLeader") == self:GetNWEntity("SquadLeader") and IsValid(plyPlayer:GetNWEntity("SquadLeader")) then
				table.insert(self.Squad, plyPlayer)
			end
		end
	else
		if SERVER then self:SetNWEntity("SquadLeader", self) end
	end
	if SERVER then
		SendNetworkMessage("UD_UpdateSquadTable", self, {})
	end
end

function Player:IsInSquad(plyTarget)
	if not IsValid(self) or not IsValid(plyTarget) then return false end
	return table.HasValue(self.Squad or {}, plyTarget)
end

function Player:GetAverageSquadLevel()
	if not IsValid(self) or not self.Squad then return 1 end
	local intTotalLevel = 0
	for _, ply in pairs(self.Squad or {}) do
		if ply:GetLevel() > intTotalLevel then
			intTotalLevel = ply:GetLevel()
		end
	end
	return intTotalLevel --/ #(self.Squad or {})
end

if CLIENT then
	function GM:OpenInvitePrompt(plyInviter)
		GAMEMODE:DisplayPrompt("none", plyInviter:Nick() .. " wants you to join a party!", function()
			RunConsoleCommand("UD_AcceptInvite", plyInviter:EntIndex())
		end)
	end
	net.Receive("UD_UpdateInvites", function()
		LocalPlayer():UpdateInvites(net.ReadEntity(), net.ReadInt(16))
	end)
	net.Receive("UD_UpdateSquadTable", function()
		LocalPlayer():UpdateSquadTable()
	end)
end
