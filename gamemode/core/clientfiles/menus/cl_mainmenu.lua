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

	self.TabSheet:SetPos(0, 0)
	self.TabSheet:SetSize(self:GetSize())

	local w, h = self.TabSheet:GetWide(), self.TabSheet:GetTall()
	for _, v in pairs(self.TabSheet.Items) do
		v.Panel:SetSize(w - 10, h - 30)
		v.Panel:PerformLayout()
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

GM.AcctivePrompt = nil
function GM:DisplayPrompt(strType, strTitle, fncOkPressed, intAmount)
	strType = strType or "number"
	strTitle = strTitle or "Prompt " .. strType
	if GAMEMODE.AcctivePrompt then GAMEMODE.AcctivePrompt:Close() end
	GAMEMODE.AcctivePrompt = nil
	GAMEMODE.AcctivePrompt = CreateGenericFrame(strTitle, false, false)
	GAMEMODE.AcctivePrompt:SetSize(300, 95)
	GAMEMODE.AcctivePrompt:Center()
	GAMEMODE.AcctivePrompt:MakePopup()
	local btnAcceptButton = CreateGenericButton(GAMEMODE.AcctivePrompt, "Accept")
	btnAcceptButton:SetSize(GAMEMODE.AcctivePrompt:GetWide() / 2 - 7.5, 20)
	btnAcceptButton:SetPos(5, 70)
	btnAcceptButton.DoClick = function()
		fncOkPressed()
		GAMEMODE.AcctivePrompt:Close()
		GAMEMODE.AcctivePrompt = nil
	end
	local btnCancleButton = CreateGenericButton(GAMEMODE.AcctivePrompt, "Cancel")
	btnCancleButton:SetSize(GAMEMODE.AcctivePrompt:GetWide() / 2 - 7.5, 20)
	btnCancleButton:SetPos(GAMEMODE.AcctivePrompt:GetWide() / 2 + 2.5, 70)
	btnCancleButton.DoClick = function()
		GAMEMODE.AcctivePrompt:Close()
		GAMEMODE.AcctivePrompt = nil
	end
	if strType == "number" then
		local PromptVarPicker = CreateGenericSlider(GAMEMODE.AcctivePrompt, "Amount", 1, intAmount, 0)
		PromptVarPicker:SetPos(5, 25)
		PromptVarPicker:SetWide(GAMEMODE.AcctivePrompt:GetWide() - 10)
		if type(intAmount) == "string" then intAmount = LocalPlayer().Data.Inventory[intAmount] end
		btnAcceptButton.DoClick = function()
			fncOkPressed(math.Clamp(PromptVarPicker:GetValue(), 1, intAmount))
			GAMEMODE.AcctivePrompt:Close()
			GAMEMODE.AcctivePrompt = nil
		end
		btnAcceptButton:SetPos(5, PromptVarPicker:GetTall() + 25 + 5)
		btnCancleButton:SetPos(GAMEMODE.AcctivePrompt:GetWide() / 2 + 2.5, PromptVarPicker:GetTall() + 25 + 5)
		GAMEMODE.AcctivePrompt:SetTall(25 + PromptVarPicker:GetTall() + 5 + btnAcceptButton:GetTall() + 5)
	end
	if strType == "string" then
		local txtPromptVarPicker = vgui.Create("DTextEntry", GAMEMODE.AcctivePrompt)
		txtPromptVarPicker:SetPos(5, 25)
		txtPromptVarPicker:SetWide(GAMEMODE.AcctivePrompt:GetWide() - 10)
		btnAcceptButton.DoClick = function()
			fncOkPressed(txtPromptVarPicker:GetValue())
			GAMEMODE.AcctivePrompt:Close()
			GAMEMODE.AcctivePrompt = nil
		end
		txtPromptVarPicker.OnEnter = btnAcceptButton.DoClick
		btnAcceptButton:SetPos(5, txtPromptVarPicker:GetTall() + 25 + 5)
		btnCancleButton:SetPos(GAMEMODE.AcctivePrompt:GetWide() / 2 + 2.5, txtPromptVarPicker:GetTall() + 25 + 5)
		GAMEMODE.AcctivePrompt:SetTall(25 + txtPromptVarPicker:GetTall() + 5 + btnAcceptButton:GetTall() + 5)
	end
	if strType == "none" then
		btnAcceptButton:SetPos(5, 25)
		btnCancleButton:SetPos(GAMEMODE.AcctivePrompt:GetWide() / 2 + 2.5, 25)
		GAMEMODE.AcctivePrompt:SetTall(25 + btnAcceptButton:GetTall() + 5)
	end
end
