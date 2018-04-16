local intSpacing = 5
PANEL = {}
function PANEL:Init()
	self.OptinsList = CreateGenericList(self, intSpacing, false, true)
	self.SecondaryOptinsList = CreateGenericList(self, intSpacing, false, true)
	self:LoadOptions()
end

function PANEL:PerformLayout()
	self.OptinsList:SetSize((self:GetWide() / 2) - (intSpacing / 2), self:GetTall())
	self.SecondaryOptinsList:SetPos((self:GetWide() / 2) + (intSpacing / 2), 0)
	self.SecondaryOptinsList:SetSize((self:GetWide() / 2) - (intSpacing / 2), self:GetTall())
end

function PANEL:LoadOptions()
	self.OptinsList:AddItem(CreateGenericLabel(nil, "MenuLarge", "Cammera Options", clrWhite))
	self.OptinsList:AddItem(CreateGenericSlider(nil, "Cammera Distance", 50, 200, 0, "ud_cammeradistance"))
	self.OptinsList:AddItem(CreateGenericLabel(nil, "MenuLarge", "HUD Options", clrWhite))
	self.OptinsList:AddItem(CreateGenericCheckBox(nil, "Show HUD", "ud_showhud"))
	self.OptinsList:AddItem(CreateGenericCheckBox(nil, "Show Crosshair", "ud_showcrosshair"))
	self.OptinsList:AddItem(CreateGenericSlider(nil, "Crosshair Prongs", 2, 5, 0, "ud_crosshairprongs"))
end
vgui.Register("optionstab", PANEL, "Panel")


