GM.MapEditor = {}
GM.MapEditor.Open = false
GM.MapEditor.ObjectsList = nil
GM.MapEditor.CurrentObjectSet = nil
GM.MapEditor.ObjectSets = {}
GM.MapEditor.ObjectSets["NPC_Spawnpoints"] = GM.MapEntities.NPCSpawnPoints
GM.MapEditor.ObjectSets["World_Props"] = GM.MapEntities.WorldProps
GM.MapEditor.CurrentObjectNum = nil
GM.MapEditor.Models = {}
GM.MapEditor.Models[1] = "models/props_junk/wood_crate001a.mdl"
GM.MapEditor.Models[2] = "models/props_junk/wood_crate002a.mdl"
GM.MapEditor.Models[3] = "models/props_c17/oildrum001.mdl"
GM.MapEditor.Models[4] = "models/props_c17/oildrum001_explosive.mdl"
GM.MapEditor.Models[5] = "models/props_combine/combinetower001.mdl"
GM.MapEditor.Models[6] = "models/props/CS_militia/caseofbeer01.mdl"
GM.MapEditor.Models[7] = "models/props/CS_militia/footlocker01_closed.mdl"
GM.MapEditor.Models[8] = "models/props_combine/combine_barricade_short01a.mdl"
GM.MapEditor.Models[9] = "models/props_combine/combine_barricade_short01a.mdl"
GM.MapEditor.Models[10] = "models/props_combine/combine_barricade_med01a.mdl"
GM.MapEditor.Models[11] = "models/props_combine/combine_barricade_med01b.mdl"
GM.MapEditor.Models[12] = "models/props_combine/combine_booth_short01a.mdl"
GM.MapEditor.Models[13] = "models/props_interiors/Radiator01a.mdl"
GM.MapEditor.Models[14] = "models/props_wasteland/kitchen_stove001a.mdl"
GM.MapEditor.Models[15] = "models/props/de_piranesi/pi_merlon.mdl"
GM.MapEditor.Models[16] = "models/props/de_inferno/fountain.mdl"
GM.MapEditor.Models[17] = "models/props/de_inferno/crates_fruit1.mdl"
GM.MapEditor.Models[18] = "models/props/de_inferno/crates_fruit2.mdl"
GM.MapEditor.Models[19] = "models/props/de_inferno/ClayOven.mdl"
GM.MapEditor.Models[20] = "models/props/de_inferno/bench_wood.mdl"
GM.MapEditor.Models[21] = "models/props/cs_militia/Furnace01.mdl"
GM.MapEditor.Models[22] = "models/props/cs_italy/it_mkt_table3.mdl"

if not game.SinglePlayer() then return end

function GM.MapEditor.OpenMapEditor()
	local frmMapEditorFrame = CreateGenericFrame("Map Editor", true, true)
	frmMapEditorFrame:SetPos(50, 50)
	frmMapEditorFrame:SetSize(375, 450)
	frmMapEditorFrame:MakePopup()
	frmMapEditorFrame.btnClose.DoClick = function(btn)
		frmMapEditorFrame:Close()
		GAMEMODE.MapEditor.Open = false
	end

	local pnlControlsList = CreateGenericList(frmMapEditorFrame, 5, false, true)
	pnlControlsList:SetPos(5, 55)
	pnlControlsList:SetSize(frmMapEditorFrame:GetWide() - 10, frmMapEditorFrame:GetTall() - 60)

	local mchObjectSetList = vgui.Create("DComboBox", frmMapEditorFrame)
	local wngObjects = vgui.Create("DNumberWang", frmMapEditorFrame)
	GAMEMODE.MapEditor.ObjectsList = wngObjects

	mchObjectSetList:SetPos(75, 30)
	mchObjectSetList:SetSize(frmMapEditorFrame:GetWide() - 135, 20)
	for key, sets in pairs(GAMEMODE.MapEditor.ObjectSets) do mchObjectSetList:AddChoice(key) end
	mchObjectSetList.OnSelect = function(index, value, data)
		GAMEMODE.MapEditor.CurrentObjectSet = GAMEMODE.MapEditor.ObjectSets[data]
		GAMEMODE.MapEditor.CurrentObjectNum = 0
		GAMEMODE.MapEditor.UpatePanel()
		pnlControlsList:Clear()
	end

	wngObjects:SetPos(frmMapEditorFrame:GetWide() - 55, 30)
	wngObjects:SetSize(50, 20)
	wngObjects:SetDecimals(0)
	wngObjects:SetMin(1)
	wngObjects:SetMax(1)
	if GAMEMODE.MapEditor.CurrentObjectSet then
		wngObjects:SetMax(#GAMEMODE.MapEditor.CurrentObjectSet)
	end
	wngObjects.OnValueChanged = function(pnlPanel, intIndex)
		intIndex = math.Round(intIndex)
		if GAMEMODE.MapEditor.CurrentObjectSet and GAMEMODE.MapEditor.CurrentObjectSet[tonumber(intIndex)] then
			GAMEMODE.MapEditor.CurrentObjectNum = tonumber(intIndex)
			if GAMEMODE.MapEditor.CurrentObjectSet == GAMEMODE.MapEntities.NPCSpawnPoints then
				GAMEMODE.MapEditor.AddSpawnPointControls(pnlControlsList)
			elseif GAMEMODE.MapEditor.CurrentObjectSet == GAMEMODE.MapEntities.WorldProps then
				GAMEMODE.MapEditor.AddWorldPropControls(pnlControlsList)
			end
			LocalPlayer():SetEyeAngles((GAMEMODE.MapEditor.CurrentObjectSet[tonumber(intIndex)].Postion - LocalPlayer():GetShootPos()):Angle())
		end
	end

	local function SaveMap() RunConsoleCommand("UD_Dev_EditMap_SaveMap") end
	local btnSaveButton = CreateGenericImageButton(frmMapEditorFrame, "icon16/disk_multiple.png", "Save Map", SaveMap)
	btnSaveButton:SetPos(7, 32)
	btnSaveButton:SetSize(16, 16)

	local function AddObject()
		GAMEMODE.MapEditor.CurrentObjectNum = #GAMEMODE.MapEditor.CurrentObjectSet + 1
		if GAMEMODE.MapEditor.CurrentObjectSet == GAMEMODE.MapEntities.NPCSpawnPoints then
			RunConsoleCommand("UD_Dev_EditMap_CreateSpawnPoint")
		elseif GAMEMODE.MapEditor.CurrentObjectSet == GAMEMODE.MapEntities.WorldProps then
			RunConsoleCommand("UD_Dev_EditMap_CreateWorldProp")
		end
	end
	local btnNewSpawnButton = CreateGenericImageButton(frmMapEditorFrame, "icon16/brick_add.png", "New Object", AddObject)
	btnNewSpawnButton:SetPos(32, 32)
	btnNewSpawnButton:SetSize(16, 16)

	local function RemoveObject()
		pnlControlsList:Clear()
		if GAMEMODE.MapEditor.CurrentObjectSet == GAMEMODE.MapEntities.NPCSpawnPoints then
			RunConsoleCommand("UD_Dev_EditMap_RemoveSpawnPoint", GAMEMODE.MapEditor.CurrentObjectNum)
		elseif GAMEMODE.MapEditor.CurrentObjectSet == GAMEMODE.MapEntities.WorldProps then
			RunConsoleCommand("UD_Dev_EditMap_RemoveWorldProp", GAMEMODE.MapEditor.CurrentObjectNum)
		end
	end
	local btnRemoveButton = CreateGenericImageButton(frmMapEditorFrame, "icon16/delete.png", "Remove Object", RemoveObject)
	btnRemoveButton:SetPos(57, 32)
	btnRemoveButton:SetSize(16, 16)

	GAMEMODE.MapEditor.Open = true
end
concommand.Add("UD_Dev_EditMap", function() GAMEMODE.MapEditor.OpenMapEditor() end)

function GM.MapEditor.UpatePanel()
	if GAMEMODE.MapEditor.Open then
		if not GAMEMODE.MapEditor.CurrentObjectSet then return end
		GAMEMODE.MapEditor.ObjectsList:SetMax(#GAMEMODE.MapEditor.CurrentObjectSet)
		if GAMEMODE.MapEditor.CurrentObjectNum > 0 and GAMEMODE.MapEditor.CurrentObjectSet[GAMEMODE.MapEditor.CurrentObjectNum] then
			GAMEMODE.MapEditor.ObjectsList:SetValue(GAMEMODE.MapEditor.CurrentObjectNum)
		end
	end
end

function GM.MapEditor.AddSpawnPointControls(pnlAddList)
	pnlAddList:Clear()
	local intSpawnKey = GAMEMODE.MapEditor.CurrentObjectNum
	local tblSpawnTable = GAMEMODE.MapEditor.CurrentObjectSet[intSpawnKey]
	local strNPCName = tblSpawnTable.NPC or "zombie"
	local intLevel = tblSpawnTable.Level or 5
	local intSpawnTime = tblSpawnTable.SpawnTime or 0
	local intRotation = tblSpawnTable.Angle.y or 90

	local mchNPCTypes = vgui.Create("DComboBox")
	local intID = 1
	for key, npctable in pairs(GAMEMODE.DataBase.NPCs) do
		mchNPCTypes:AddChoice(key)
		if key == tblSpawnTable.NPC then mchNPCTypes:ChooseOptionID(intID) end
		intID = intID + 1
	end
	mchNPCTypes.OnSelect = function(index, value, data)
		strNPCName = data
	end
	pnlAddList:AddItem(mchNPCTypes)

	local nmsLevel = GAMEMODE.MapEditor.CreateGenericSlider(pnlAddList, "Level", 50, 0)
	nmsLevel:SetMin(0)
	nmsLevel.ValueChanged = function(self, value) intLevel = value end
	nmsLevel.UpdateSlider(intLevel)

	local nmsSpawnTime = GAMEMODE.MapEditor.CreateGenericSlider(pnlAddList, "Spawn Time", 90, 0)
	nmsSpawnTime:SetMin(0)
	nmsSpawnTime.ValueChanged = function(self, value) intSpawnTime = value end
	nmsSpawnTime.UpdateSlider(intSpawnTime)

	local nmsRotation = GAMEMODE.MapEditor.CreateGenericSlider(pnlAddList, "Rotation", 180, 0)
	nmsRotation.ValueChanged = function(self, value) intRotation = value end
	nmsRotation.UpdateSlider(intRotation)

	local btnUpdateServer = vgui.Create("DButton")
	btnUpdateServer:SetText("Update Server")
	btnUpdateServer.DoClick = function()
		RunConsoleCommand("UD_Dev_EditMap_UpdateSpawnPoint", intSpawnKey, strNPCName, intLevel, intSpawnTime, intRotation)
	end
	btnUpdateServer.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDemensions(0, 0, btnUpdateServer:GetWide(), btnUpdateServer:GetTall())
		tblPaintPanel:SetStyle(4, clrGray)
		tblPaintPanel:SetBoarder(2, clrTan)
		jdraw.DrawPanel(tblPaintPanel)
	end
	pnlAddList:AddItem(btnUpdateServer)
end

function GM.MapEditor.AddWorldPropControls(pnlAddList)
	pnlAddList:Clear()
	local intSpawnKey = GAMEMODE.MapEditor.CurrentObjectNum
	local tblSpawnTable = GAMEMODE.MapEditor.CurrentObjectSet[intSpawnKey]
	local strModel = tblSpawnTable.Entity:GetModel() or "models/props_junk/garbage_metalcan001a.mdl"
	local vecOffset = Vector(0, 0, 0)
	local intRotation = 0

	local cpcVectorControls = GAMEMODE.MapEditor.AddVectorControls(pnlAddList)
	cpcVectorControls.ValueChanged = function(vecValue) vecOffset = vecValue end
	cpcVectorControls.UpdateNewValues(vecOffset)

	local nmsRotation = GAMEMODE.MapEditor.CreateGenericSlider(pnlAddList, "Rotation", 180, 0)
	nmsRotation.ValueChanged = function(self, value) intRotation = value end
	nmsRotation.UpdateSlider(intRotation)

	local cpcModelControls = GAMEMODE.MapEditor.AddModelControls(pnlAddList)
	cpcModelControls:SetExpanded(false)
	cpcModelControls.ValueChanged = function(strNewModel) RunConsoleCommand("UD_Dev_EditMap_UpdateWorldProp", intSpawnKey, strNewModel, StringatizeVector(vecOffset), intRotation) end

	local btnUpdateServer = vgui.Create("DButton")
	btnUpdateServer:SetText("Update Server")
	btnUpdateServer.DoClick = function()
		RunConsoleCommand("UD_Dev_EditMap_UpdateWorldProp", intSpawnKey, strModel, StringatizeVector(vecOffset), intRotation)
	end
	btnUpdateServer.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDemensions(0, 0, btnUpdateServer:GetWide(), btnUpdateServer:GetTall())
		tblPaintPanel:SetStyle(4, clrGray)
		tblPaintPanel:SetBoarder(2, clrTan)
		jdraw.DrawPanel(tblPaintPanel)
	end
	pnlAddList:AddItem(btnUpdateServer)
end

function GM.MapEditor.CreateGenericCollapse(pnlAddList, strName)
	local cpcNewCollapseCat = vgui.Create("DCollapsibleCategory")
	cpcNewCollapseCat:SetLabel(strName)
	cpcNewCollapseCat.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDemensions(0, 0, cpcNewCollapseCat:GetWide(), cpcNewCollapseCat:GetTall())
		tblPaintPanel:SetStyle(4, clrTan)
		tblPaintPanel:SetBoarder(1, clrDrakGray)
		jdraw.DrawPanel(tblPaintPanel)
	end
	cpcNewCollapseCat.List = vgui.Create("DPanelList")
	cpcNewCollapseCat.List:SetAutoSize(true)
	cpcNewCollapseCat.List:SetSpacing(5)
	cpcNewCollapseCat.List:SetPadding(5)
	cpcNewCollapseCat.List:EnableHorizontal(false)
	cpcNewCollapseCat.List.Paint = function()
		local tblPaintPanel = jdraw.NewPanel()
		tblPaintPanel:SetDemensions(0, 0, cpcNewCollapseCat.List:GetWide(), cpcNewCollapseCat.List:GetTall())
		tblPaintPanel:SetStyle(4, clrDrakGray)
		tblPaintPanel:SetBoarder(1, clrTan)
		jdraw.DrawPanel(tblPaintPanel)
	end
	cpcNewCollapseCat:SetContents(cpcNewCollapseCat.List)
	pnlAddList:AddItem(cpcNewCollapseCat)
	return cpcNewCollapseCat
end

function GM.MapEditor.AddVectorControls(pnlAddList)
	local vecCommyVector = Vector(0, 0, 0)
	local cpcNewCollapseCat = GAMEMODE.MapEditor.CreateGenericCollapse(pnlAddList, "Offset Controls")
	local nmsNewXSlider = GAMEMODE.MapEditor.CreateGenericSlider(cpcNewCollapseCat.List, "X Axis", 30)
	nmsNewXSlider.ValueChanged = function(self, value) vecCommyVector.x = value cpcNewCollapseCat.ValueChanged(vecCommyVector) end
	local nmsNewYSlider = GAMEMODE.MapEditor.CreateGenericSlider(cpcNewCollapseCat.List, "Y Axis", 30)
	nmsNewYSlider.ValueChanged = function(self, value) vecCommyVector.y = value cpcNewCollapseCat.ValueChanged(vecCommyVector) end
	local nmsNewZSlider = GAMEMODE.MapEditor.CreateGenericSlider(cpcNewCollapseCat.List, "Z Axis", 30)
	nmsNewZSlider.ValueChanged = function(self, value) vecCommyVector.z = value cpcNewCollapseCat.ValueChanged(vecCommyVector) end
	cpcNewCollapseCat.UpdateNewValues = function(vecNewOffset)
		nmsNewXSlider.UpdateSlider(vecNewOffset.x)
		nmsNewYSlider.UpdateSlider(vecNewOffset.y)
		nmsNewZSlider.UpdateSlider(vecNewOffset.z)
	end
	return cpcNewCollapseCat
end

function GM.MapEditor.AddModelControls(pnlAddList)
	local intIconsPerRow = 8
	local cpcNewCollapseCat = GAMEMODE.MapEditor.CreateGenericCollapse(pnlAddList, "Model Controls")
	cpcNewCollapseCat.List:EnableHorizontal(true)
	for key, model in pairs(GAMEMODE.MapEditor.Models) do
		local ModelIcon = vgui.Create("SpawnIcon")
		ModelIcon:SetModel(model)
		ModelIcon:SetIconSize((pnlAddList:GetWide() - ((intIconsPerRow + 1) * 5) - 10) / intIconsPerRow)
		ModelIcon.OnMousePressed = function()
			cpcNewCollapseCat.ValueChanged(model)
		end
		cpcNewCollapseCat.List:AddItem(ModelIcon)
	end
	return cpcNewCollapseCat
end

function GM.MapEditor.CreateGenericSlider(pnlAddList, strName, intRange, intDecimals)
	local nmsNewSlider = vgui.Create("DNumSlider")
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

hook.Add("HUDPaint", "DrawMapObjects", function()
	if GAMEMODE.MapEditor.Open then
		for key, object in pairs(GAMEMODE.MapEditor.CurrentObjectSet or {}) do
			if not key or not object or not object.Postion then return end
			local intPosX, intPosY = object.Postion:ToScreen().x, object.Postion:ToScreen().y
			local clrDrawColor = clrWhite
			if GAMEMODE.MapEditor.CurrentObjectNum == key then clrDrawColor = clrBlue end
			draw.SimpleTextOutlined(key, "UiBold", intPosX, intPosY, clrDrawColor, 1, 1, 1, Color(0, 0, 0, 255))
		end
	end
end)

hook.Add("GUIMouseReleased", "TurnEditorCamGUIMouseReleased", function(mousecode)
	if GAMEMODE.MapEditor.Open then
		LocalPlayer():SetEyeAngles((LocalPlayer():GetEyeTrace().HitPos - LocalPlayer():GetShootPos()):Angle())
	end
end)
