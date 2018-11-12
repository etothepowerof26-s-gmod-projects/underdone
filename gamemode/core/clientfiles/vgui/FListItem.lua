--[[
	+oooooo+-`    `:oyyys+-`    +oo.       /oo-   .oo+-  ooo+`   `ooo+
	NMMhyhmMMm-  omMNyosdMMd:   NMM:       hMM+ `oNMd:  `MMMMy`  yMMMN
	NMM:  .NMMo /MMN:    sMMN`  NMM:       hMMo/dMm/`   `MMMmMs`oMmMMN
	NMMhyhmMNh. yMMm     -MMM:  NMM:       hMMmNMMo     `MMM:mMhMd/MMN
	NMMyoo+/.   /MMN:    sMMN`  NMM:       hMMy:dMMh-   `MMM`:NMN.:MMN
	NMM:         +NMNyosdMMd:   NMMdyyyyy. hMM+ `+NMNo` `MMM` ... :MMN
	+oo.          `:oyyys+-`    +oooooooo` /oo-   .ooo/  ooo`     .oo+  2009
]]

-- > 2009
-- > 2018

local PANEL = {}
PANEL.Color = nil
PANEL.Icon = nil
PANEL.NameText = nil
PANEL.DescText = nil
PANEL.AvatarImage = nil
PANEL.ContentList = nil
PANEL.Name = nil
PANEL.Expanded = false
PANEL.Expandable = false
PANEL.ExpandedSize = nil
PANEL.HeaderSize = nil
PANEL.GradientTexture = nil
PANEL.NameFont = "MenuLarge"

function PANEL:Init()
	self.Color = Gray
	self.Color_hover = Gray
	self:SetColor(Gray)
	self.NameText = "Test"
	self.DescText = ""
	--RightClick Dectection--
	self:SetMouseInputEnabled(true)
	self.OnMousePressed = function(self,mousecode) self:MouseCapture(true) end
	self.OnMouseReleased = function(self,mousecode) self:MouseCapture(false)
	if mousecode == MOUSE_RIGHT then pcall(self.DoRightClick,self) end
	if mousecode == MOUSE_LEFT then pcall(self.DoClick,self) end end
	-------------------------
	self.DoClick = function() self:SetExpanded(not self:GetExpanded()) end
	self.DoRightClick = function() end
	-------------------------
	self.GradientTexture = surface.GetTextureID("VGUI/gradient-d")
end

function PANEL:PerformLayout()
	self.ExpandedSize = 50
	self.HeaderSize = 18
	
	if self.Expanded then self:SetSize(self:GetWide(), self.ExpandedSize) end
	if not self.Expanded then self:SetSize(self:GetWide(), self.HeaderSize) end
	if self.CommonButton then
		self.CommonButton:SetPos(self:GetWide() - 17, (self.HeaderSize / 2) - (self.CommonButton:GetTall() / 2))
	end
	for key, Button in pairs(self.Buttons or {}) do
		Button:SetPos(self:GetWide() - (key * (Button:GetWide() + 5)), (self.HeaderSize / 2) - (Button:GetTall() / 2))
	end

	if self.ContentList then
		self.ContentList:SetSize(self:GetWide() - 10, self:GetTall() - self.HeaderSize - 7)
		self.ContentList:SetPos(5, self.HeaderSize + 2)
	end
	if self.AvatarImage then
		self.AvatarImage:SetPos(3, (self.HeaderSize / 2) - (self.AvatarImage:GetTall() / 2))
	end
	self:GetParent():InvalidateLayout()
end

function PANEL:Paint(w, h)
	local IconSize = 16
	local IconSize_small = 12
	local BackGroundColor
	local x, y = self:CursorPos()
	if x > 0 and x < w and y > 0 and y < h then
		BackGroundColor = self.Color_hover
	else
		BackGroundColor = self.Color
	end
	local PaintPanel = jdraw.NewPanel()
	PaintPanel:SetDimensions(0, 0, w, h)
	PaintPanel:SetStyle(4, BackGroundColor)
	PaintPanel:SetBorder(1, DrakGray)
	jdraw.DrawPanel(PaintPanel)
	--Text
	surface.SetFont(self.NameFont)
	local wide, high = surface.GetTextSize(self.NameText)
	local XOffSet = 5
	if self.AvatarImage then XOffSet = self.AvatarImage:GetWide() + 8 end
	if self.Icon and not self.AvatarImage then XOffSet = 20 end
	draw.SimpleText(self.NameText, self.NameFont, XOffSet, (self.HeaderSize / 2) - 1, White, 0, 1)
	draw.SimpleText(self.DescText, "DefaultSmall", wide + XOffSet + 5, (self.HeaderSize / 2), DrakGray, 0, 1)
	--Icon
	if self.Icon and not self.AvatarImage then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(self:GetIcon())
		if x > 0 and x < self:GetWide() and y > 0 and y < self:GetTall() then
			surface.DrawTexturedRect(1, (self.HeaderSize / 2) - (IconSize / 2), IconSize, IconSize)
		else
			surface.DrawTexturedRect(3, (self.HeaderSize / 2) - (IconSize_small / 2), IconSize_small, IconSize_small)
		end
	end
	return true
end

function PANEL:SetColor(clr)
	self.Color = clr
	local HoverChange = 20
	local HoverColor = Color(
		math.Clamp(clr.r + HoverChange, 0, 255),
		math.Clamp(clr.g + HoverChange, 0, 255),
		math.Clamp(clr.b + HoverChange, 0, 255),
		clr.a)
	self.Color_hover = HoverColor
end
function PANEL:GetIcon()
	return self.Icon
end
function PANEL:SetIcon(IconText)
	self.Icon = Material(IconText)
end
function PANEL:SetNameText(NameText)
	self.NameText = NameText
end
function PANEL:SetDescText(DescText)
	self.DescText = DescText
end
function PANEL:SetHeaderSize(HeaderSize)
	self.HeaderSize = HeaderSize
end
function PANEL:SetExpandable(Expandable)
	self.Expandable = Expandable
end
function PANEL:SetFont(Font)
	self.NameFont = Font
end
function PANEL:SetExpanded(Expanded)
	if self.Expandable then
		self.Expanded = Expanded
		if self.Expanded then self:SetTall(self.ExpandedSize) end
		if not self.Expanded then self:SetTall(self.HeaderSize) end
		self:GetParent():InvalidateLayout()
	end
end
function PANEL:GetExpanded()
	return self.Expanded
end

function PANEL:SetCommonButton(Texture, PressedFunction, ToolTip)
	if not self.CommonButton then  self.CommonButton = vgui.Create("DImageButton", self) end
	self.CommonButton:SetMaterial(Texture)
	self.CommonButton:SizeToContents()
	self.CommonButton.DoClick = PressedFunction
	self.CommonButton:SetTooltip(ToolTip)
end

function PANEL:AddButton(Texture, ToolTip, PressedFunction)
	local NewButton = vgui.Create("DImageButton", self)
	NewButton:SetMaterial(Texture)
	NewButton:SizeToContents()
	NewButton:SetTooltip(ToolTip)
	NewButton.DoClick = PressedFunction
	self.Buttons = self.Buttons or {}
	table.insert(self.Buttons, NewButton)
	return NewButton
end

function PANEL:SetAvatar(Player, AvatarSize)
	self.AvatarImage = vgui.Create("AvatarImage", self)
	self.AvatarImage:SetSize(AvatarSize, AvatarSize)
	self.AvatarImage:SetPlayer(Player)
end

function PANEL:SetItemIcon(Item, Text, AvatarSize)
	self.AvatarImage = vgui.Create("FIconItem", self)
	self.AvatarImage:SetSize(AvatarSize, AvatarSize)
	self.AvatarImage:SetItem(ItemTable(Item), Text, "none")
	self.AvatarImage:SetDragable(false)
	self.AvatarImage:SetText(Text)
end

function PANEL:AddContent(Item)
	self.ExpandedSize = 50
	self.HeaderSize = 18
	
	if not self.ContentList then
		self.ContentList = vgui.Create("DPanelList", self)
		self.ContentList:SetSpacing(1)
		self.ContentList:SetPadding(2)
		self.ContentList:EnableHorizontal(false)
		self.ContentList:EnableVerticalScrollbar(true)
		self.ContentList.Paint = function()
			local PaintPanel = jdraw.NewPanel()
			PaintPanel:SetDimensions(0, 0, self.ContentList:GetWide(), self.ContentList:GetTall())
			PaintPanel:SetStyle(4, Gray)
			PaintPanel:SetBorder(1, DrakGray)
			jdraw.DrawPanel(PaintPanel)
		end
	end
	self.ContentList:AddItem(Item)
	local ExpandSize = self.HeaderSize + 10
	for _, ListItem in pairs(self.ContentList:GetItems()) do ExpandSize = ExpandSize + ListItem.HeaderSize + 1 end
	self.ExpandedSize = ExpandSize
	self:PerformLayout()
end
vgui.Register("FListItem", PANEL, "Panel")