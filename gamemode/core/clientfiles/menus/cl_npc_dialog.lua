GM.Dialog = nil
PANEL = {}

function PANEL:Init()
	self.Frame = CreateGenericFrame("Npc Dialog", true, true)
	self.Frame.btnClose.DoClick = function(pnlPanel)
		GAMEMODE.Dialog.Frame:Close()
		GAMEMODE.Dialog = nil
	end
	self.Frame:MakePopup()
	self.TextList = CreateGenericList(self.Frame, 5, false, true)
	self.Dialog = CreateGenericLabel(nil, nil, "", clrDrakGray)
	self.TextList:AddItem(self.Dialog)
	self:PerformLayout()
end

function PANEL:Button(strTextLeft, strTextRight, LeftButtonClick, RightButtonClick)
	self.LeftButton = CreateGenericButton(self.Frame, strTextLeft or "")
	self.LeftButton:SetSize((self:GetWide() / 2) - 5,20)
	self.LeftButton:SetPos(5, self:GetTall() - (self.LeftButton:GetTall() + 5))
	self.LeftButton.DoClick = function(pnlPanel)
		self:LeftButtonClick()
	end
	self.RightButton = CreateGenericButton(self.Frame, strTextRight or "")
	self.RightButton:SetSize((self:GetWide() / 2) - 5,20)
	self.RightButton:SetPos(self:GetWide() - (self.RightButton:GetWide() + 5), self:GetTall() - (self.RightButton:GetTall() + 5))
	self.RightButton.DoClick = function(pnlPanel)
		self:RightButtonClick()
	end
end

function PANEL:PerformLayout()
	self.Frame:SetPos(self:GetPos())
	self.Frame:SetSize(self:GetSize())
	self.TextList:SetPos(5, 25)
	self.TextList:SetSize(self.Frame:GetWide() - 10, self.Frame:GetTall() - 30)
end

function PANEL:UpdateDialog(strText)
	self.Dialog:SetText(strText or "")
end
vgui.Register("npcdialog", PANEL, "Panel")

concommand.Add("UD_Npcdialog", function(ply, command, args)
	GAMEMODE.Dialog = GAMEMODE.Dialog or vgui.Create("npcdialog")
	GAMEMODE.Dialog:SetSize(400, 200)
	GAMEMODE.Dialog:UpdateDialog("This is my story :]")
	GAMEMODE.Dialog:Button("Next")
	GAMEMODE.Dialog.LeftButtonClick = function()
		GAMEMODE.Dialog:UpdateDialog("That was my story :]")
	end
	GAMEMODE.Dialog.RightButtonClick = function()
		GAMEMODE.Dialog.Frame:Close()
		GAMEMODE.Dialog = nil
	end
	GAMEMODE.Dialog:Center()
end)