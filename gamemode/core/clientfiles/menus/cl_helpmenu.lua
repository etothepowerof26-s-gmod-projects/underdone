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

	self.Frame.CloseButton = vgui.Create("DButton", self.Frame)
	self.Frame.CloseButton:SetFont("Marlett")
	self.Frame.CloseButton:SetText("r")
	self.Frame.CloseButton.DoClick = function(Panel)
		GAMEMODE.HelpMenu.Frame:Close()
		GAMEMODE.HelpMenu = nil
	end
	self.Frame.CloseButton.Paint = function(w, h)
		jdraw.QuickDrawPanel(Gray, 0, 0, w - 1, h - 1)
	end
	self.Frame:MakePopup()
	self:PerformLayout()
end

function PANEL:PerformLayout()
	self.Frame:SetPos(self:GetPos())
	self.Frame:SetSize(self:GetSize())
	self.Frame.CloseButton:SetPos(self.Frame:GetWide() - 5, 10)

	self.TabSheet:SetPos(5, 5)
	self.TabSheet:SetSize(self.Frame:GetWide() - 10, self.Frame:GetTall() - 10)
end
vgui.Register("helpmenu", PANEL, "Panel")

concommand.Add("UD_OpenHelp", function(ply, command, args)
	GAMEMODE.HelpMenu = GAMEMODE.HelpMenu or vgui.Create("helpmenu")
	GAMEMODE.HelpMenu:SetSize(600, 450)
	GAMEMODE.HelpMenu:Center()
end)
