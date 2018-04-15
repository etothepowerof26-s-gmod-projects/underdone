--StupidPeopel
--STEAM_0:1:14293896
PANEL = {}

local c

function PANEL:Init()
	self.MainList = CreateGenericList(self, 2, false, true)
	self.ServerPlayerList = CreateGenericListItem(20, "Server", #player.GetAll() .. " Player(s)", "gui/server", clrTan, true, true)
	self.MainList:AddItem(self.ServerPlayerList)
	self:LoadPlayers()
end

function PANEL:PerformLayout()
	self.MainList:SetSize(self:GetWide(), self:GetTall())
end

function PANEL:LoadPlayers()
	if self.ServerPlayerList.ContentList then self.ServerPlayerList.ContentList:Clear() end
	self.ServerPlayerList:SetDescText(#player.GetAll() .. " Player(s)")
	if #(LocalPlayer().Squad or {}) > 1 and not self.SquadPlayerList then
		self.SquadPlayerList = CreateGenericListItem(20, "Your Squad", "", "icon16/group.png", clrTan, true, true)
		if LocalPlayer():GetNWEntity("SquadLeader") ~= LocalPlayer() then
			self.SquadPlayerList:AddButton("icon16/check_off.png", "Leave Squad", function() RunConsoleCommand("UD_LeaveSquad") end)
		end
		self.MainList:AddItem(self.SquadPlayerList)
	elseif #(LocalPlayer().Squad or {}) <= 1 and self.SquadPlayerList then
		self.SquadPlayerList:Remove()
		self.SquadPlayerList = nil
	end
	if self.SquadPlayerList and self.SquadPlayerList.ContentList then self.SquadPlayerList.ContentList:Clear() end
	for _, player in pairs(player.GetAll()) do
		self:AddPlayer(self.ServerPlayerList, player)
		if LocalPlayer():IsInSquad(player) and player ~= LocalPlayer() then
			self:AddPlayer(self.SquadPlayerList, player)
		end
	end
	self:PerformLayout()
end

function PANEL:AddPlayer(pnlParent, plyPlayer)
	if not pnlParent or not IsValid(plyPlayer) then return end
	local ltiListItem = vgui.Create("FListItem")
	ltiListItem:SetHeaderSize(25)
	ltiListItem:SetNameText(plyPlayer:Nick())
	ltiListItem:SetDescText("level " .. plyPlayer:GetLevel())
	ltiListItem:SetColor(clrGray)
	ltiListItem:SetAvatar(plyPlayer, 20)
	if plyPlayer:IsAdmin() then ltiListItem:SetIcon("gui/admin") end
	--Mutting
	local fncToggleMute = function(btnMuteButton)
		plyPlayer:SetMuted()
		local strMuteIcon = "gui/sound_on"
		local strMuteToolTip = "Mute"
		if plyPlayer:IsMuted(plyPlayer) then strMuteIcon = "gui/sound_off" strMuteToolTip = "Un Mute" end
		btnMuteButton:SetMaterial(strMuteIcon)
		btnMuteButton:SetTooltip(strMuteToolTip)
	end
	local strMuteIcon = "gui/sound_on"
	local strMuteToolTip = "Mute"
	if plyPlayer:IsMuted() then 
		strMuteIcon = "gui/sound_off" strMuteToolTip = "Un Mute" end
	--Private Messaging
	local fncPrivateMessage = function()
		GAMEMODE:DisplayPromt("string", "Private Message", function(strMessage)
			if strMessage == "" or plyPlayer:EntIndex() == LocalPlayer():EntIndex() then return end
			RunConsoleCommand("UD_PrivateMessage", plyPlayer:EntIndex(), strMessage)
		end)
	end
	if pnlParent == self.ServerPlayerList and LocalPlayer() ~= plyPlayer then
		local btnMuteButton = ltiListItem:AddButton(strMuteIcon, strMuteToolTip, fncToggleMute)
		local btnPMButton = ltiListItem:AddButton("gui/email", "Private Message", fncPrivateMessage)
	end
	--Squad
	local fncSquadInvite = function()
		RunConsoleCommand("UD_InvitePlayer", plyPlayer:EntIndex())
	end
	local fncSquadKick = function()
		RunConsoleCommand("UD_KickSquadPlayer", plyPlayer:EntIndex())
	end
	--Menu
	local fncOpenMenu = function()
		GAMEMODE.ActiveMenu = nil
		GAMEMODE.ActiveMenu = DermaMenu()
		if pnlParent == self.ServerPlayerList and LocalPlayer() ~= plyPlayer then
			local strText = "Mute"
			if plyPlayer:IsMuted() then strText = "Un Mute" end
			GAMEMODE.ActiveMenu:AddOption(strText, fncToggleMute)
			GAMEMODE.ActiveMenu:AddOption("Private Message", fncPrivateMessage)
			GAMEMODE.ActiveMenu:AddOption("Invite to Squad", fncSquadInvite)
		end
		if pnlParent == self.ServerPlayerList and plyPlayer == LocalPlayer() then
			local SquadChatText = "Squad Chat"
			if LocalPlayer():GetNWBool("SquadChat") then SquadChatText = "All Talk" end
			GAMEMODE.ActiveMenu:AddOption(SquadChatText, function()
				if LocalPlayer():GetNWBool("SquadChat") then
					LocalPlayer():SetNWBool("SquadChat", false)
				else
					LocalPlayer():SetNWBool("SquadChat",true)
				end
			end)
		end
		if pnlParent == self.SquadPlayerList then
			if LocalPlayer():GetNWEntity("SquadLeader") == LocalPlayer() and LocalPlayer():IsInSquad(plyPlayer) and LocalPlayer() ~= plyPlayer then
				GAMEMODE.ActiveMenu:AddOption("Kick from Squad", fncSquadKick)
			end
		end
		if LocalPlayer():IsAdmin() and LocalPlayer() ~= plyPlayer then
			GAMEMODE.ActiveMenu:AddSpacer()
			GAMEMODE.ActiveMenu:AddOption("Kick", function() RunConsoleCommand("UD_Admin_Kick", plyPlayer:EntIndex()) end)
			local mnuBanSubMenu = GAMEMODE.ActiveMenu:AddSubMenu("Ban ...")
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
				mnuBanSubMenu:AddOption(strTime, function() RunConsoleCommand("UD_Admin_Kick", plyPlayer:EntIndex(), intTime) end)
			end
		end
		GAMEMODE.ActiveMenu:Open()
	end
	local btnActionsButton = ltiListItem:AddButton("gui/options", "Actions", fncOpenMenu)
	if pnlParent == self.SquadPlayerList then
		if LocalPlayer():GetNWEntity("SquadLeader") == LocalPlayer() and LocalPlayer():IsInSquad(plyPlayer) and LocalPlayer() ~= plyPlayer then
			ltiListItem:AddButton("icon16/check_off.png", "Kick from Squad", fncSquadKick)
		end
	end
	ltiListItem.DoRightClick = fncOpenMenu
	pnlParent:AddContent(ltiListItem)
end

vgui.Register("playerstab", PANEL, "Panel")
