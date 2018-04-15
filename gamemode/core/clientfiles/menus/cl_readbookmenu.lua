GM.ReadMenu = nil
PANEL = {}

function PANEL:Init()
	self.Frame = CreateGenericFrame("Book", true, true)
	self.Frame.btnClose.DoClick = function(pnlPanel)
		GAMEMODE.ReadMenu.Frame:Close()
		GAMEMODE.ReadMenu = nil
	end
	self.Frame:MakePopup()
	self.TextList = CreateGenericList(self.Frame, 5, false, true)
	self.StoryText = CreateGenericLabel(nil, nil, LocalPlayer().CurrentStory or "", clrDrakGray)
	self.TextList:AddItem(self.StoryText)
	self:PerformLayout()
end

function PANEL:PerformLayout()
	self.Frame:SetPos(self:GetPos())
	self.Frame:SetSize(self:GetSize())
	self.TextList:SetPos(5, 25)
	self.TextList:SetSize(self.Frame:GetWide() - 10, self.Frame:GetTall() - 30)
end

function PANEL:UpdateStory()
	self.StoryText:SetText(LocalPlayer().CurrentStory or "")
end
vgui.Register("readmenu", PANEL, "Panel")

concommand.Add("UD_OpenReadMenu", function(ply, command, args)
	GAMEMODE.ReadMenu = GAMEMODE.ReadMenu or vgui.Create("readmenu")
	GAMEMODE.ReadMenu:SetSize(250, 250)
	GAMEMODE.ReadMenu:Center()
	GAMEMODE.ReadMenu:UpdateStory()
end)