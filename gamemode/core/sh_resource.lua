local tblSharedFolders = {}
tblSharedFolders[1] = "underdone/gamemode/core/sharedfiles/"
tblSharedFolders[2] = "underdone/gamemode/core/sharedfiles/database/"
tblSharedFolders[3] = "underdone/gamemode/core/sharedfiles/database/items/"
tblSharedFolders[4] = "underdone/gamemode/core/sharedfiles/database/npcs/"
tblSharedFolders[5] = "underdone/gamemode/core/sharedfiles/database/quests/"
tblSharedFolders[6] = "underdone/gamemode/core/sharedfiles/database/shops/"
tblSharedFolders[7] = "underdone/gamemode/core/sharedfiles/database/skills/"
tblSharedFolders[8] = "underdone/gamemode/core/sharedfiles/database/stats/"
tblSharedFolders[9] = "underdone/gamemode/core/sharedfiles/database/recipes/"
tblSharedFolders[10] = "underdone/gamemode/core/sharedfiles/database/masters/"
tblSharedFolders[11] = "underdone/gamemode/core/sharedfiles/database/events/"

local tblClientFolders = {}
tblClientFolders[1] = "underdone/gamemode/core/clientfiles/"
tblClientFolders[2] = "underdone/gamemode/core/clientfiles/menus/"
tblClientFolders[3] = "underdone/gamemode/core/clientfiles/vgui/"
tblClientFolders[4] = "underdone/gamemode/core/clientfiles/menutabs/"
tblClientFolders[5] = "underdone/gamemode/core/clientfiles/menutabs/helpmenu/"
tblClientFolders[6] = "underdone/gamemode/core/clientfiles/menutabs/auctionmenu/"

local tblServerFolders = {}
tblServerFolders[1] = "underdone/gamemode/core/serverfiles/"
tblServerFolders[2] = "underdone/gamemode/core/serverfiles/commands/"

if SERVER then
	local strPath = "underdone/content/materials/gui/"
	for _, file in pairs(file.Find(strPath .. "*", "LUA")) do
		if string.find(file, ".vmt") or string.find(file, ".vtf") then
			strPath = string.Replace(strPath, "underdone/content/", "")
			resource.AddFile(strPath ..file)
		end
	end
	local strPath = "underdone/content/materials/icons/"
	for _, file in pairs(file.Find(strPath .. "*", "LUA")) do
		if string.find(file, ".vmt") or string.find(file, ".vtf") then
			strPath = string.Replace(strPath, "underdone/content/", "")
			resource.AddFile(strPath .. file)
		end
	end

	local tblTotalFolder = {}
	table.Add(tblTotalFolder, tblSharedFolders)
	table.Add(tblTotalFolder, tblClientFolders)
	table.Add(tblTotalFolder, tblServerFolders)
	for _, path in pairs(tblTotalFolder) do
		for _, file in pairs(file.Find(path .. "*.lua", "LUA")) do
			if table.HasValue(tblClientFolders, path) or table.HasValue(tblSharedFolders, path) then
				AddCSLuaFile(path .. file)
			end
			if table.HasValue(tblSharedFolders, path) or table.HasValue(tblServerFolders, path)  then
				include(path .. file)
			end
		end
	end
	function resource.AddDir( dir, ext )
		for _, f in pairs( file.Find( "../" .. dir .. "/*" .. (ext or ""), "LUA") or {}) do
			resource.AddFile( dir .. "/" .. f )
		end
	end
	resource.AddDir( "materials/gui", ".vmt" )
	resource.AddDir( "materials/gui", ".vtf" )
	resource.AddDir( "materials/icons", ".vmt" )
	resource.AddDir( "materials/icons", ".vtf" )
	resource.AddDir( "materials/models/Betam01_Soldier", ".vmt" )
	resource.AddDir( "materials/models/Betam01_Soldier", ".vtf" )
	resource.AddFile( "models/Betam01_Soldier.dx80.vtx" )
	resource.AddFile( "models/Betam01_Soldier.dx90.vtx" )
	resource.AddFile( "models/Betam01_Soldier.mdl" )
	resource.AddFile( "models/Betam01_Soldier.phy" )
	resource.AddFile( "models/Betam01_Soldier.sw.vtx" )
	resource.AddFile( "models/Betam01_Soldier.vvd" )
end

if not SERVER then
	local tblTotalFolder = {}
	table.Add(tblTotalFolder, tblSharedFolders)
	table.Add(tblTotalFolder, tblClientFolders)
	for _, path in pairs(tblTotalFolder) do
		for _, file in pairs(file.Find(path .. "*.lua", "LUA")) do
			include(path .. file)
		end
	end
end
