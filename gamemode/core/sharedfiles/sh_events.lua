function GM:StartEvent(strEvent)
	local tblEventTable = EventTable(strEvent)
	assert(tblEventTable, "event doesn't exist")
	
	for index, tblNPCAttack in pairs(tblEventTable.NPCAttack or {}) do
		if not tblNPCAttack then return end
		timer.Simple(tblNPCAttack.Spawntime, function() GAMEMODE:TimerSpawnNPC(tblNPCAttack) end)
	end
end

function GM:TimerSpawnNPC(tblNPCAttack)
	if not tblNPCAttack then return end
	local tblSpawnTable = {Position = tblNPCAttack.Spawnpos, Level =  tblNPCAttack.Level or (tblNPCAttack.AmountSpawned or 1) }
	if (tblNPCAttack.AmountSpawned or 0) < tblNPCAttack.Amount then
		local NPC = self:CreateNPC(tblNPCAttack.Class, tblSpawnTable)
		tblNPCAttack.AmountSpawned = (tblNPCAttack.AmountSpawned or 0) + 1
		NPC:AttackPos(tblNPCAttack.Attackpos)
		NPC.DontReturn = true
		timer.Simple(tblNPCAttack.Spawntime, function() GAMEMODE:TimerSpawnNPC(tblNPCAttack) end)
	end
end

function GM:TickUpdater()
	if (not GAMEMODE.NextUpdate) then GAMEMODE.NextUpdate = CurTime() end
	if (CurTime() > GAMEMODE.NextUpdate) then
		GAMEMODE.NextUpdate = CurTime() + 1
		GAMEMODE:TimeChecker()
	end
end
hook.Add("Tick", "TickUpdater", function() GAMEMODE:TickUpdater() end)

function GM:TimeChecker()
	for _, Event in pairs(GAMEMODE.DataBase.Events or {}) do
		if not Event.Time.w and not Event.Time.H then return end
		if os.date("%w") == Event.Time.w and os.date("%H") == Event.Time.Start then
			if os.date("%M") >= "50" and os.date("%S") == "00" then
				local CountDown = 10 -(tonumber(os.date("%M")) - 50)
				GAMEMODE:NotifyAll("Event " ..Event.PrintName.. " will begin in ".. CountDown .." Minutes")
			end
		end
		if os.date("%w") == Event.Time.w and os.date("%H") == Event.Time.H and os.date("%M") < Event.Duration then
			if GAMEMODE.EventHasStarted or table.Count(player.GetAll()) >= (Event.MinPlayers or 1) then return end
			GAMEMODE.EventHasStarted = true
			GAMEMODE:NotifyAll("Event " ..Event.PrintName.. " Has Begun!")
			GAMEMODE:StartEvent(Event.Name)
		end
		if os.date("%w") == Event.Time.w and os.date("%H") == Event.Time.H then
			if GAMEMODE.EventHasStarted  and os.date("%M") >= Event.Duration then
				GAMEMODE:EndEvent(Event)
			end
		end
	end
end

function GM:EndEvent(Event)
	for _,ply in pairs(player.GetAll()) do
		ply:ChatPrint("Event has ended!")
	end
	GAMEMODE.EventHasStarted = false
end
