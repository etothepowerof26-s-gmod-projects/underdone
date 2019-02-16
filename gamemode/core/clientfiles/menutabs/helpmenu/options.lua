local Spacing = 5
PANEL = {}
function PANEL:Init()
	self.OptionsList = CreateGenericList(self, Spacing, false, true)
	self.SecondaryOptionsList = CreateGenericList(self, Spacing, false, true)
	self:LoadOptions()
end

function PANEL:PerformLayout()
	self.OptionsList:SetSize((self:GetWide() / 2) - (Spacing / 2), self:GetTall())
	self.SecondaryOptionsList:SetPos((self:GetWide() / 2) + (Spacing / 2), 0)
	self.SecondaryOptionsList:SetSize((self:GetWide() / 2) - (Spacing / 2), self:GetTall())
end

function PANEL:LoadOptions()
	self.OptionsList:AddItem(CreateGenericLabel(nil, "MenuLarge", "Camera Options", White))
	self.OptionsList:AddItem(CreateGenericSlider(nil, "Camera Distance", 50, 200, 0, "ud_cameradistance"))
	self.OptionsList:AddItem(CreateGenericLabel(nil, "MenuLarge", "HUD Options", White))
	self.OptionsList:AddItem(CreateGenericCheckBox(nil, "Show HUD", "ud_showhud"))
	self.OptionsList:AddItem(CreateGenericCheckBox(nil, "Show Crosshair", "ud_showcrosshair"))
	self.OptionsList:AddItem(CreateGenericSlider(nil, "Crosshair Prongs", 2, 5, 0, "ud_crosshairprongs"))
end
vgui.Register("optionstab", PANEL, "Panel")


