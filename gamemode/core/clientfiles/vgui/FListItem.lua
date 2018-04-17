--[[
	+oooooo+-`    `:oyyys+-`    +oo.       /oo-   .oo+-  ooo+`   `ooo+
	NMMhyhmMMm-  omMNyosdMMd:   NMM:       hMM+ `oNMd:  `MMMMy`  yMMMN
	NMM:  .NMMo /MMN:    sMMN`  NMM:       hMMo/dMm/`   `MMMmMs`oMmMMN
	NMMhyhmMNh. yMMm     -MMM:  NMM:       hMMmNMMo     `MMM:mMhMd/MMN
	NMMyoo+/.   /MMN:    sMMN`  NMM:       hMMy:dMMh-   `MMM`:NMN.:MMN
	NMM:         +NMNyosdMMd:   NMMdyyyyy. hMM+ `+NMNo` `MMM` ... :MMN
	+oo.          `:oyyys+-`    +oooooooo` /oo-   .ooo/  ooo`     .oo+  2009
]]

local PANEL = {}
PANEL.Color = nil
PANEL.Icon = nil
PANEL.NameText = nil
PANEL.DescText = nil
PANEL.AvatarImage = nil
PANEL.ContentList = nil
PANEL.strName = nil
PANEL.Expanded = false
PANEL.Expandable = false
PANEL.ExpandedSize = nil
PANEL.HeaderSize = nil
PANEL.GradientTexture = nil
PANEL.NameFont = "MenuLarge"

function PANEL:Init()
	self.Color = clrGray
	self.Color_hover = clrGray
	self:SetColor(clrGray)
	self.NameText = "Test"
	self.DescText = ""
	self.ExpandedSize = 50
	self.HeaderSize = 18
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
	if self.Expanded then self:SetSize(self:GetWide(), self.ExpandedSize) end
	if not self.Expanded then self:SetSize(self:GetWide(), self.HeaderSize) end
	if self.CommonButton then
		self.CommonButton:SetPos(self:GetWide() - 17, (self.HeaderSize / 2) - (self.CommonButton:GetTall() / 2))
	end
	for key, btnButton in pairs(self.Buttons or {}) do
		btnButton:SetPos(self:GetWide() - (key * (btnButton:GetWide() + 5)), (self.HeaderSize / 2) - (btnButton:GetTall() / 2))
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

function PANEL:Paint()
	local intIconSize = 16
	local intIconSize_small = 12
	local clrBackGroundColor
	local x, y = self:CursorPos()
	if x > 0 and x < self:GetWide() and y > 0 and y < self:GetTall() then
		clrBackGroundColor = self.Color_hover
	else
		clrBackGroundColor = self.Color
	end
	local tblPaintPanle = jdraw.NewPanel()
	tblPaintPanle:SetDimensions(0, 0, self:GetWide(), self:GetTall())
	tblPaintPanle:SetStyle(4, clrBackGroundColor)
	tblPaintPanle:SetBorder(1, clrDrakGray)
	jdraw.DrawPanel(tblPaintPanle)
	--Text
	surface.SetFont(self.NameFont)
	local wide, high = surface.GetTextSize(self.NameText)
	local intXOffSet = 5
	if self.AvatarImage then intXOffSet = self.AvatarImage:GetWide() + 8 end
	if self.Icon and not self.AvatarImage then intXOffSet = 20 end
	draw.SimpleText(self.NameText, self.NameFont, intXOffSet, (self.HeaderSize / 2) - 1, clrWhite, 0, 1)
	draw.SimpleText(self.DescText, "DefaultSmall", wide + intXOffSet + 5, (self.HeaderSize / 2), clrDrakGray, 0, 1)
	--Icon
	if self.Icon and not self.AvatarImage then
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(self:GetIcon())
		if x > 0 and x < self:GetWide() and y > 0 and y < self:GetTall() then
			surface.DrawTexturedRect(1, (self.HeaderSize / 2) - (intIconSize / 2), intIconSize, intIconSize)
		else
			surface.DrawTexturedRect(3, (self.HeaderSize / 2) - (intIconSize_small / 2), intIconSize_small, intIconSize_small)
		end
	end
	return true
end

function PANEL:SetColor(clrColor)
	self.Color = clrColor
	local intHoverChange = 20
	local HoverColor = Color(
		math.Clamp(clrColor.r + intHoverChange, 0, 255),
		math.Clamp(clrColor.g + intHoverChange, 0, 255),
		math.Clamp(clrColor.b + intHoverChange, 0, 255),
		clrColor.a)
	self.Color_hover = HoverColor
end
function PANEL:GetIcon()
	return self.Icon
end
function PANEL:SetIcon(strIconText)
	self.Icon = Material(strIconText)
end
function PANEL:SetNameText(strNameText)
	self.NameText = strNameText
end
function PANEL:SetDescText(strDescText)
	self.DescText = strDescText
end
function PANEL:SetHeaderSize(intHeaderSize)
	self.HeaderSize = intHeaderSize
end
function PANEL:SetExpandable(boolExpandable)
	self.Expandable = boolExpandable
end
function PANEL:SetFont(strFont)
	self.NameFont = strFont
end
function PANEL:SetExpanded(boolExpanded)
	if self.Expandable then
		self.Expanded = boolExpanded
		if self.Expanded then self:SetTall(self.ExpandedSize) end
		if not self.Expanded then self:SetTall(self.HeaderSize) end
		self:GetParent():InvalidateLayout()
	end
end
function PANEL:GetExpanded()
	return self.Expanded
end



function PANEL:SetCommonButton(strTexture, fncPressedFunction, strToolTip)
	if not self.CommonButton then  self.CommonButton = vgui.Create("DImageButton", self) end
	self.CommonButton:SetMaterial(strTexture)
	self.CommonButton:SizeToContents()
	self.CommonButton.DoClick = fncPressedFunction
	self.CommonButton:SetTooltip(strToolTip)
end



function PANEL:AddButton(strTexture, strToolTip, fncPressedFunction)
	local btnNewButton = vgui.Create("DImageButton", self)
	btnNewButton:SetMaterial(strTexture)
	btnNewButton:SizeToContents()
	btnNewButton:SetTooltip(strToolTip)
	btnNewButton.DoClick = fncPressedFunction
	self.Buttons = self.Buttons or {}
	table.insert(self.Buttons, btnNewButton)
	return btnNewButton
end

function PANEL:SetAvatar(plyPlayer, intAvatarSize)
	self.AvatarImage = vgui.Create("AvatarImage", self)
	self.AvatarImage:SetSize(intAvatarSize, intAvatarSize)
	self.AvatarImage:SetPlayer(plyPlayer)
end

function PANEL:SetItemIcon(strItem, strText, intAvatarSize)
	self.AvatarImage = vgui.Create("FIconItem", self)
	self.AvatarImage:SetSize(intAvatarSize, intAvatarSize)
	self.AvatarImage:SetItem(ItemTable(strItem), strText, "none")
	self.AvatarImage:SetDragable(false)
	self.AvatarImage:SetText(strText)
end

function PANEL:AddContent(objItem)
	if not self.ContentList then
		self.ContentList = vgui.Create("DPanelList", self)
		self.ContentList:SetSpacing(1)
		self.ContentList:SetPadding(2)
		self.ContentList:EnableHorizontal(false)
		self.ContentList:EnableVerticalScrollbar(true)
		self.ContentList.Paint = function()
			local tblPaintPanle = jdraw.NewPanel()
			tblPaintPanle:SetDimensions(0, 0, self.ContentList:GetWide(), self.ContentList:GetTall())
			tblPaintPanle:SetStyle(4, clrGray)
			tblPaintPanle:SetBorder(1, clrDrakGray)
			jdraw.DrawPanel(tblPaintPanle)
		end
	end
	self.ContentList:AddItem(objItem)
	local ExpandSize = self.HeaderSize + 10
	for _, ListItem in pairs(self.ContentList:GetItems()) do ExpandSize = ExpandSize + ListItem.HeaderSize + 1 end
	self.ExpandedSize = ExpandSize
	self:PerformLayout()
end
vgui.Register("FListItem", PANEL, "Panel")