GM.MainMenu = nil
PANEL = {}
PANEL.TargetAlpha = 0
PANEL.CurrentAlpha = 0

function PANEL:Init()
	self:SetSize(550, 350)
	self.Frame = CreateGenericFrame("", false, false)
	self.Frame.Paint = function() end
	self.Frame:SetAlpha(0)
	self.Frame:MakePopup()
	self.TabSheet = CreateGenericTabPanel(self.Frame)
	self.InventoryTab = self.TabSheet:NewTab("Inventory", "inventorytab", "icon16/user.png", "Minipulate your Items")
	self.CharacterTab = self.TabSheet:NewTab("Character", "charactertab", "icon16/user.png", "Customize you character")
	self.PlayersTab = self.TabSheet:NewTab("Players", "playerstab", "icon16/group.png", "List of players")
	self:PerformLayout()
end

function PANEL:SetTargetAlpha(intTargetAlpha)
	self.TargetAlpha = intTargetAlpha
end

function PANEL:Paint()
	if (self.TargetAlpha - self.CurrentAlpha) == 0 then return end
	local intNewAlpha = self.CurrentAlpha + (((self.TargetAlpha - self.CurrentAlpha) / math.abs(self.TargetAlpha - self.CurrentAlpha)) * 50)
	intNewAlpha = math.Clamp(intNewAlpha, 0, 255)
	self.Frame:SetAlpha(intNewAlpha)
	self.CurrentAlpha = intNewAlpha
	if self.CurrentAlpha <= 0 then
		GAMEMODE.MainMenu.Frame:SetVisible(false)
		RememberCursorPosition()
		gui.EnableScreenClicker(false)
	end
end

function PANEL:PerformLayout()
	self.Frame:SetPos(self:GetPos())
	self.Frame:SetSize(self:GetSize())
		self.TabSheet:SetPos(0,0)
		self.TabSheet:SetSize(self:GetSize())
			if self.TabSheet.TabPanels then
				for _, panel in pairs(self.TabSheet.TabPanels) do
					panel:SetSize(self.TabSheet:GetWide() - 10, self.TabSheet:GetTall() - 30)
					panel:PerformLayout()
				end
			end
end
vgui.Register("mainmenu", PANEL, "Panel")

function GM:OnSpawnMenuOpen()
	if not LocalPlayer().Data then return end
	GAMEMODE.MainMenu = GAMEMODE.MainMenu or vgui.Create("mainmenu")
	GAMEMODE.MainMenu:Center()
	GAMEMODE.MainMenu:SetTargetAlpha(255)
	GAMEMODE.MainMenu.Frame:SetVisible(true)
	gui.EnableScreenClicker(true)
	RestoreCursorPosition()
	GAMEMODE.MainMenu.PlayersTab:LoadPlayers()
	GAMEMODE.MainMenu.InventoryTab:ReloadAmmoDisplay()
	GAMEMODE.MainMenu.CharacterTab:LoadHeader()
	GAMEMODE.MainMenu.CharacterTab:LoadMasters()
end

function GM:OnSpawnMenuClose()
	if not LocalPlayer().Data or not GAMEMODE.MainMenu then return end
	GAMEMODE.MainMenu:SetTargetAlpha(0)
	if GAMEMODE.DraggingGhost then
		GAMEMODE.DraggingPanel = nil
	end
	if GAMEMODE.ActiveMenu then GAMEMODE.ActiveMenu:Remove() GAMEMODE.ActiveMenu = nil end
end

GM.AcctivePromt = nil
function GM:DisplayPromt(strType, strTitle, fncOkPressed, intAmount)
	strType = strType or "number"
	strTitle = strTitle or "Promt "..strType
	if GAMEMODE.AcctivePromt then GAMEMODE.AcctivePromt:Close() end
	GAMEMODE.AcctivePromt = nil
	GAMEMODE.AcctivePromt = CreateGenericFrame(strTitle, false, false)
	GAMEMODE.AcctivePromt:SetSize(300, 95)
	GAMEMODE.AcctivePromt:Center()
	GAMEMODE.AcctivePromt:MakePopup()
	local btnAcceptButton = CreateGenericButton(GAMEMODE.AcctivePromt, "Accept")
	btnAcceptButton:SetSize(GAMEMODE.AcctivePromt:GetWide() / 2 - 7.5, 20)
	btnAcceptButton:SetPos(5, 70)
	btnAcceptButton.DoClick = function(btnAcceptButton)
		fncOkPressed()
		GAMEMODE.AcctivePromt:Close()
		GAMEMODE.AcctivePromt = nil
	end
	local btnCancleButton = CreateGenericButton(GAMEMODE.AcctivePromt, "Cancel")
	btnCancleButton:SetSize(GAMEMODE.AcctivePromt:GetWide() / 2 - 7.5, 20)
	btnCancleButton:SetPos(GAMEMODE.AcctivePromt:GetWide() / 2 + 2.5, 70)
	btnCancleButton.DoClick = function(btnCancleButton)
		GAMEMODE.AcctivePromt:Close()
		GAMEMODE.AcctivePromt = nil
	end
	if strType == "number" then
		local PromtVarPicker = CreateGenericSlider(GAMEMODE.AcctivePromt, "Amount", 1, 1, 0)
		PromtVarPicker:SetPos(5, 25)
		PromtVarPicker:SetWide(GAMEMODE.AcctivePromt:GetWide() - 10)
		PromtVarPicker:SetValue(1)
		if type(intAmount) == "string" then intAmount = LocalPlayer().Data.Inventory[intAmount] end
		PromtVarPicker:SetMax(intAmount)
		btnAcceptButton.DoClick = function(btnAcceptButton)
			fncOkPressed(math.Clamp(PromtVarPicker:GetValue(), 1, intAmount))
			GAMEMODE.AcctivePromt:Close()
			GAMEMODE.AcctivePromt = nil
		end
		btnAcceptButton:SetPos(5, PromtVarPicker:GetTall() + 25 + 5)
		btnCancleButton:SetPos(GAMEMODE.AcctivePromt:GetWide() / 2 + 2.5, PromtVarPicker:GetTall() + 25 + 5)
		GAMEMODE.AcctivePromt:SetTall(25 + PromtVarPicker:GetTall() + 5 + btnAcceptButton:GetTall() + 5)
	end
	if strType == "string" then
		local txePromtVarPikur = vgui.Create("DTextEntry", GAMEMODE.AcctivePromt)
		txePromtVarPikur:SetPos(5, 25)
		txePromtVarPikur:SetWide(GAMEMODE.AcctivePromt:GetWide() - 10)
		btnAcceptButton.DoClick = function(btnAcceptButton)
			fncOkPressed(txePromtVarPikur:GetValue())
			GAMEMODE.AcctivePromt:Close()
			GAMEMODE.AcctivePromt = nil
		end
		txePromtVarPikur.OnEnter = btnAcceptButton.DoClick
		btnAcceptButton:SetPos(5, txePromtVarPikur:GetTall() + 25 + 5)
		btnCancleButton:SetPos(GAMEMODE.AcctivePromt:GetWide() / 2 + 2.5, txePromtVarPikur:GetTall() + 25 + 5)
		GAMEMODE.AcctivePromt:SetTall(25 + txePromtVarPikur:GetTall() + 5 + btnAcceptButton:GetTall() + 5)
	end
	if strType == "none" then
		btnAcceptButton:SetPos(5, 25)
		btnCancleButton:SetPos(GAMEMODE.AcctivePromt:GetWide() / 2 + 2.5, 25)
		GAMEMODE.AcctivePromt:SetTall(25 + btnAcceptButton:GetTall() + 5)
	end
end
