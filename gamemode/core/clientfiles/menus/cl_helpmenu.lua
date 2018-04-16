GM.HelpMenu = nil
PANEL = {}

function PANEL:Init()
	self.Frame = CreateGenericFrame("", false, false)
	self.Frame.Paint = function() end

	self.TabSheet = CreateGenericTabPanel(self.Frame)
	self.Help = self.TabSheet:NewTab("Help", "helptab", "gui/help", "You have come to learn, I am proud.")
	self.Options = self.TabSheet:NewTab("Options", "optionstab", "gui/options", "Adjust your settings to your liking.")
	if LocalPlayer():IsAdmin() then
		self.Admin = self.TabSheet:NewTab("Admin", "admintab", "gui/admin", "For admins only.")
	end

	self.Frame.btnClose = vgui.Create("DButton", self.Frame)
	self.Frame.btnClose:SetFont("Marlett")
	self.Frame.btnClose:SetText("r")
	self.Frame.btnClose.DoClick = function(pnlPanel)
		GAMEMODE.HelpMenu.Frame:Close()
		GAMEMODE.HelpMenu = nil
	end
	self.Frame.btnClose.Paint = function()
		jdraw.QuickDrawPanel(clrGray, 0, 0, self.Frame.btnClose:GetWide() - 1, self.Frame.btnClose:GetTall() - 1)
	end
	self.Frame:MakePopup()
	self:PerformLayout()
end

function PANEL:PerformLayout()
	self.Frame:SetPos(self:GetPos())
	self.Frame:SetSize(self:GetSize())
	self.Frame.btnClose:SetPos(self.Frame:GetWide() - 5, 10)

	self.TabSheet:SetPos(5, 5)
	self.TabSheet:SetSize(self.Frame:GetWide() - 10, self.Frame:GetTall() - 10)
end
vgui.Register("helpmenu", PANEL, "Panel")

concommand.Add("UD_OpenHelp", function(ply, command, args)
	GAMEMODE.HelpMenu = GAMEMODE.HelpMenu or vgui.Create("helpmenu")
	GAMEMODE.HelpMenu:SetSize(600, 450)
	GAMEMODE.HelpMenu:Center()
end)
