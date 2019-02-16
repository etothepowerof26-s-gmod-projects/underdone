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
	self.InventoryTab = self.TabSheet:NewTab("Inventory", "inventorytab", "icon16/user.png", "Manipulate your items")
	self.CharacterTab = self.TabSheet:NewTab("Character", "charactertab", "icon16/user.png", "Customize your character")
	self.PlayersTab = self.TabSheet:NewTab("Players", "playerstab", "icon16/group.png", "List of players")
	self:PerformLayout()
end

function PANEL:SetTargetAlpha(TargetAlpha)
	self.TargetAlpha = TargetAlpha
end

function PANEL:Paint()
	if (self.TargetAlpha - self.CurrentAlpha) == 0 then return end
	local NewAlpha = math.Clamp(self.CurrentAlpha + (((self.TargetAlpha - self.CurrentAlpha) / math.abs(self.TargetAlpha - self.CurrentAlpha)) * 50), 0, 255)
	self.Frame:SetAlpha(NewAlpha)
	self.CurrentAlpha = NewAlpha
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
function GM:DisplayPrompt(Type, Title, OkPressed, Amount)
	Type = Type or "number"
	Title = Title or "Prompt " .. Type
	if GAMEMODE.AcctivePrompt then GAMEMODE.AcctivePrompt:Close() end
	GAMEMODE.AcctivePrompt = nil
	GAMEMODE.AcctivePrompt = CreateGenericFrame(Title, false, false)
	GAMEMODE.AcctivePrompt:SetSize(300, 95)
	GAMEMODE.AcctivePrompt:Center()
	GAMEMODE.AcctivePrompt:MakePopup()
	local AcceptButton = CreateGenericButton(GAMEMODE.AcctivePrompt, "Accept")
	AcceptButton:SetSize(GAMEMODE.AcctivePrompt:GetWide() / 2 - 7.5, 20)
	AcceptButton:SetPos(5, 70)
	AcceptButton.DoClick = function()
		OkPressed()
		GAMEMODE.AcctivePrompt:Close()
		GAMEMODE.AcctivePrompt = nil
	end
	local CancelButton = CreateGenericButton(GAMEMODE.AcctivePrompt, "Cancel")
	CancelButton:SetSize(GAMEMODE.AcctivePrompt:GetWide() / 2 - 7.5, 20)
	CancelButton:SetPos(GAMEMODE.AcctivePrompt:GetWide() / 2 + 2.5, 70)
	CancelButton.DoClick = function()
		GAMEMODE.AcctivePrompt:Close()
		GAMEMODE.AcctivePrompt = nil
	end
	if Type == "number" then
		local PromptVarPicker = CreateGenericSlider(GAMEMODE.AcctivePrompt, "Amount", 1, Amount, 0)
		PromptVarPicker:SetPos(5, 25)
		PromptVarPicker:SetWide(GAMEMODE.AcctivePrompt:GetWide() - 10)
		if type(Amount) == "string" then Amount = LocalPlayer().Data.Inventory[Amount] end
		AcceptButton.DoClick = function()
			OkPressed(math.Clamp(PromptVarPicker:GetValue(), 1, Amount))
			GAMEMODE.AcctivePrompt:Close()
			GAMEMODE.AcctivePrompt = nil
		end
		AcceptButton:SetPos(5, PromptVarPicker:GetTall() + 25 + 5)
		CancelButton:SetPos(GAMEMODE.AcctivePrompt:GetWide() / 2 + 2.5, PromptVarPicker:GetTall() + 25 + 5)
		GAMEMODE.AcctivePrompt:SetTall(25 + PromptVarPicker:GetTall() + 5 + AcceptButton:GetTall() + 5)
	end
	if Type == "string" then
		local PromptVarPicker = vgui.Create("DTextEntry", GAMEMODE.AcctivePrompt)
		PromptVarPicker:SetPos(5, 25)
		PromptVarPicker:SetWide(GAMEMODE.AcctivePrompt:GetWide() - 10)
		AcceptButton.DoClick = function()
			OkPressed(PromptVarPicker:GetValue())
			GAMEMODE.AcctivePrompt:Close()
			GAMEMODE.AcctivePrompt = nil
		end
		PromptVarPicker.OnEnter = AcceptButton.DoClick
		AcceptButton:SetPos(5, PromptVarPicker:GetTall() + 25 + 5)
		CancelButton:SetPos(GAMEMODE.AcctivePrompt:GetWide() / 2 + 2.5, PromptVarPicker:GetTall() + 25 + 5)
		GAMEMODE.AcctivePrompt:SetTall(25 + PromptVarPicker:GetTall() + 5 + AcceptButton:GetTall() + 5)
	end
	if Type == "none" then
		AcceptButton:SetPos(5, 25)
		CancelButton:SetPos(GAMEMODE.AcctivePrompt:GetWide() / 2 + 2.5, 25)
		GAMEMODE.AcctivePrompt:SetTall(25 + AcceptButton:GetTall() + 5)
	end
end
