function GM:StartEvent(Event)
	local EventTable = EventTable(Event)
	assert(EventTable, "event doesn't exist")
	
	for index, NPCAttack in pairs(EventTable.NPCAttack or {}) do
		if not NPCAttack then return end
		timer.Simple(NPCAttack.Spawntime, function() GAMEMODE:TimerSpawnNPC(NPCAttack) end)
	end
end

function GM:TimerSpawnNPC(NPCAttack)
	if not NPCAttack then return end
	local SpawnTable = {Position = NPCAttack.Spawnpos, Level =  NPCAttack.Level or (NPCAttack.AmountSpawned or 1) }
	if (NPCAttack.AmountSpawned or 0) < NPCAttack.Amount then
		local NPC = self:CreateNPC(NPCAttack.Class, SpawnTable)
		NPCAttack.AmountSpawned = (NPCAttack.AmountSpawned or 0) + 1
		NPC:AttackPos(NPCAttack.Attackpos)
		NPC.DontReturn = true
		timer.Simple(NPCAttack.Spawntime, function() GAMEMODE:TimerSpawnNPC(NPCAttack) end)
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
				GAMEMODE:NotifyAll("Event " ..Event.PrintName.. " will begin in ".. CountDown .." minutes")
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
