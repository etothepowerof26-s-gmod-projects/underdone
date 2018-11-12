local Player = FindMetaTable("Player")

function Player:AddBookToLibrary(strBook)
	if not IsValid(self) then return false end
	self.Data.Library = self.Data.Library or {}
	self.Data.Library[strBook] = true
	for _, strRecipe in pairs(ItemTable(strBook).GainRecipes or {}) do
		self:AddRecipe(strRecipe)
	end
	if SERVER then
		if ItemTable(strBook).LibraryLoad then
			ItemTable(strBook):LibraryLoad(self, ItemTable(strBook))
		end
		SendNetworkMessage("UD_UpdateLibrary", self, {strBook})
	end
	return true
end

function Player:HasReadBook(strBook)
	if not IsValid(self) then return false end
	return (self.Data.Library or {})[strBook]
end

if SERVER then
	function Player:RequestBookStory(strBook)
		if self:HasReadBook(strBook) then
			SendNetworkMessage("UD_UpdateCurrentBook", self, {true})
			for i = 0, math.ceil(string.len(ItemTable(strBook).Story) / 150) - 1 do
				SendNetworkMessage("UD_UpdateCurrentBook", self, {false, string.sub(ItemTable(strBook).Story, (i * 150) + 1, (i + 1) * 150)})
			end
		end
	end
	concommand.Add("UD_ReadBook", function(ply, command, args) ply:RequestBookStory(args[1]) end)
end

if CLIENT then
	net.Receive("UD_UpdateLibrary", function()
		LocalPlayer():AddBookToLibrary(net.ReadString())
	end)
	net.Receive("UD_UpdateCurrentBook", function()
		LocalPlayer().CurrentStory = LocalPlayer().CurrentStory or ""
		if not net.ReadBool() then
			LocalPlayer().CurrentStory = LocalPlayer().CurrentStory .. net.ReadString()
		else
			LocalPlayer().CurrentStory = ""
		end
		if GAMEMODE.ReadMenu then
			GAMEMODE.ReadMenu:UpdateStory()
		else
			RunConsoleCommand("UD_OpenReadMenu")
		end
	end)
end

