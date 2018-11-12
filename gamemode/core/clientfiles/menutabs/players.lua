PANEL = {}

local muteIcon = Material("icon16/sound_mute.png")
local unmuteIcon = Material("icon16/sound.png")

function PANEL:Init()
	self.MainList = CreateGenericList(self, 2, false, true)
	self.ServerPlayerList = CreateGenericListItem(20, "Server", player.GetCount() .. " Player(s)", "gui/server", Tan, true, true)
	self.MainList:AddItem(self.ServerPlayerList)
	self:LoadPlayers()
end

function PANEL:PerformLayout()
	self.MainList:SetSize(self:GetWide(), self:GetTall())
end

function PANEL:LoadPlayers()
	if self.ServerPlayerList.ContentList then
		self.ServerPlayerList.ContentList:Clear()
	end
	self.ServerPlayerList:SetDescText(player.GetCount() .. " Player(s)")
	if #(LocalPlayer().Squad or {}) > 1 and not self.SquadPlayerList then
		self.SquadPlayerList = CreateGenericListItem(20, "Your Squad", "", "icon16/group.png", Tan, true, true)
		if LocalPlayer():GetNWEntity("SquadLeader") ~= LocalPlayer() then
			self.SquadPlayerList:AddButton("icon16/delete.png", "Leave Squad", function() RunConsoleCommand("UD_LeaveSquad") end)
		end
		self.MainList:AddItem(self.SquadPlayerList)
	elseif #(LocalPlayer().Squad or {}) <= 1 and self.SquadPlayerList then
		self.SquadPlayerList:Remove()
		self.SquadPlayerList = nil
	end
	if self.SquadPlayerList and self.SquadPlayerList.ContentList then
		self.SquadPlayerList.ContentList:Clear()
	end
	for _, player in pairs(player.GetAll()) do
		self:AddPlayer(self.ServerPlayerList, player)
		if LocalPlayer():IsInSquad(player) and player ~= LocalPlayer() then
			self:AddPlayer(self.SquadPlayerList, player)
		end
	end
	self:PerformLayout()
end


function PANEL:AddPlayer(Parent, ply)
	if not Parent or not IsValid(ply) then return end
	local ListItem = vgui.Create("FListItem")
	ListItem:SetHeaderSize(25)
	ListItem:SetNameText(ply:Nick())
	ListItem:SetDescText("level " .. ply:GetLevel())
	ListItem:SetColor(Gray)
	ListItem:SetAvatar(ply, 20)
	if ply:IsAdmin() then
		ListItem:SetIcon("gui/admin")
	end

	--Private Messaging
	local PrivateMessage = function()
		GAMEMODE:DisplayPrompt("string", "Private Message", function(strMessage)
			if strMessage == "" or ply:EntIndex() == LocalPlayer():EntIndex() then return end
			RunConsoleCommand("UD_PrivateMessage", ply:EntIndex(), strMessage)
		end)
	end
	if Parent == self.ServerPlayerList and LocalPlayer() ~= ply then
		ListItem.MuteButton = ListItem:AddButton(ply:IsMuted() and muteIcon or unmuteIcon, not ply:IsMuted() and "Mute" or "Unmute", function(self)
			ply:SetMuted(not ply:IsMuted())

			self:SetMaterial(ply:IsMuted() and muteIcon or unmuteIcon)
			self:SetTooltip(not ply:IsMuted() and "Mute" or "Unmute")
		end)
		local PMButton = ListItem:AddButton("gui/email", "Private Message", PrivateMessage)
	end
	--Squad
	local SquadInvite = function()
		RunConsoleCommand("UD_InvitePlayer", ply:EntIndex())
	end
	local SquadKick = function()
		RunConsoleCommand("UD_KickSquadPlayer", ply:EntIndex())
	end
	--Menu
	local OpenMenu = function()
		local dmenu = DermaMenu()

		if Parent == self.ServerPlayerList and LocalPlayer() ~= ply then
			dmenu:AddOption(not ply:IsMuted() and "Mute" or "Unmute", function()
				ply:SetMuted(not ply:IsMuted())

				ListItem.MuteButton:SetMaterial(ply:IsMuted() and muteIcon or unmuteIcon)
				ListItem.MuteButton:SetTooltip(not ply:IsMuted() and "Mute" or "Unmute")
			end)
			dmenu:AddOption("Private Message", PrivateMessage)
			dmenu:AddOption("Invite to Squad", SquadInvite)
		end
		if Parent == self.ServerPlayerList and ply == LocalPlayer() then
			local SquadChatText = "Squad Chat"
			if LocalPlayer():GetNWBool("SquadChat") then SquadChatText = "All Talk" end
			dmenu:AddOption(SquadChatText, function()
				if LocalPlayer():GetNWBool("SquadChat") then
					LocalPlayer():SetNWBool("SquadChat", false)
				else
					LocalPlayer():SetNWBool("SquadChat",true)
				end
			end)
		end
		if Parent == self.SquadPlayerList then
			if LocalPlayer():GetNWEntity("SquadLeader") == LocalPlayer() and LocalPlayer():IsInSquad(ply) and LocalPlayer() ~= ply then
				dmenu:AddOption("Kick from Squad", SquadKick)
			end
		end

		dmenu:Open()

		GAMEMODE.ActiveMenu = dmenu
	end
	local ActionsButton = ListItem:AddButton("gui/options", "Actions", OpenMenu)
	if Parent == self.SquadPlayerList then
		if LocalPlayer():GetNWEntity("SquadLeader") == LocalPlayer() and LocalPlayer():IsInSquad(ply) and LocalPlayer() ~= ply then
			ListItem:AddButton("icon16/delete.png", "Kick from Squad", SquadKick)
		end
	end
	ListItem.DoRightClick = OpenMenu
	Parent:AddContent(ListItem)
end

vgui.Register("playerstab", PANEL, "Panel")
