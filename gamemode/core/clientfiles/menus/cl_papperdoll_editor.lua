GM.PapperDollEditor = {}
GM.PapperDollEditor.CurrentSlot = nil
GM.PapperDollEditor.CurrentObject = 1
GM.PapperDollEditor.CurrentAddedVector = Vector(0, 0, 0)
GM.PapperDollEditor.CurrentAddedAngle = Angle(0, 0, 0)
GM.PapperDollEditor.CurrentCamRotation = nil
GM.PapperDollEditor.CurrentCamDistance = nil

if not game.SinglePlayer() then return end

function GM.PapperDollEditor.OpenPapperDollEditor()
	local frmPapperDollFrame = vgui.Create("DFrame")
	frmPapperDollFrame.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDemensions(0, 0, frmPapperDollFrame:GetWide(), frmPapperDollFrame:GetTall())
		tblPaintPanel:SetStyle(4, clrTan)
		tblPaintPanel:SetBoarder(1, clrDrakGray)
		jdraw.DrawPanel(tblPaintPanel)
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDemensions(5, 5, frmPapperDollFrame:GetWide() - 10, 15)
		tblPaintPanel:SetStyle(4, clrGray)
		tblPaintPanel:SetBoarder(1, clrDrakGray)
		jdraw.DrawPanel(tblPaintPanel)
	end
	local pnlControlsList = vgui.Create("DPanelList", frmPapperDollFrame)
	pnlControlsList.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDemensions(0, 0, pnlControlsList:GetWide(), pnlControlsList:GetTall())
		tblPaintPanel:SetStyle(4, clrDrakGray)
		tblPaintPanel:SetBoarder(2, clrDrakGray)
		jdraw.DrawPanel(tblPaintPanel)
	end
	local mlcSlotSellector = vgui.Create("DComboBox")
	pnlControlsList:AddItem(mlcSlotSellector)
	local mlcObjectSellector = vgui.Create("DComboBox")
	pnlControlsList:AddItem(mlcObjectSellector)
	local cpcVectorControls = GAMEMODE.PapperDollEditor.AddVectorControls(pnlControlsList)
	local cpcAngleControls = GAMEMODE.PapperDollEditor.AddAngleControls(pnlControlsList)
	local cpcCammeraControls = GAMEMODE.PapperDollEditor.AddCammeraControls(pnlControlsList)
	local btnPrintButton = vgui.Create("DButton")
	pnlControlsList:AddItem(btnPrintButton)
	btnPrintButton.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDemensions(0, 0, btnPrintButton:GetWide(), btnPrintButton:GetTall())
		tblPaintPanel:SetStyle(4, clrGray)
		tblPaintPanel:SetBoarder(2, clrTan)
		jdraw.DrawPanel(tblPaintPanel)
	end

	frmPapperDollFrame:SetPos(50, 50)
	frmPapperDollFrame:SetSize(325, 450)
	frmPapperDollFrame:SetTitle("Papper Doll Editor")
	frmPapperDollFrame:SetVisible(true)
	frmPapperDollFrame:SetDraggable(true)
	frmPapperDollFrame:ShowCloseButton(true)
	frmPapperDollFrame:MakePopup()
	frmPapperDollFrame.btnClose.DoClick = function(btn)
		frmPapperDollFrame:Close()
		GAMEMODE.PapperDollEditor.CurrentCamRotation = nil
		GAMEMODE.PapperDollEditor.CurrentCamDistance = nil
	end

	pnlControlsList:SetPos(5, 30)
	pnlControlsList:SetSize(frmPapperDollFrame:GetWide() - 10, frmPapperDollFrame:GetTall() - 35)
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
		GAMEMODE.PapperDollEditor.CurrentSlot = data
		mlcObjectSellector:Clear()
		mlcObjectSellector:AddChoice(1)
		mlcObjectSellector:ChooseOptionID(1)
		if GAMEMODE.PapperDollEnts[LocalPlayer():EntIndex()] then
			for k, v in pairs(GAMEMODE.PapperDollEnts[LocalPlayer():EntIndex()][data].Children or {}) do
				mlcObjectSellector:AddChoice(k + 1)
			end
		end
	end
	mlcObjectSellector:SetDisabled(false)
	mlcObjectSellector.OnSelect = function(index, value, data)
		data = tonumber(data)
		GAMEMODE.PapperDollEditor.CurrentObject = data
		local strItem = LocalPlayer().Data.Paperdoll[GAMEMODE.PapperDollEditor.CurrentSlot]
		local tblItemTable = GAMEMODE.DataBase.Items[strItem]
		if tblItemTable and tblItemTable.Model[data] then
			GAMEMODE.PapperDollEditor.CurrentAddedVector = tblItemTable.Model[data].Position
			GAMEMODE.PapperDollEditor.CurrentAddedAngle = tblItemTable.Model[data].Angle
			cpcVectorControls.UpdateNewValues(tblItemTable.Model[data].Position)
			cpcAngleControls.UpdateNewValues(tblItemTable.Model[data].Angle)
		end
	end
	btnPrintButton:SetText("Copy Info to Clipboard")
	btnPrintButton.DoClick = function(btnPrintButton) GAMEMODE.PapperDollEditor.PrintNewDementions() end
end
concommand.Add("UD_Dev_EditPapperDoll", function() GAMEMODE.PapperDollEditor.OpenPapperDollEditor() end)

function GM.PapperDollEditor.AddVectorControls(pnlAddList)
	local cpcNewCollapseCat = GAMEMODE.PapperDollEditor.CreateGenericCollapse(pnlAddList, "Offset Controls")
	cpcNewCollapseCat.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDemensions(0, 0, cpcNewCollapseCat:GetWide(), cpcNewCollapseCat:GetTall())
		tblPaintPanel:SetStyle(4, clrTan)
		tblPaintPanel:SetBoarder(1, clrDrakGray)
		jdraw.DrawPanel(tblPaintPanel)
	end
	local nmsNewXSlider = GAMEMODE.PapperDollEditor.CreateGenericSlider(cpcNewCollapseCat.List, "X Axis", 30)
	nmsNewXSlider.ValueChanged = function(self, value) GAMEMODE.PapperDollEditor.CurrentAddedVector.x = value end
	local nmsNewYSlider = GAMEMODE.PapperDollEditor.CreateGenericSlider(cpcNewCollapseCat.List, "Y Axis", 30)
	nmsNewYSlider.ValueChanged = function(self, value) GAMEMODE.PapperDollEditor.CurrentAddedVector.y = value end
	local nmsNewZSlider = GAMEMODE.PapperDollEditor.CreateGenericSlider(cpcNewCollapseCat.List, "Z Axis", 30)
	nmsNewZSlider.ValueChanged = function(self, value) GAMEMODE.PapperDollEditor.CurrentAddedVector.z = value end
	cpcNewCollapseCat.UpdateNewValues = function(vecNewOffset)
		nmsNewXSlider.UpdateSlider(vecNewOffset.x)
		nmsNewYSlider.UpdateSlider(vecNewOffset.y)
		nmsNewZSlider.UpdateSlider(vecNewOffset.z)
	end
	cpcNewCollapseCat.List.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDemensions(0, 0, cpcNewCollapseCat.List:GetWide(), cpcNewCollapseCat.List:GetTall())
		tblPaintPanel:SetStyle(4, clrDrakGray)
		tblPaintPanel:SetBoarder(1, clrTan)
		jdraw.DrawPanel(tblPaintPanel)
	end
	return cpcNewCollapseCat
end

function GM.PapperDollEditor.AddAngleControls(pnlAddList)
	local cpcNewCollapseCat = GAMEMODE.PapperDollEditor.CreateGenericCollapse(pnlAddList, "Angle Controls")
	cpcNewCollapseCat.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDemensions(0, 0, cpcNewCollapseCat:GetWide(), cpcNewCollapseCat:GetTall())
		tblPaintPanel:SetStyle(4, clrTan)
		tblPaintPanel:SetBoarder(1, clrDrakGray)
		jdraw.DrawPanel(tblPaintPanel)
	end
	local nmsNewPitchSlider = GAMEMODE.PapperDollEditor.CreateGenericSlider(cpcNewCollapseCat.List, "Pitch", 180)
	nmsNewPitchSlider.ValueChanged = function(self, value) GAMEMODE.PapperDollEditor.CurrentAddedAngle.p = value end
	local nmsNewYawSlider = GAMEMODE.PapperDollEditor.CreateGenericSlider(cpcNewCollapseCat.List, "Yaw", 180)
	nmsNewYawSlider.ValueChanged = function(self, value) GAMEMODE.PapperDollEditor.CurrentAddedAngle.y = value end
	local nmsNewRollSlider = GAMEMODE.PapperDollEditor.CreateGenericSlider(cpcNewCollapseCat.List, "Roll", 180)
	nmsNewRollSlider.ValueChanged = function(self, value) GAMEMODE.PapperDollEditor.CurrentAddedAngle.r = value end
	cpcNewCollapseCat.UpdateNewValues = function(angNewAngle)
		nmsNewPitchSlider.UpdateSlider(angNewAngle.p)
		nmsNewYawSlider.UpdateSlider(angNewAngle.y)
		nmsNewRollSlider.UpdateSlider(angNewAngle.r)
	end
	cpcNewCollapseCat.List.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDemensions(0, 0, cpcNewCollapseCat.List:GetWide(), cpcNewCollapseCat.List:GetTall())
		tblPaintPanel:SetStyle(4, clrDrakGray)
		tblPaintPanel:SetBoarder(1, clrTan)
		jdraw.DrawPanel(tblPaintPanel)
	end
	return cpcNewCollapseCat
end

function GM.PapperDollEditor.AddCammeraControls(pnlAddList)
	local cpcNewCollapseCat = GAMEMODE.PapperDollEditor.CreateGenericCollapse(pnlAddList, "Cammera Controls")
	cpcNewCollapseCat.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDemensions(0, 0, cpcNewCollapseCat:GetWide(), cpcNewCollapseCat:GetTall())
		tblPaintPanel:SetStyle(4, clrTan)
		tblPaintPanel:SetBoarder(1, clrDrakGray)
		jdraw.DrawPanel(tblPaintPanel)
	end
	local nmsNewRotationSlider = GAMEMODE.PapperDollEditor.CreateGenericSlider(cpcNewCollapseCat.List, "Rotation", 180, 3)
	nmsNewRotationSlider.ValueChanged = function(self, value) GAMEMODE.PapperDollEditor.CurrentCamRotation = value end
	local nmsNewDistanceSlider = GAMEMODE.PapperDollEditor.CreateGenericSlider(cpcNewCollapseCat.List, "Distance", 90)
	nmsNewDistanceSlider.ValueChanged = function(self, value) GAMEMODE.PapperDollEditor.CurrentCamDistance = value end
	cpcNewCollapseCat.List.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDemensions(0, 0, cpcNewCollapseCat.List:GetWide(), cpcNewCollapseCat.List:GetTall())
		tblPaintPanel:SetStyle(4, clrDrakGray)
		tblPaintPanel:SetBoarder(1, clrTan)
		jdraw.DrawPanel(tblPaintPanel)
	end
	return cpcNewCollapseCat
end

function GM.PapperDollEditor.CreateGenericCollapse(pnlAddList, strName)
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

function GM.PapperDollEditor.CreateGenericSlider(pnlAddList, strName, intRange, intDecimals)
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

function GM.PapperDollEditor.PrintNewDementions()
	local vecVector = GAMEMODE.PapperDollEditor.CurrentAddedVector
	local intX, intY, intZ = math.Round(vecVector.x * 10) / 10, math.Round(vecVector.y * 10) / 10, math.Round(vecVector.z * 10) / 10
	local strVector = tostring(intX .. ", " .. intY .. ", " .. intZ)
	local angAngle = GAMEMODE.PapperDollEditor.CurrentAddedAngle
	local intPitch, intYaw, intRoll = math.Round(angAngle.p * 10) / 10, math.Round(angAngle.y * 10) / 10, math.Round(angAngle.r * 10) / 10
	local strAngle = tostring(intPitch .. ", " .. intYaw .. ", " .. intRoll)
	print("Vector(" .. strVector .. "), Angle(" .. strAngle .. ")")
	SetClipboardText("Vector(" .. strVector .. "), Angle(" .. strAngle .. ")")
end
