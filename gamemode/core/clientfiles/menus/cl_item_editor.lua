GM.ItemEditor = nil
GM.ItemEditorSettings = {}
GM.ItemEditorSettings.CurrentEditingSlot = nil
GM.ItemEditorSettings.CurrentEditingItemModel = 1
GM.ItemEditorSettings.CurrentEditingVector = Vector(0, 0, 0)
GM.ItemEditorSettings.CurrentEditingAngle = Angle(0, 0, 0)
GM.ItemEditorSettings.CurrentEditingMat = nil
GM.ItemEditorSettings.CurrentEditingScale = Vector(1, 1, 1)
GM.ItemEditorSettings.CurrentCamRotation = nil
GM.ItemEditorSettings.CurrentCamDistance = nil
local GlobalPadding = 5
local ToolBarIconSize = 16
local UsableMats = {}
UsableMats[1] = "Models/props_c17/FurnitureMetal002a.vtf"
UsableMats[2] = "Models/Gibs/metalgibs/metal_gibs.vtf"
UsableMats[3] = "Models/props_building_details/courtyard_template001c_bars.vtf"
UsableMats[4] = "Models/props_building_details/courtyard_template001c_bars_dark.vtf"
UsableMats[5] = "Models/props_c17/Metalladder001.vtf"
UsableMats[6] = "Models/props_c17/Metalladder002.vtf"
UsableMats[7] = "Models/props_c17/Metalladder003.vtf"
UsableMats[8] = "Models/props_junk/rock_junk001a.vtf"
UsableMats[9] = "Models/props_lab/door_klab01.vtf"
UsableMats[10] = "Models/props_pipes/GutterMetal01a.vtf"
UsableMats[11] = "Models/props_pipes/pipeset_metal.vtf"
UsableMats[12] = "Models/props_pipes/pipeset_metal02.vtf"
UsableMats[13] = "Models/props_pipes/Pipesystem01a_skin3.vtf"
UsableMats[14] = "Models/props_lab/cornerunit_cloud.vtf"
UsableMats[15] = "Models/props_lab/glass_tint001.vtf"
UsableMats[16] = "Models/props_wasteland/rockgranite02a.vtf"
UsableMats[17] = "debug/env_cubemap_model.vtf"
UsableMats[18] = "Models/props_mining/barrier.vtf"
UsableMats[19] = "Models/props_mining/mesh_ceiling.vtf"
UsableMats[20] = "Models/props_mining/stalactite_rock01.vtf"
UsableMats[21] = "Models/props_mining/warehouse_ceiling01.vtf"
UsableMats[22] = "Models/props_mining/wood_stack.vtf"
UsableMats[23] = "Models/props_silo/de_train_handrails_01.vtf"
UsableMats[24] = "Models/props_silo/de_train_handrails_02.vtf"
UsableMats[25] = "Models/props_silo/fanglow.vtf"
UsableMats[26] = "Models/props_silo/turret.vtf"
UsableMats[27] = "Models/props_silo/transformer.vtf"
UsableMats[28] = "Models/Magnusson_Teleporter/magnusson_teleporter_fxglow_off.vtf"
UsableMats[29] = "Models/Magnusson_Teleporter/magnusson_teleporter_fxglow1.vtf"
UsableMats[30] = "Models/grub_nugget/grub_nugget.vtf"
UsableMats[31] = "Models/Combine_Turrets/combine_cannon.vtf"
UsableMats[32] = "Models/effects/vol_lightmask01.vtf"
UsableMats[33] = "Models/effects/vol_lightmask02.vtf"
UsableMats[34] = "Models/Combine_Helicopter/helicopter_bomb01.vtf"
UsableMats[35] = "Models/Combine_Helicopter/helicopter_bomb_off01.vtf"

if not game.SinglePlayer() then return end

local PANEL = {}
function PANEL:Init()
	self.Frame = CreateGenericFrame("Item Editor", true, true)
	self.Frame.CloseButton.DoClick = function(Panel)
		GAMEMODE.ItemEditor.Frame:Close()
		GAMEMODE.ItemEditor = nil
		GAMEMODE.ItemEditorSettings.CurrentCamRotation = nil
		GAMEMODE.ItemEditorSettings.CurrentCamDistance = nil
	end

	self.ToolBar = CreateGenericList(self.Frame, intGlobalPadding, true, false)
	self:AddToolButton("icon16/folder_go.png", "Load Item", function()
		local function fncGivePlayerItem(Item)
			RunConsoleCommand("ud_edit_items_giveitem", Item)
		end
		local LoadItems = DermaMenu()
		local Weapons = LoadItems:AddSubMenu("Weapons")
			local WeaponsRanged = Weapons:AddSubMenu("Ranged")
			local WeaponsMelee = Weapons:AddSubMenu("Melee")
		local Armor = LoadItems:AddSubMenu("Armor")
			local ArmorHelm = Armor:AddSubMenu("Helm")
			local ArmorChest = Armor:AddSubMenu("Chest")
			local ArmorShield = Armor:AddSubMenu("Shield")
			local ArmorShoulder = Armor:AddSubMenu("Shoulder")
		for Item, ItemTable in pairs(GAMEMODE.DataBase.Items) do
			if string.find(Item, "weapon_") then
				if string.find(Item, "_ranged_") then
					WeaponsRanged:AddOption(Item, function() fncGivePlayerItem(Item) end)
				elseif string.find(Item, "_melee_") then
					WeaponsMelee:AddOption(Item, function() fncGivePlayerItem(Item) end)
				else
					Weapons:AddOption(Item, function() fncGivePlayerItem(Item) end)
				end
			end
			if string.find(Item, "armor_") then
				if string.find(Item, "_helm_") then
					ArmorHelm:AddOption(Item, function() fncGivePlayerItem(Item) end)
				elseif string.find(Item, "_chest_") then
					ArmorChest:AddOption(Item, function() fncGivePlayerItem(Item) end)
				elseif string.find(Item, "_sheild_") or string.find(Item, "_shield_") then --Fuck my spelling ><
					ArmorShield:AddOption(Item, function() fncGivePlayerItem(Item) end)
				elseif string.find(Item, "_shoulder_") then
					ArmorShoulder:AddOption(Item, function() fncGivePlayerItem(Item) end)
				else
					Armor:AddOption(Item, function() fncGivePlayerItem(Item) end)
				end
			end
		end
		LoadItems:Open()
	end)
	self:AddToolButton("icon16/cross.png", "Clear Paperdoll", function()
		RunConsoleCommand("ud_edit_items_clearpaperdoll")
	end)
	self:AddToolButton("icon16/page.png", "Copy Dementions to clip board", function() self:PrintNewDementions() end)
	self.SlotSwitch, self.ObjectSwitch = self:AddSlotControls()

	self.ControlsList = CreateGenericList(self.Frame, intGlobalPadding, false, true)
	self.VectorControls = self:AddControl(self:AddVectorControls())
	self.AngleControls = self:AddControl(self:AddAngleControls())
	self.MatControls = self:AddControl(self:AddMatControls())
	self.ScaleControls = self:AddControl(self:AddScaleControls())
	self.CameraControls = self:AddControl(self:AddCameraControls())


	self.Frame:MakePopup()
	self:PerformLayout()
end

function PANEL:PerformLayout()
	self.Frame:SetPos(self:GetPos())
	self.Frame:SetSize(self:GetSize())
	self.ToolBar:SetPos(intGlobalPadding, 25)
	self.ToolBar:SetSize(self:GetWide() - (intGlobalPadding * 2), intToolBarIconSize + (intGlobalPadding * 2))
	self.ControlsList:SetPos(intGlobalPadding, 25 + self.ToolBar:GetTall() + intGlobalPadding)
	self.ControlsList:SetSize(self:GetWide() - (intGlobalPadding * 2), self:GetTall() - (25 + self.ToolBar:GetTall() + (intGlobalPadding * 2)))
	for _, Icon in pairs(self.MatControls.Icons or {}) do
		Icon:SetSize(38, 38)
	end
end

function PANEL:UpdateSellectors(Slot)
	self.SlotSwitch:Clear()
	for InSlot, _ in pairs(LocalPlayer().Data.Paperdoll or {}) do
		self.SlotSwitch:AddChoice(InSlot)
	end
	timer.Simple(0.1, function() self.SlotSwitch:ChooseOption(Slot) end)
end

function PANEL:AddToolButton(Image, ToolTip, fncFunction)
	local NewToolButton = CreateGenericImageButton(nil, Image, ToolTip, fncFunction)
	NewToolButton:SetSize(intToolBarIconSize, intToolBarIconSize)
	self.ToolBar:AddItem(NewToolButton)
end

function PANEL:AddControl(Control)
	self.ControlsList:AddItem(Control)
	return Control
end

function PANEL:AddSlotControls()
	local SlotSellector = CreateGenericMultiChoice()
	SlotSellector:SetSize(120, intToolBarIconSize)
	self.ToolBar:AddItem(SlotSellector)

	local ObjectSellector = CreateGenericMultiChoice()
	ObjectSellector:SetSize(50, intToolBarIconSize)
	self.ToolBar:AddItem(ObjectSellector)

	SlotSellector.OnSelect = function(index, value, data)
		if !LocalPlayer().Data.Paperdoll[data] then return false end
		GAMEMODE.ItemEditorSettings.CurrentEditingSlot = data
		ObjectSellector:Clear()
		ObjectSellector:AddChoice(1)
		ObjectSellector:ChooseOptionID(1)
		if GAMEMODE.PaperDollEnts[LocalPlayer():SteamID64()] && GAMEMODE.PaperDollEnts[LocalPlayer():SteamID64()][data] then
			for k, v in pairs(GAMEMODE.PaperDollEnts[LocalPlayer():SteamID64()][data].Children or {}) do
				ObjectSellector:AddChoice(k + 1)
			end
		end
	end
	ObjectSellector.OnSelect = function(index, value, data)
		data = tonumber(data)
		GAMEMODE.ItemEditorSettings.CurrentEditingItemModel = data
		local Item = LocalPlayer().Data.Paperdoll[GAMEMODE.ItemEditorSettings.CurrentEditingSlot]
		local ItemTable = GAMEMODE.DataBase.Items[Item]
		if ItemTable && ItemTable.Model[data] then
			GAMEMODE.ItemEditorSettings.CurrentEditingVector = ItemTable.Model[data].Position
			GAMEMODE.ItemEditorSettings.CurrentEditingAngle = ItemTable.Model[data].Angle
			GAMEMODE.ItemEditorSettings.CurrentEditingMat = ItemTable.Model[data].Material
			GAMEMODE.ItemEditorSettings.CurrentEditingScale = ItemTable.Model[data].Scale or Vector(1, 1, 1)
			self.VectorControls.UpdateNewValues(ItemTable.Model[data].Position)
			self.AngleControls.UpdateNewValues(ItemTable.Model[data].Angle)
			self.ScaleControls.UpdateNewValues(ItemTable.Model[data].Scale or Vector(1, 1, 1))
		end
	end
	return SlotSellector, ObjectSellector
end

function PANEL:AddVectorControls()
	local NewCollapseCat = CreateGenericCollapse(nil, "Offset Controls", intGlobalPadding, false)
	local NewXSlider = CreateGenericSlider(nil, "X Axis", -40, 40, 2)
	NewXSlider.ValueChanged = function(self, value) GAMEMODE.ItemEditorSettings.CurrentEditingVector.x = value end
	NewCollapseCat.List:AddItem(NewXSlider)
	local NewYSlider = CreateGenericSlider(nil, "Y Axis", -40, 40, 2)
	NewYSlider.ValueChanged = function(self, value) GAMEMODE.ItemEditorSettings.CurrentEditingVector.y = value end
	NewCollapseCat.List:AddItem(NewYSlider)
	local NewZSlider = CreateGenericSlider(nil, "Z Axis", -40, 40, 2)
	NewZSlider.ValueChanged = function(self, value) GAMEMODE.ItemEditorSettings.CurrentEditingVector.z = value end
	NewCollapseCat.List:AddItem(NewZSlider)
	NewCollapseCat.UpdateNewValues = function(vecNewOffset)
		NewXSlider.UpdateSlider(vecNewOffset.x)
		NewYSlider.UpdateSlider(vecNewOffset.y)
		NewZSlider.UpdateSlider(vecNewOffset.z)
	end
	return NewCollapseCat
end

function PANEL:AddAngleControls()
	local NewCollapseCat = CreateGenericCollapse(nil, "Angle Controls", intGlobalPadding, false)
	local NewXSlider = CreateGenericSlider(nil, "Pitch", -180, 180, 2)
	NewXSlider.ValueChanged = function(self, value) GAMEMODE.ItemEditorSettings.CurrentEditingAngle.p = value end
	NewCollapseCat.List:AddItem(NewXSlider)
	local NewYSlider = CreateGenericSlider(nil, "Yaw", -180, 180, 2)
	NewYSlider.ValueChanged = function(self, value) GAMEMODE.ItemEditorSettings.CurrentEditingAngle.y = value end
	NewCollapseCat.List:AddItem(NewYSlider)
	local NewZSlider = CreateGenericSlider(nil, "Roll", -180, 180, 2)
	NewZSlider.ValueChanged = function(self, value) GAMEMODE.ItemEditorSettings.CurrentEditingAngle.r = value end
	NewCollapseCat.List:AddItem(NewZSlider)
	NewCollapseCat.UpdateNewValues = function(angNewAngle)
		NewXSlider.UpdateSlider(angNewAngle.p)
		NewYSlider.UpdateSlider(angNewAngle.y)
		NewZSlider.UpdateSlider(angNewAngle.r)
	end
	return NewCollapseCat
end

function PANEL:AddMatControls()
	local NewCollapseCat = CreateGenericCollapse(nil, "Material Controls", intGlobalPadding, true)
	NewCollapseCat.Icons = {}
	local NewMatButton = CreateGenericImageButton(nil, "null", "", function() GAMEMODE.ItemEditorSettings.CurrentEditingMat = "" end)
	NewCollapseCat.List:AddItem(NewMatButton)
	table.insert(NewCollapseCat.Icons, NewMatButton)
	for _, Texture in pairs(UsableMats or {}) do
		local NewMatButton = CreateGenericImageButton(nil, Texture, Texture, function() GAMEMODE.ItemEditorSettings.CurrentEditingMat = Texture end)
		NewCollapseCat.List:AddItem(NewMatButton)
		table.insert(NewCollapseCat.Icons, NewMatButton)
	end
	return NewCollapseCat
end

function PANEL:AddScaleControls()
	local NewCollapseCat = CreateGenericCollapse(nil, "Scale Controls", intGlobalPadding, false)
	local NewXSlider = CreateGenericSlider(nil, "Wide", 0, 5, 2)
	NewXSlider.ValueChanged = function(self, value) GAMEMODE.ItemEditorSettings.CurrentEditingScale.x = value end
	NewCollapseCat.List:AddItem(NewXSlider)
	local NewYSlider = CreateGenericSlider(nil, "Long", 0, 5, 2)
	NewYSlider.ValueChanged = function(self, value) GAMEMODE.ItemEditorSettings.CurrentEditingScale.y = value end
	NewCollapseCat.List:AddItem(NewYSlider)
	local NewZSlider = CreateGenericSlider(nil, "Tall", 0, 5, 2)
	NewZSlider.ValueChanged = function(self, value) GAMEMODE.ItemEditorSettings.CurrentEditingScale.z = value end
	NewCollapseCat.List:AddItem(NewZSlider)
	NewCollapseCat.UpdateNewValues = function(vecNewScale)
		if vecNewScale then
			NewXSlider.UpdateSlider(vecNewScale.x)
			NewYSlider.UpdateSlider(vecNewScale.y)
			NewZSlider.UpdateSlider(vecNewScale.z)
		end
	end
	return NewCollapseCat
end

function PANEL:AddCameraControls()
	local NewCollapseCat = CreateGenericCollapse(nil, "Camera Controls", intGlobalPadding, false)
	local NewRotationSlider = CreateGenericSlider(nil, "Rotation", -180, 180, 3)
	NewRotationSlider.ValueChanged = function(self, value) GAMEMODE.ItemEditorSettings.CurrentCamRotation = value end
	NewCollapseCat.List:AddItem(NewRotationSlider)
	local NewDistanceSlider = CreateGenericSlider(nil, "Distance", -120, 50)
	NewDistanceSlider.ValueChanged = function(self, value) GAMEMODE.ItemEditorSettings.CurrentCamDistance = value end
	NewCollapseCat.List:AddItem(NewDistanceSlider)
	return NewCollapseCat
end

function PANEL:PrintNewDementions()
	local EVector = GAMEMODE.ItemEditorSettings.CurrentEditingVector
	local X, Y, Z = math.Round(EVector.x * 100) / 100, math.Round(EVector.y * 100) / 100, math.Round(EVector.z * 100) / 100
	local Vector_String = tostring(X .. ", " .. Y .. ", " .. Z)
	local EAngle = GAMEMODE.ItemEditorSettings.CurrentEditingAngle
	local Pitch, Yaw, Roll = math.Round(EAngle.p * 100) / 100, math.Round(EAngle.y * 100) / 100, math.Round(EAngle.r * 100) / 100
	local Angle_String = tostring(Pitch .. ", " .. Yaw .. ", " .. Roll)
	local Mat = GAMEMODE.ItemEditorSettings.CurrentEditingMat
	if Mat then Mat = '"' .. tostring(Mat) .. '"' end
	if !Mat then Mat = "nil" end
	local Scale = GAMEMODE.ItemEditorSettings.CurrentEditingScale
	local X, Y, Z = math.Round(Scale.x * 100) / 100, math.Round(Scale.y * 100) / 100, math.Round(Scale.z * 100) / 100
	local Scale_String = tostring(intX .. ", " .. intY .. ", " .. intZ)
	print("Vector(" .. Vector_String .. "), Angle(" .. Angle_String .. "), nil, " .. Mat .. ", Vector(" .. Scale_String .. ")")
	SetClipboardText("Vector(" .. Vector_String .. "), Angle(" .. Angle_String .. "), nil, " .. Mat .. ", Vector(" .. Scale_String .. ")")
end
vgui.Register("editor_items", PANEL, "Panel")

concommand.Add("ud_edit_items", function(ply, command, args)
	GAMEMODE.ItemEditor = GAMEMODE.ItemEditor or vgui.Create("editor_items")
	GAMEMODE.ItemEditor:SetSize(390, 450)
	GAMEMODE.ItemEditor:SetPos(50, 50)
end)

concommand.Add("ud_edit_items_giveitem", function(ply, command, args)
	local ItemTable = ItemTable(args[1])
	if ItemTable.Use then
		ItemTable:Use(ply, ItemTable)
	end
end)

concommand.Add("ud_edit_items_clearpaperdoll", function(ply, command, args)
	for Slot, Item in pairs(ply.Data.Paperdoll or {}) do
		local ItemTable = ItemTable(Item)
		if ItemTable.Use then ItemTable:Use(ply, ItemTable) end
	end
end)
