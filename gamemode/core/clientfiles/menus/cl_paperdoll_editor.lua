GM.PaperDollEditor = {}
GM.PaperDollEditor.CurrentSlot = nil
GM.PaperDollEditor.CurrentObject = 1
GM.PaperDollEditor.CurrentAddedVector = Vector(0, 0, 0)
GM.PaperDollEditor.CurrentAddedAngle = Angle(0, 0, 0)
GM.PaperDollEditor.CurrentCamRotation = nil
GM.PaperDollEditor.CurrentCamDistance = nil

if not game.SinglePlayer() then return end

function GM.PaperDollEditor.OpenPaperDollEditor()
	local PaperDollFrame = vgui.Create("DFrame")
	PaperDollFrame.Paint = function()
		local PaintPanel = jdraw.NewPanel()
		PaintPanel:SetDimensions(0, 0, PaperDollFrame:GetWide(), PaperDollFrame:GetTall())
		PaintPanel:SetStyle(4, Tan)
		PaintPanel:SetBorder(1, DrakGray)
		jdraw.DrawPanel(PaintPanel)
		local PaintPanel = jdraw.NewPanel()
		PaintPanel:SetDimensions(5, 5, PaperDollFrame:GetWide() - 10, 15)
		PaintPanel:SetStyle(4, Gray)
		PaintPanel:SetBorder(1, DrakGray)
		jdraw.DrawPanel(PaintPanel)
	end
	local ControlsList = vgui.Create("DPanelList", PaperDollFrame)
	ControlsList.Paint = function()
		local PaintPanel = jdraw.NewPanel()
		PaintPanel:SetDimensions(0, 0, ControlsList:GetWide(), ControlsList:GetTall())
		PaintPanel:SetStyle(4, DrakGray)
		PaintPanel:SetBorder(2, DrakGray)
		jdraw.DrawPanel(PaintPanel)
	end
	local SlotSellector = vgui.Create("DComboBox")
	ControlsList:AddItem(SlotSellector)
	local ObjectSellector = vgui.Create("DComboBox")
	ControlsList:AddItem(ObjectSellector)
	local VectorControls = GAMEMODE.PaperDollEditor.AddVectorControls(ControlsList)
	local AngleControls = GAMEMODE.PaperDollEditor.AddAngleControls(ControlsList)
	local CameraControls = GAMEMODE.PaperDollEditor.AddCameraControls(ControlsList)
	local PrintButton = vgui.Create("DButton")
	ControlsList:AddItem(PrintButton)
	PrintButton.Paint = function()
		local PaintPanel = jdraw.NewPanel()
		PaintPanel:SetDimensions(0, 0, PrintButton:GetWide(), PrintButton:GetTall())
		PaintPanel:SetStyle(4, Gray)
		PaintPanel:SetBorder(2, Tan)
		jdraw.DrawPanel(PaintPanel)
	end

	PaperDollFrame:SetPos(50, 50)
	PaperDollFrame:SetSize(325, 450)
	PaperDollFrame:SetTitle("Paper Doll Editor")
	PaperDollFrame:SetVisible(true)
	PaperDollFrame:SetDraggable(true)
	PaperDollFrame:ShowCloseButton(true)
	PaperDollFrame:MakePopup()
	PaperDollFrame.Close.DoClick = function()
		PaperDollFrame:Close()
		GAMEMODE.PaperDollEditor.CurrentCamRotation = nil
		GAMEMODE.PaperDollEditor.CurrentCamDistance = nil
	end

	ControlsList:SetPos(5, 30)
	ControlsList:SetSize(PaperDollFrame:GetWide() - 10, PaperDollFrame:GetTall() - 35)
	ControlsList:EnableHorizontal(false)
	ControlsList:EnableVerticalScrollbar(true)
	ControlsList:SetSpacing(5)
	ControlsList:SetPadding(5)

	SlotSellector:SetText("Pick the slot")
	SlotSellector:SetDisabled(false)
	for name, slot in pairs(GAMEMODE.DataBase.Slots) do
		SlotSellector:AddChoice(name)
	end
	SlotSellector.OnSelect = function(index, value, data)
		GAMEMODE.PaperDollEditor.CurrentSlot = data
		ObjectSellector:Clear()
		ObjectSellector:AddChoice(1)
		ObjectSellector:ChooseOptionID(1)
		if GAMEMODE.PaperDollEnts[LocalPlayer():SteamID64()] then
			for k, v in pairs(GAMEMODE.PaperDollEnts[LocalPlayer():SteamID64()][data].Children or {}) do
				ObjectSellector:AddChoice(k + 1)
			end
		end
	end
	ObjectSellector:SetDisabled(false)
	ObjectSellector.OnSelect = function(index, value, data)
		data = tonumber(data)
		GAMEMODE.PaperDollEditor.CurrentObject = data
		local Item = LocalPlayer().Data.Paperdoll[GAMEMODE.PaperDollEditor.CurrentSlot]
		local ItemTable = GAMEMODE.DataBase.Items[Item]
		if ItemTable and ItemTable.Model[data] then
			GAMEMODE.PaperDollEditor.CurrentAddedVector = ItemTable.Model[data].Position
			GAMEMODE.PaperDollEditor.CurrentAddedAngle = ItemTable.Model[data].Angle
			VectorControls.UpdateNewValues(ItemTable.Model[data].Position)
			AngleControls.UpdateNewValues(ItemTable.Model[data].Angle)
		end
	end
	PrintButton:SetText("Copy Info to Clipboard")
	PrintButton.DoClick = function(PrintButton) GAMEMODE.PaperDollEditor.PrintNewDementions() end
end
concommand.Add("UD_Dev_EditPaperDoll", function() GAMEMODE.PaperDollEditor.OpenPaperDollEditor() end)

function GM.PaperDollEditor.AddVectorControls(AddList)
	local NewCollapseCat = GAMEMODE.PaperDollEditor.CreateGenericCollapse(AddList, "Offset Controls")
	NewCollapseCat.Paint = function()
		local PaintPanel = jdraw.NewPanel()
		PaintPanel:SetDimensions(0, 0, NewCollapseCat:GetWide(), NewCollapseCat:GetTall())
		PaintPanel:SetStyle(4, Tan)
		PaintPanel:SetBorder(1, DrakGray)
		jdraw.DrawPanel(PaintPanel)
	end
	local NewXSlider = GAMEMODE.PaperDollEditor.CreateGenericSlider(NewCollapseCat.List, "X Axis", 30)
	NewXSlider.ValueChanged = function(self, value) GAMEMODE.PaperDollEditor.CurrentAddedVector.x = value end
	local NewYSlider = GAMEMODE.PaperDollEditor.CreateGenericSlider(NewCollapseCat.List, "Y Axis", 30)
	NewYSlider.ValueChanged = function(self, value) GAMEMODE.PaperDollEditor.CurrentAddedVector.y = value end
	local NewZSlider = GAMEMODE.PaperDollEditor.CreateGenericSlider(NewCollapseCat.List, "Z Axis", 30)
	NewZSlider.ValueChanged = function(self, value) GAMEMODE.PaperDollEditor.CurrentAddedVector.z = value end
	NewCollapseCat.UpdateNewValues = function(vecNewOffset)
		NewXSlider.UpdateSlider(vecNewOffset.x)
		NewYSlider.UpdateSlider(vecNewOffset.y)
		NewZSlider.UpdateSlider(vecNewOffset.z)
	end
	NewCollapseCat.List.Paint = function()
		local PaintPanel = jdraw.NewPanel()
		PaintPanel:SetDimensions(0, 0, NewCollapseCat.List:GetWide(), NewCollapseCat.List:GetTall())
		PaintPanel:SetStyle(4, DrakGray)
		PaintPanel:SetBorder(1, Tan)
		jdraw.DrawPanel(PaintPanel)
	end
	return NewCollapseCat
end

function GM.PaperDollEditor.AddAngleControls(AddList)
	local NewCollapseCat = GAMEMODE.PaperDollEditor.CreateGenericCollapse(AddList, "Angle Controls")
	NewCollapseCat.Paint = function()
		local PaintPanel = jdraw.NewPanel()
		PaintPanel:SetDimensions(0, 0, NewCollapseCat:GetWide(), NewCollapseCat:GetTall())
		PaintPanel:SetStyle(4, Tan)
		PaintPanel:SetBorder(1, DrakGray)
		jdraw.DrawPanel(PaintPanel)
	end
	local NewPitchSlider = GAMEMODE.PaperDollEditor.CreateGenericSlider(NewCollapseCat.List, "Pitch", 180)
	NewPitchSlider.ValueChanged = function(self, value) GAMEMODE.PaperDollEditor.CurrentAddedAngle.p = value end
	local NewYawSlider = GAMEMODE.PaperDollEditor.CreateGenericSlider(NewCollapseCat.List, "Yaw", 180)
	NewYawSlider.ValueChanged = function(self, value) GAMEMODE.PaperDollEditor.CurrentAddedAngle.y = value end
	local NewRollSlider = GAMEMODE.PaperDollEditor.CreateGenericSlider(NewCollapseCat.List, "Roll", 180)
	NewRollSlider.ValueChanged = function(self, value) GAMEMODE.PaperDollEditor.CurrentAddedAngle.r = value end
	NewCollapseCat.UpdateNewValues = function(angNewAngle)
		NewPitchSlider.UpdateSlider(angNewAngle.p)
		NewYawSlider.UpdateSlider(angNewAngle.y)
		NewRollSlider.UpdateSlider(angNewAngle.r)
	end
	NewCollapseCat.List.Paint = function()
		local PaintPanel = jdraw.NewPanel()
		PaintPanel:SetDimensions(0, 0, NewCollapseCat.List:GetWide(), NewCollapseCat.List:GetTall())
		PaintPanel:SetStyle(4, DrakGray)
		PaintPanel:SetBorder(1, Tan)
		jdraw.DrawPanel(PaintPanel)
	end
	return NewCollapseCat
end

function GM.PaperDollEditor.AddCameraControls(AddList)
	local NewCollapseCat = GAMEMODE.PaperDollEditor.CreateGenericCollapse(AddList, "Camera Controls")
	NewCollapseCat.Paint = function()
		local PaintPanel = jdraw.NewPanel()
		PaintPanel:SetDimensions(0, 0, NewCollapseCat:GetWide(), NewCollapseCat:GetTall())
		PaintPanel:SetStyle(4, Tan)
		PaintPanel:SetBorder(1, DrakGray)
		jdraw.DrawPanel(PaintPanel)
	end
	local NewRotationSlider = GAMEMODE.PaperDollEditor.CreateGenericSlider(NewCollapseCat.List, "Rotation", 180, 3)
	NewRotationSlider.ValueChanged = function(self, value) GAMEMODE.PaperDollEditor.CurrentCamRotation = value end
	local NewDistanceSlider = GAMEMODE.PaperDollEditor.CreateGenericSlider(NewCollapseCat.List, "Distance", 90)
	NewDistanceSlider.ValueChanged = function(self, value) GAMEMODE.PaperDollEditor.CurrentCamDistance = value end
	NewCollapseCat.List.Paint = function()
		local PaintPanel = jdraw.NewPanel()
		PaintPanel:SetDimensions(0, 0, NewCollapseCat.List:GetWide(), NewCollapseCat.List:GetTall())
		PaintPanel:SetStyle(4, DrakGray)
		PaintPanel:SetBorder(1, Tan)
		jdraw.DrawPanel(PaintPanel)
	end
	return NewCollapseCat
end

function GM.PaperDollEditor.CreateGenericCollapse(AddList, Name)
	local NewCollapseCat = vgui.Create("DCollapsibleCategory")
	NewCollapseCat:SetLabel(Name)
	NewCollapseCat.List = vgui.Create("DPanelList")
	NewCollapseCat.List:SetAutoSize(true)
	NewCollapseCat.List:SetSpacing(5)
	NewCollapseCat.List:SetPadding(2)
	NewCollapseCat.List:EnableHorizontal(false)
	NewCollapseCat:SetContents(NewCollapseCat.List)
	AddList:AddItem(NewCollapseCat)
	return NewCollapseCat
end

function GM.PaperDollEditor.CreateGenericSlider(AddList, Name, Range, Decimals)
	local NewSlider = vgui.Create("DNumSlider")
	if not Range then Range = 50 end
	NewSlider:SetText(Name)
	NewSlider:SetMin(-Range)
	NewSlider:SetMax(Range)
	NewSlider:SetDecimals(Decimals or 1)
	NewSlider.UpdateSlider = function(NewValue)
		NewSlider:SetValue(NewValue)
		NewSlider.Slider:SetSlideX(NewSlider.Wang:GetFraction())
	end
	AddList:AddItem(NewSlider)
	return NewSlider
end

function GM.PaperDollEditor.PrintNewDementions()
	local AVector = GAMEMODE.PaperDollEditor.CurrentAddedVector
	local X, Y, Z = math.Round(AVector.x * 10) / 10, math.Round(AVector.y * 10) / 10, math.Round(AVector.z * 10) / 10
	local Vector_String = tostring(X .. ", " .. Y .. ", " .. Z)
	local AAngle = GAMEMODE.PaperDollEditor.CurrentAddedAngle
	local Pitch, Yaw, Roll = math.Round(AAngle.p * 10) / 10, math.Round(AAngle.y * 10) / 10, math.Round(AAngle.r * 10) / 10
	local Angle_String = tostring(Pitch .. ", " .. Yaw .. ", " .. Roll)
	print("Vector(" .. Vector_String .. "), Angle(" .. Angle_String .. ")")
	SetClipboardText("Vector(" .. Vector_String .. "), Angle(" .. Angle_String .. ")")
end
