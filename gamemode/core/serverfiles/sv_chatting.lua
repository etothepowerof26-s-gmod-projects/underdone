function GM:PlayerCanHearPlayersVoice(Listener, Speaker)
	if not IsValid(Speaker) or not IsValid(Listener) then return false end --InValid
	local ChatDistance = 1000
	if Speaker:GetNWBool("SquadChat") or Listener:GetNWBool("SquadChat") then
		if Listener:IsInSquad(Speaker) or Speaker:IsInSquad(Listener) then
			ChatDistance = 10000
		else
			ChatDistance = 1000
		end
	end
	if Listener:GetPos():Distance(Speaker:GetPos()) >= ChatDistance then return false end --Too Far
	return true --All good :D
end

function GM:PlayerCanSeePlayersChat(Text, TeamOnly, Listener, Speaker)
	if not IsValid(Speaker) or not IsValid(Listener) then return false end --InValid
	if TeamOnly and (not Listener:IsInSquad(Speaker) or not Speaker:IsInSquad(Listener)) then return false end
	if GAMEMODE.ChatDistance and Listener:GetPos():Distance(Speaker:GetPos()) >= GAMEMODE.ChatDistance then return false end --Too Far
	return true
end
