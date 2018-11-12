local SharedFolders = {}
SharedFolders[1] = "underdone/gamemode/core/sharedfiles/"
SharedFolders[2] = "underdone/gamemode/core/sharedfiles/database/"
SharedFolders[3] = "underdone/gamemode/core/sharedfiles/database/items/"
SharedFolders[4] = "underdone/gamemode/core/sharedfiles/database/npcs/"
SharedFolders[5] = "underdone/gamemode/core/sharedfiles/database/quests/"
SharedFolders[6] = "underdone/gamemode/core/sharedfiles/database/shops/"
SharedFolders[7] = "underdone/gamemode/core/sharedfiles/database/skills/"
SharedFolders[8] = "underdone/gamemode/core/sharedfiles/database/stats/"
SharedFolders[9] = "underdone/gamemode/core/sharedfiles/database/recipes/"
SharedFolders[10] = "underdone/gamemode/core/sharedfiles/database/masters/"
SharedFolders[11] = "underdone/gamemode/core/sharedfiles/database/events/"

local ClientFolders = {}
ClientFolders[1] = "underdone/gamemode/core/clientfiles/"
ClientFolders[2] = "underdone/gamemode/core/clientfiles/menus/"
ClientFolders[3] = "underdone/gamemode/core/clientfiles/vgui/"
ClientFolders[4] = "underdone/gamemode/core/clientfiles/menutabs/"
ClientFolders[5] = "underdone/gamemode/core/clientfiles/menutabs/helpmenu/"
ClientFolders[6] = "underdone/gamemode/core/clientfiles/menutabs/auctionmenu/"

local ServerFolders = {}
ServerFolders[1] = "underdone/gamemode/core/serverfiles/"
ServerFolders[2] = "underdone/gamemode/core/serverfiles/commands/"

if SERVER then
	local TotalFolder = {}
	table.Add(TotalFolder, SharedFolders)
	table.Add(TotalFolder, ClientFolders)
	table.Add(TotalFolder, ServerFolders)

	for _, path in pairs(TotalFolder) do
		for _, file in pairs(file.Find(path .. "*.lua", "LUA")) do
			if table.HasValue(ClientFolders, path) or table.HasValue(SharedFolders, path) then
				AddCSLuaFile(path .. file)
			end
			if table.HasValue(SharedFolders, path) or table.HasValue(ServerFolders, path)  then
				include(path .. file)
			end
		end
	end

	function resource.AddDir(dir, ext)
		for _, f in ipairs(file.Find(dir .. "/*" .. (ext or ""), "GAME")) do
			resource.AddFile(dir .. "/" .. f)
		end
	end

	resource.AddDir("materials/gui",   ".vmt")
	resource.AddDir("materials/gui",   ".vtf")
	resource.AddDir("materials/icons", ".vmt")
	resource.AddDir("materials/icons", ".vtf")
else
	local TotalFolder = {}
	table.Add(TotalFolder, SharedFolders)
	table.Add(TotalFolder, ClientFolders)

	for _, path in pairs(TotalFolder) do
		for _, file in pairs(file.Find(path .. "*.lua", "LUA")) do
			include(path .. file)
		end
	end
end
