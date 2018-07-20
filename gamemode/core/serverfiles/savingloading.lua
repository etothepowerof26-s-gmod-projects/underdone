local Player = FindMetaTable("Player")

function Player:NewGame()
	-- TODO: config?
	self:SetNWInt("exp", 0)
	self:AddItem("money", 100)
	self:AddItem("item_smallammo_small", 3)
	self:AddItem("item_healthkit", 2)
	self:AddItem("weapon_melee_axe", 1)
	self:AddItem("weapon_ranged_junkpistol", 1)
	--[[
	self:AddItem("item_canspoilingmeat", 1)
	self:AddItem("weapon_melee_fryingpan", 1)
	self:AddItem("weapon_melee_cleaver", 1)
	self:AddItem("weapon_melee_leadpipe", 1)
	self:AddItem("weapon_melee_circularsaw", 1)
	self:AddItem("weapon_melee_wrench", 1)
	self:AddItem("weapon_melee_knife", 1)
	self:AddItem("weapon_ranged_heavymacgun", 1)
	self:AddItem("weapon_ranged_junksmg", 1)
	self:AddItem("armor_helm_chefshat", 1)
	self:AddItem("armor_helm_junkhelmet", 1)
	self:AddItem("armor_helm_scannergoggles", 1)
	self:AddItem("armor_chest_junkarmor", 1)
	self:AddItem("armor_sheild_cog", 1)
	self:AddItem("armor_sheild_saw", 1)
	]]
	self:SaveGame()
end

function Player:LoadGame()
	self.Data = {}
	self.Race = "human"
	-- local Data = {}

	-- Set the player's stats to the default.
	for name, stat in pairs(GAMEMODE.DataBase.Stats) do
		self:SetStat(name, stat.Default)
	end

	-- Load the player's game
	local steamID = string.Replace(self:SteamID(), ":", "!")
	if game.SinglePlayer() or steamID ~= "STEAM_ID_PENDING" then
		local FileName = "underdone/" .. steamID .. ".txt"

		if file.Exists(FileName, "DATA") then
			local savedGameData = util.JSONToTable(util.Decompress(file.Read(FileName)) or "")

			self:SetNWInt("exp", savedGameData.Exp or 0)
			self:SetNWInt("SkillPoints", self:GetDeservedSkillPoints())

			if savedGameData.Skills then
				local AllSkillsTable = table.Copy(GAMEMODE.DataBase.Skills)
				AllSkillsTable = table.ClearKeys(AllSkillsTable)
				table.sort(AllSkillsTable, function(statA, statB) return statA.Tier < statB.Tier end)

				for _, Skill in pairs(AllSkillsTable or {}) do
					if self:CanHaveSkill(Skill.Name) and savedGameData.Skills[Skill.Name] then
						self:BuySkill(Skill.Name, savedGameData.Skills[Skill.Name])
					end
				end
			end

			self.Data.Model = savedGameData.Model or "models/player/Group01/male_02.mdl"
			self:SetModel(savedGameData.Model or "models/player/Group01/male_02.mdl")

			self:GiveItems(savedGameData.Inventory)

			for Item, Amount in pairs(savedGameData.Bank or {}) do self:AddItemToBank(Item, Amount) end
			for slot, item in pairs(savedGameData.Paperdoll or {}) do self:UseItem(item) end
			for Quest, Info in pairs(savedGameData.Quests or {}) do self:UpdateQuest(Quest, Info) end
			for Book, boolRead in pairs(savedGameData.Library or {}) do self:AddBookToLibrary(Book) end
			for Master, intExp in pairs(savedGameData.Masters or {}) do self:SetMaster(Master, intExp) end
		else
			self:NewGame()
		end
	end

	-- Finish loading
	self.Loaded = true
	self:SetNWBool("Loaded", true)

	hook.Run("UD_Hook_PlayerLoad", self)
	for _, ply in pairs(player.GetAll()) do
		if ply ~= self and ply.Data and ply.Data.Paperdoll then
			for slot, item in pairs(ply.Data.Paperdoll) do
				SendUsrMsg("UD_UpdatePaperDoll", self, {ply, slot, item})
			end
		end
	end
end

function Player:SaveGame()
	if not self.Loaded then return end
	if GAMEMODE.StopSaving then return end
	if not self.Data then return end

	local SaveTable = table.Copy(self.Data)
	SaveTable.Inventory = {}
	
	for Item, Amount in pairs(self.Data.Inventory or {}) do
		if Amount > 0 then SaveTable.Inventory[Item] = Amount end
	end

	SaveTable.Bank = {}
	for Item, Amount in pairs(self.Data.Bank or {}) do
		if Amount > 0 then SaveTable.Bank[Item] = Amount end
	end

	SaveTable.Quests = {}
	for Quest, Info in pairs(self.Data.Quests or {}) do
		if Info.Done then
			SaveTable.Quests[Quest] = {Done = true}
		else
			SaveTable.Quests[Quest] = Info
		end
	end

	local SteamID = string.Replace(self:SteamID(), ":", "!")
	if SteamID ~= "STEAM_ID_PENDING" then
		local FileName = "underdone/" .. SteamID .. ".txt"
		SaveTable.Exp = self:GetNWInt("exp")
		file.Write(FileName, util.Compress(util.TableToJSON(SaveTable)))
	end
end

local function PlayerSave(ply) ply:SaveGame() end
hook.Add("PlayerDisconnected", "PlayerSavePlayerDisconnected", PlayerSave)
hook.Add("UD_Hook_PlayerLevelUp", "PlayerSaveUD_Hook_PlayerLevelUp", PlayerSave)
hook.Add("ShutDown", "PlayerSaveShutDown", function() for _, ply in pairs(player.GetAll()) do PlayerSave(ply) end end)
