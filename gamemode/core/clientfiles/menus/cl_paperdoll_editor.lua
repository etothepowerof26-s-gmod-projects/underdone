GM.PaperDollEditor = {}
GM.PaperDollEditor.CurrentSlot = nil
GM.PaperDollEditor.CurrentObject = 1
GM.PaperDollEditor.CurrentAddedVector = Vector(0, 0, 0)
GM.PaperDollEditor.CurrentAddedAngle = Angle(0, 0, 0)
GM.PaperDollEditor.CurrentCamRotation = nil
GM.PaperDollEditor.CurrentCamDistance = nil

if not game.SinglePlayer() then return end

function GM.PaperDollEditor.OpenPaperDollEditor()
	local frmPaperDollFrame = vgui.Create("DFrame")
	frmPaperDollFrame.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDimensions(0, 0, frmPaperDollFrame:GetWide(), frmPaperDollFrame:GetTall())
		tblPaintPanel:SetStyle(4, clrTan)
		tblPaintPanel:SetBorder(1, clrDrakGray)
		jdraw.DrawPanel(tblPaintPanel)
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDimensions(5, 5, frmPaperDollFrame:GetWide() - 10, 15)
		tblPaintPanel:SetStyle(4, clrGray)
		tblPaintPanel:SetBorder(1, clrDrakGray)
		jdraw.DrawPanel(tblPaintPanel)
	end
	local pnlControlsList = vgui.Create("DPanelList", frmPaperDollFrame)
	pnlControlsList.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDimensions(0, 0, pnlControlsList:GetWide(), pnlControlsList:GetTall())
		tblPaintPanel:SetStyle(4, clrDrakGray)
		tblPaintPanel:SetBorder(2, clrDrakGray)
		jdraw.DrawPanel(tblPaintPanel)
	end
	local mlcSlotSellector = vgui.Create("DComboBox")
	pnlControlsList:AddItem(mlcSlotSellector)
	local mlcObjectSellector = vgui.Create("DComboBox")
	pnlControlsList:AddItem(mlcObjectSellector)
	local cpcVectorControls = GAMEMODE.PaperDollEditor.AddVectorControls(pnlControlsList)
	local cpcAngleControls = GAMEMODE.PaperDollEditor.AddAngleControls(pnlControlsList)
	local cpcCameraControls = GAMEMODE.PaperDollEditor.AddCameraControls(pnlControlsList)
	local btnPrintButton = vgui.Create("DButton")
	pnlControlsList:AddItem(btnPrintButton)
	btnPrintButton.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDimensions(0, 0, btnPrintButton:GetWide(), btnPrintButton:GetTall())
		tblPaintPanel:SetStyle(4, clrGray)
		tblPaintPanel:SetBorder(2, clrTan)
		jdraw.DrawPanel(tblPaintPanel)
	end

	frmPaperDollFrame:SetPos(50, 50)
	frmPaperDollFrame:SetSize(325, 450)
	frmPaperDollFrame:SetTitle("Paper Doll Editor")
	frmPaperDollFrame:SetVisible(true)
	frmPaperDollFrame:SetDraggable(true)
	frmPaperDollFrame:ShowCloseButton(true)
	frmPaperDollFrame:MakePopup()
	frmPaperDollFrame.btnClose.DoClick = function(btn)
		frmPaperDollFrame:Close()
		GAMEMODE.PaperDollEditor.CurrentCamRotation = nil
		GAMEMODE.PaperDollEditor.CurrentCamDistance = nil
	end

	pnlControlsList:SetPos(5, 30)
	pnlControlsList:SetSize(frmPaperDollFrame:GetWide() - 10, frmPaperDollFrame:GetTall() - 35)
	pnlControlsList:EnableHorizontal(false)
	pnlControlsList:EnableVerticalScrollbar(true)
	pnlControlsList:SetSpacing(5)
	pnlControlsList:SetPadding(5)

	mlcSlotSellector:SetText("Pick the slot")
	mlcSlotSellector:SetDisabled(false)
	for name, slot in pairs(GAMEMODE.DataBase.Slots) do
		mlcSlotSellector:AddChoice(name)
	end
	mlcSlotSellector.OnSelect = function(index, value, data)
		GAMEMODE.PaperDollEditor.CurrentSlot = data
		mlcObjectSellector:Clear()
		mlcObjectSellector:AddChoice(1)
		mlcObjectSellector:ChooseOptionID(1)
		if GAMEMODE.PaperDollEnts[LocalPlayer():SteamID64()] then
			for k, v in pairs(GAMEMODE.PaperDollEnts[LocalPlayer():SteamID64()][data].Children or {}) do
				mlcObjectSellector:AddChoice(k + 1)
			end
		end
	end
	mlcObjectSellector:SetDisabled(false)
	mlcObjectSellector.OnSelect = function(index, value, data)
		data = tonumber(data)
		GAMEMODE.PaperDollEditor.CurrentObject = data
		local strItem = LocalPlayer().Data.Paperdoll[GAMEMODE.PaperDollEditor.CurrentSlot]
		local tblItemTable = GAMEMODE.DataBase.Items[strItem]
		if tblItemTable and tblItemTable.Model[data] then
			GAMEMODE.PaperDollEditor.CurrentAddedVector = tblItemTable.Model[data].Position
			GAMEMODE.PaperDollEditor.CurrentAddedAngle = tblItemTable.Model[data].Angle
			cpcVectorControls.UpdateNewValues(tblItemTable.Model[data].Position)
			cpcAngleControls.UpdateNewValues(tblItemTable.Model[data].Angle)
		end
	end
	btnPrintButton:SetText("Copy Info to Clipboard")
	btnPrintButton.DoClick = function(btnPrintButton) GAMEMODE.PaperDollEditor.PrintNewDementions() end
end
concommand.Add("UD_Dev_EditPaperDoll", function() GAMEMODE.PaperDollEditor.OpenPaperDollEditor() end)

function GM.PaperDollEditor.AddVectorControls(pnlAddList)
	local cpcNewCollapseCat = GAMEMODE.PaperDollEditor.CreateGenericCollapse(pnlAddList, "Offset Controls")
	cpcNewCollapseCat.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDimensions(0, 0, cpcNewCollapseCat:GetWide(), cpcNewCollapseCat:GetTall())
		tblPaintPanel:SetStyle(4, clrTan)
		tblPaintPanel:SetBorder(1, clrDrakGray)
		jdraw.DrawPanel(tblPaintPanel)
	end
	local nmsNewXSlider = GAMEMODE.PaperDollEditor.CreateGenericSlider(cpcNewCollapseCat.List, "X Axis", 30)
	nmsNewXSlider.ValueChanged = function(self, value) GAMEMODE.PaperDollEditor.CurrentAddedVector.x = value end
	local nmsNewYSlider = GAMEMODE.PaperDollEditor.CreateGenericSlider(cpcNewCollapseCat.List, "Y Axis", 30)
	nmsNewYSlider.ValueChanged = function(self, value) GAMEMODE.PaperDollEditor.CurrentAddedVector.y = value end
	local nmsNewZSlider = GAMEMODE.PaperDollEditor.CreateGenericSlider(cpcNewCollapseCat.List, "Z Axis", 30)
	nmsNewZSlider.ValueChanged = function(self, value) GAMEMODE.PaperDollEditor.CurrentAddedVector.z = value end
	cpcNewCollapseCat.UpdateNewValues = function(vecNewOffset)
		nmsNewXSlider.UpdateSlider(vecNewOffset.x)
		nmsNewYSlider.UpdateSlider(vecNewOffset.y)
		nmsNewZSlider.UpdateSlider(vecNewOffset.z)
	end
	cpcNewCollapseCat.List.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDimensions(0, 0, cpcNewCollapseCat.List:GetWide(), cpcNewCollapseCat.List:GetTall())
		tblPaintPanel:SetStyle(4, clrDrakGray)
		tblPaintPanel:SetBorder(1, clrTan)
		jdraw.DrawPanel(tblPaintPanel)
	end
	return cpcNewCollapseCat
end

function GM.PaperDollEditor.AddAngleControls(pnlAddList)
	local cpcNewCollapseCat = GAMEMODE.PaperDollEditor.CreateGenericCollapse(pnlAddList, "Angle Controls")
	cpcNewCollapseCat.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDimensions(0, 0, cpcNewCollapseCat:GetWide(), cpcNewCollapseCat:GetTall())
		tblPaintPanel:SetStyle(4, clrTan)
		tblPaintPanel:SetBorder(1, clrDrakGray)
		jdraw.DrawPanel(tblPaintPanel)
	end
	local nmsNewPitchSlider = GAMEMODE.PaperDollEditor.CreateGenericSlider(cpcNewCollapseCat.List, "Pitch", 180)
	nmsNewPitchSlider.ValueChanged = function(self, value) GAMEMODE.PaperDollEditor.CurrentAddedAngle.p = value end
	local nmsNewYawSlider = GAMEMODE.PaperDollEditor.CreateGenericSlider(cpcNewCollapseCat.List, "Yaw", 180)
	nmsNewYawSlider.ValueChanged = function(self, value) GAMEMODE.PaperDollEditor.CurrentAddedAngle.y = value end
	local nmsNewRollSlider = GAMEMODE.PaperDollEditor.CreateGenericSlider(cpcNewCollapseCat.List, "Roll", 180)
	nmsNewRollSlider.ValueChanged = function(self, value) GAMEMODE.PaperDollEditor.CurrentAddedAngle.r = value end
	cpcNewCollapseCat.UpdateNewValues = function(angNewAngle)
		nmsNewPitchSlider.UpdateSlider(angNewAngle.p)
		nmsNewYawSlider.UpdateSlider(angNewAngle.y)
		nmsNewRollSlider.UpdateSlider(angNewAngle.r)
	end
	cpcNewCollapseCat.List.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDimensions(0, 0, cpcNewCollapseCat.List:GetWide(), cpcNewCollapseCat.List:GetTall())
		tblPaintPanel:SetStyle(4, clrDrakGray)
		tblPaintPanel:SetBorder(1, clrTan)
		jdraw.DrawPanel(tblPaintPanel)
	end
	return cpcNewCollapseCat
end

function GM.PaperDollEditor.AddCameraControls(pnlAddList)
	local cpcNewCollapseCat = GAMEMODE.PaperDollEditor.CreateGenericCollapse(pnlAddList, "Camera Controls")
	cpcNewCollapseCat.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDimensions(0, 0, cpcNewCollapseCat:GetWide(), cpcNewCollapseCat:GetTall())
		tblPaintPanel:SetStyle(4, clrTan)
		tblPaintPanel:SetBorder(1, clrDrakGray)
		jdraw.DrawPanel(tblPaintPanel)
	end
	local nmsNewRotationSlider = GAMEMODE.PaperDollEditor.CreateGenericSlider(cpcNewCollapseCat.List, "Rotation", 180, 3)
	nmsNewRotationSlider.ValueChanged = function(self, value) GAMEMODE.PaperDollEditor.CurrentCamRotation = value end
	local nmsNewDistanceSlider = GAMEMODE.PaperDollEditor.CreateGenericSlider(cpcNewCollapseCat.List, "Distance", 90)
	nmsNewDistanceSlider.ValueChanged = function(self, value) GAMEMODE.PaperDollEditor.CurrentCamDistance = value end
	cpcNewCollapseCat.List.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDimensions(0, 0, cpcNewCollapseCat.List:GetWide(), cpcNewCollapseCat.List:GetTall())
		tblPaintPanel:SetStyle(4, clrDrakGray)
		tblPaintPanel:SetBorder(1, clrTan)
		jdraw.DrawPanel(tblPaintPanel)
	end
	return cpcNewCollapseCat
end

function GM.PaperDollEditor.CreateGenericCollapse(pnlAddList, strName)
	local cpcNewCollapseCat = vgui.Create("DCollapsibleCategory")
	cpcNewCollapseCat:SetLabel(strName)
	cpcNewCollapseCat.List = vgui.Create("DPanelList")
	cpcNewCollapseCat.List:SetAutoSize(true)
	cpcNewCollapseCat.List:SetSpacing(5)
	cpcNewCollapseCat.List:SetPadding(2)
	cpcNewCollapseCat.List:EnableHorizontal(false)
	cpcNewCollapseCat:SetContents(cpcNewCollapseCat.List)
	pnlAddList:AddItem(cpcNewCollapseCat)
	return cpcNewCollapseCat
end

function GM.PaperDollEditor.CreateGenericSlider(pnlAddList, strName, intRange, intDecimals)
	local nmsNewSlider = vgui.Create("DNumSlider")
	if not intRange then intRange = 50 end
	nmsNewSlider:SetText(strName)
	nmsNewSlider:SetMin(-intRange)
	nmsNewSlider:SetMax(intRange)
	nmsNewSlider:SetDecimals(intDecimals or 1)
	nmsNewSlider.UpdateSlider = function(intNewValue)
		nmsNewSlider:SetValue(intNewValue)
		nmsNewSlider.Slider:SetSlideX(nmsNewSlider.Wang:GetFraction())
	end
	pnlAddList:AddItem(nmsNewSlider)
	return nmsNewSlider
end

function GM.PaperDollEditor.PrintNewDementions()
	local vecVector = GAMEMODE.PaperDollEditor.CurrentAddedVector
	local intX, intY, intZ = math.Round(vecVector.x * 10) / 10, math.Round(vecVector.y * 10) / 10, math.Round(vecVector.z * 10) / 10
	local strVector = tostring(intX .. ", " .. intY .. ", " .. intZ)
	local angAngle = GAMEMODE.PaperDollEditor.CurrentAddedAngle
	local intPitch, intYaw, intRoll = math.Round(angAngle.p * 10) / 10, math.Round(angAngle.y * 10) / 10, math.Round(angAngle.r * 10) / 10
	local strAngle = tostring(intPitch .. ", " .. intYaw .. ", " .. intRoll)
	print("Vector(" .. strVector .. "), Angle(" .. strAngle .. ")")
	SetClipboardText("Vector(" .. strVector .. "), Angle(" .. strAngle .. ")")
end
