--StupidPeopel
--STEAM_0:1:14293896 
-- ^ nice fix it's completely shit
PANEL = {}

local muteIcon = Material("icon16/sound_mute.png")
local unmuteIcon = Material("icon16/sound.png")

function PANEL:Init()
	self.MainList = CreateGenericList(self, 2, false, true)
	self.ServerPlayerList = CreateGenericListItem(20, "Server", player.GetCount() .. " Player(s)", "gui/server", clrTan, true, true)
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
		self.SquadPlayerList = CreateGenericListItem(20, "Your Squad", "", "icon16/group.png", clrTan, true, true)
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


function PANEL:AddPlayer(pnlParent, ply)
	if not pnlParent or not IsValid(ply) then return end
	local ltiListItem = vgui.Create("FListItem")
	ltiListItem:SetHeaderSize(25)
	ltiListItem:SetNameText(ply:Nick())
	ltiListItem:SetDescText("level " .. ply:GetLevel())
	ltiListItem:SetColor(clrGray)
	ltiListItem:SetAvatar(ply, 20)
	if ply:IsAdmin() then 
		ltiListItem:SetIcon("gui/admin") 
	end

	--Private Messaging
	local fncPrivateMessage = function()
		GAMEMODE:DisplayPromt("string", "Private Message", function(strMessage)
			if strMessage == "" or ply:EntIndex() == LocalPlayer():EntIndex() then return end
			RunConsoleCommand("UD_PrivateMessage", ply:EntIndex(), strMessage)
		end)
	end
	if pnlParent == self.ServerPlayerList and LocalPlayer() ~= ply then
		ltiListItem.btnMuteButton = ltiListItem:AddButton(ply:IsMuted() and muteIcon or unmuteIcon, not ply:IsMuted() and "Mute" or "Unmute", function(self)
			ply:SetMuted(not ply:IsMuted())

			self:SetMaterial(ply:IsMuted() and muteIcon or unmuteIcon)
			self:SetTooltip(not ply:IsMuted() and "Mute" or "Unmute")
		end)
		local btnPMButton = ltiListItem:AddButton("gui/email", "Private Message", fncPrivateMessage)
	end
	--Squad
	local fncSquadInvite = function()
		RunConsoleCommand("UD_InvitePlayer", ply:EntIndex())
	end
	local fncSquadKick = function()
		RunConsoleCommand("UD_KickSquadPlayer", ply:EntIndex())
	end
	--Menu
	local fncOpenMenu = function()
		local dmenu = DermaMenu()

		if pnlParent == self.ServerPlayerList and LocalPlayer() ~= ply then
			dmenu:AddOption(not ply:IsMuted() and "Mute" or "Unmute", function()
				ply:SetMuted(not ply:IsMuted())

				ltiListItem.btnMuteButton:SetMaterial(ply:IsMuted() and muteIcon or unmuteIcon)
				ltiListItem.btnMuteButton:SetTooltip(not ply:IsMuted() and "Mute" or "Unmute")
			end)
			dmenu:AddOption("Private Message", fncPrivateMessage)
			dmenu:AddOption("Invite to Squad", fncSquadInvite)
		end
		if pnlParent == self.ServerPlayerList and ply == LocalPlayer() then
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
		if pnlParent == self.SquadPlayerList then
			if LocalPlayer():GetNWEntity("SquadLeader") == LocalPlayer() and LocalPlayer():IsInSquad(ply) and LocalPlayer() ~= ply then
				dmenu:AddOption("Kick from Squad", fncSquadKick)
			end
		end
		if LocalPlayer():IsAdmin() and LocalPlayer() ~= ply then
			dmenu:AddSpacer()
			dmenu:AddOption("Kick", function() RunConsoleCommand("UD_Admin_Kick", ply:EntIndex()) end)
			local mnuBanSubMenu = dmenu:AddSubMenu("Ban ...")
			for i = 0, 12 do
				local intTime = math.pow(i, 3.5) * 5
				local intDays = math.floor(intTime / 1440)
				local intHours = math.floor((intTime - (intDays * 1440)) / 60)
				local intMins = math.Round(intTime - (intHours * 60) - (intDays * 1440))
				local strTime = ""
				if intDays > 0 then strTime = strTime .. intDays .. " Days " end
				if intHours > 0 then strTime = strTime .. intHours .. " Hours " end
				if intMins > 0 then strTime = strTime .. intMins .. " Mins" end
				if intTime <= 0 then strTime = strTime .. "Perma-Ban" end
				mnuBanSubMenu:AddOption(strTime, function() RunConsoleCommand("UD_Admin_Kick", ply:EntIndex(), intTime) end)
			end
		end
		dmenu:Open()

		GAMEMODE.ActiveMenu = dmenu
	end
	local btnActionsButton = ltiListItem:AddButton("gui/options", "Actions", fncOpenMenu)
	if pnlParent == self.SquadPlayerList then
		if LocalPlayer():GetNWEntity("SquadLeader") == LocalPlayer() and LocalPlayer():IsInSquad(ply) and LocalPlayer() ~= ply then
			ltiListItem:AddButton("icon16/delete.png", "Kick from Squad", fncSquadKick)
		end
	end
	ltiListItem.DoRightClick = fncOpenMenu
	pnlParent:AddContent(ltiListItem)
end

vgui.Register("playerstab", PANEL, "Panel")
