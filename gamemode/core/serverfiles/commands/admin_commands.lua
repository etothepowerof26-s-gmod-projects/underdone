function GM:ChangeMapTimed(NewMap, MapChangeDelay)
	MapChangeDelay = MapChangeDelay or 10
	GAMEMODE.StopSaving = true
	for _, ply in pairs(player.GetAll()) do
		if IsValid(ply) then
			ply:CreateNotification("Saving Accounts")
			ply:SaveGame()
			ply:CreateNotification("Server changing map to " .. NewMap .. " in " .. MapChangeDelay .. " seconds")
			for i = 1, MapChangeDelay do
				timer.Simple(i, function() ply:CreateNotification(tostring(MapChangeDelay - (i - 1)) .. " ...") end)
			end
		end
	end
	timer.Simple(MapChangeDelay, function() game.ConsoleCommand("changelevel " .. NewMap .. "\n") end)
end
concommand.Add("UD_Admin_ChangeMap", function(ply, command, args)
	if (not IsValid(ply) or ply:IsAdmin()) and args[1] then
		local NewMap = args[1]
		local MapChangeDelay = tonumber(args[2]) or 10
		GAMEMODE:ChangeMapTimed(NewMap, MapChangeDelay)
	end
end)

function GM:AdminBackup()
	for _, ply in pairs(player.GetAll()) do
		local SteamID = string.Replace(ply:SteamID(), ":", "!")
		if SteamID ~= "STEAM_ID_PENDING" then
			local FileName = "underdone/" .. SteamID .. ".txt"
			local SaveTable = table.Copy(ply.Data)
			SaveTable.Inventory = {}
			--Polkm: Space saver loop
			for Item, Amount in pairs(ply.Data.Inventory or {}) do
				if Amount > 0 then SaveTable.Inventory[Item] = Amount end
			end
			SaveTable.Bank = {}
			for Item, Amount in pairs(ply.Data.Bank or {}) do
				if Amount > 0 then SaveTable.Bank[Item] = Amount end
			end
			SaveTable.Quests = {}
			for Quest, Info in pairs(ply.Data.Quests or {}) do
				if Info.Done then
					SaveTable.Quests[Quest] = {Done = true}
				else
					SaveTable.Quests[Quest] = Info
				end
			end
			SaveTable.Exp = ply:GetNWInt("exp")
			file.Write(FileName, util.TableToJSON(SaveTable))
			ply:ChatPrint("Admin has saved a backup of player data")
		end
	end
end

concommand.Add("UD_Admin_SaveBackup", function(ply, command, args)
	if not IsValid(ply) or ply:IsAdmin() then
		GAMEMODE:AdminBackup()
	end
end)