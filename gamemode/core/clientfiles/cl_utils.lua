	function CreateGenericFrame(Title, Draggable, Close)
		local NewFrame = vgui.Create("DFrame")
		NewFrame:SetTitle(Title)
		NewFrame:SetDraggable(Draggable)
		NewFrame:ShowCloseButton(Close)

		if Close then
			NewFrame.Close:SetFont("Marlett")
			NewFrame.Close:SetText("r")
			NewFrame.Close:SetColor(Color(200, 200, 200, 255))
			NewFrame.Close.Paint = function() end

			NewFrame.Maxim:SetVisible(false)
			NewFrame.Minim:SetVisible(false)
		end

		local PaintPanel = jdraw.NewPanel()
		NewFrame.PaintPanel = PaintPanel
			PaintPanel:SetStyle(4, Tan)
			PaintPanel:SetBorder(1, DrakGray)

		local PaintPanel2 = jdraw.NewPanel()
		NewFrame.PaintPanel2 = PaintPanel2
			PaintPanel2:SetStyle(4, Gray)
			PaintPanel2:SetBorder(1, DrakGray)

		function NewFrame:Paint(w, h)
			self.PaintPanel:SetDimensions(0, 0, w, h)
			jdraw.DrawPanel(self.PaintPanel)

			self.PaintPanel2:SetDimensions(5, 5, w - 10, 15)
			jdraw.DrawPanel(self.PaintPanel2)
		end

		return NewFrame
	end

	function CreateGenericList(Parent, Spacing, HorizontalScrollEnabled, VerticalScrollEnabled)
		local NewList = vgui.Create("DPanelList", Parent)
		NewList:SetSpacing(Spacing)
		NewList:SetPadding(Spacing)
		NewList:EnableHorizontal(HorizontalScrollEnabled)
		NewList:EnableVerticalScrollbar(VerticalScrollEnabled)

		local PaintPanel = jdraw.NewPanel()
		NewList.PaintPanel = PaintPanel
			PaintPanel:SetStyle(4, Gray)
			PaintPanel:SetBorder(1, DrakGray)

		function NewList:Paint(w, h)
			self.PaintPanel:SetDimensions(0, 0, w, h)
			jdraw.DrawPanel(self.PaintPanel)
		end

		return NewList
	end

	function CreateGenericLabel(Parent, Font, Text, Color)
		local Label = vgui.Create("FMultiLabel", Parent)
		Label:SetFont(Font or "Default")
		Label:SetText(Text or "Default")
		Label:SetColor(Color or White)

		return Label
	end

	local weight_format = "Weight %d/%d"
	function CreateGenericWeightBar(Parent, Weight, MaxWeight)
		local WeightBar = vgui.Create("FPercentBar", Parent)
		WeightBar:SetMax(MaxWeight)
		WeightBar:SetValue(Weight)
		WeightBar:SetText(string.format(weight_format, Weight, MaxWeight))

		function WeightBar:Update(NewValue)
			NewValue = tonumber(NewValue) or 0

			WeightBar:SetValue(NewValue)
			WeightBar:SetText(string.format(weight_format, NewValue, self:GetMax()))
		end

		return WeightBar
	end

	function CreateGenericTabPanel(Parent)
		local TabSheet = vgui.Create("DPropertySheet", Parent)

		function TabSheet:Paint(w, h)
			jdraw.QuickDrawPanel(Tan, 0, 20, w, h - 20)
		end

		function TabSheet:NewTab(Name, PanelObject, Icon, Desc)
			local NewPanel = vgui.Create(PanelObject)
			local tab = self:AddSheet(Name, NewPanel, Icon, false, false, Desc).Tab

			function tab:Paint(w, h)
				local active = TabSheet:GetActiveTab() == self
				local BackColor = active and Tan or Gray

				if active then
					jdraw.QuickDrawPanel(BackColor, 0, 0, w, h - 6)
					draw.RoundedBox(0, 0, h - 8, w, 2, BackColor)
				else
					jdraw.QuickDrawPanel(BackColor, 0, 0, w, h + 2)
					draw.RoundedBox(0, 0, h - 4, w, 2, BackColor)
				end
			end

			return NewPanel
		end

		return TabSheet
	end

	function CreateGenericListItem(HeaderSize, NameText, Desc, Icon, Color, Expandable, Expanded)
		local NewListItem = vgui.Create("FListItem")
		NewListItem:SetHeaderSize(intHeaderSize)
		NewListItem:SetNameText(NameText)
		NewListItem:SetDescText(Desc)
		NewListItem:SetIcon(Icon)
		NewListItem:SetColor(Color)
		NewListItem:SetExpandable(Expandable)
		NewListItem:SetExpanded(Expanded)

		return NewListItem
	end

	function CreateGenericSlider(Parent, Text, Min, Max, Decimals, ConVar)
		local NewNumSlider = vgui.Create("DNumSlider", Parent)
		NewNumSlider:SetText(Text)
		NewNumSlider:SetMin(Min)
		NewNumSlider:SetMax(Max or Min)
		NewNumSlider:SetDecimals(Decimals or 0)
		NewNumSlider:SetConVar(ConVar)

		return NewNumSlider
	end

	function CreateGenericCheckbox(Parent, Text, ConVar)
		local NewCheckbox = vgui.Create("DCheckboxLabel", Parent)
		NewCheckbox:SetText(Text)
		NewCheckbox:SetConVar(ConVar)
		NewCheckbox:SizeToContents()

		return NewCheckbox
	end

	function CreateGenericImageButton(Parent, Image, ToolTip, Callback)
		local NewButton = vgui.Create("DImageButton", Parent)
		NewButton:SetImage(Image)
		NewButton:SetTooltip(ToolTip)
		NewButton:SizeToContents()
		NewButton.DoClick = Callback

		return NewButton
	end

	local shade = Color(0, 0, 0, 100)
	function CreateGenericButton(Parent, Text)
		local NewButton = vgui.Create("DButton", Parent)
		NewButton:SetText(Text)
		NewButton:SetTextColor(Color(200, 200, 200, 255))

		function NewButton:Paint(w, h)
			local DrawColor = Gray
			local GradDir = 1

			if self:GetDisabled() then
				DrawColor = ColorCopy(Gray, 100)
			elseif self.Depressed or self:IsDown() then
				GradDir = -1
			elseif NewButton.Hovered then
				-- TODO: maybe more visual feedback?
			end

			jdraw.QuickDrawPanel(DrawColor, 0, 0, w, h)
			jdraw.QuickDrawGrad(shade, 0, 0, w, h, GradDir)
		end

		return NewButton
	end

	function CreateGenericPanel(Parent, X, Y, Width, Hieght)
		local NewPanel = vgui.Create("DPanel", Parent)
		NewPanel:SetPos(X, Y)
		NewPanel:SetSize(Width, Hieght)

		function NewPanel:Paint(w, h)
			jdraw.QuickDrawPanel(Gray, 0, 0, w, h)
		end

		return NewPanel
	end

	function CreateGenericMultiChoice(Parent, Text, IsEditable)
		local NewMultiChoice = vgui.Create("DComboBox", Parent)
		NewMultiChoice:SetText(Text or "")
		NewMultiChoice:SetEnabled(IsEditable)

		return NewMultiChoice
	end

	function CreateGenericCollapse(Parent, Name, Spacing, HorizontalScrollEnabled)
		local NewCollapseCat = vgui.Create("DCollapsibleCategory", Parent)
		NewCollapseCat:SetLabel(Name)

		NewCollapseCat.List = vgui.Create("DPanelList")
		NewCollapseCat.List:SetAutoSize(true)
		NewCollapseCat.List:SetSpacing(Spacing)
		NewCollapseCat.List:SetPadding(Spacing)
		NewCollapseCat.List:EnableHorizontal(HorizontalScrollEnabled)
		NewCollapseCat:SetContents(NewCollapseCat.List)

		return NewCollapseCat
	end