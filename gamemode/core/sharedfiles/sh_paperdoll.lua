local Player = FindMetaTable("Player")

function Player:HasSet(strSet)
	if not IsValid(self) then return false end
	local tblSetTable = EquipmentSetTable(strSet)
	if not tblSetTable then return false end
	for _, strItem in pairs(tblSetTable.Items or {}) do
		if not table.HasValue(self.Data.Paperdoll or {}, strItem) then return false end
	end
	return true
end

function Player:SetPaperDoll(strSlot, strItem)
	if not self or not self:IsValid() and not self:Alive() then return false end
	local tblItemTable = ItemTable(strItem) or {}
	self.Data = self.Data or {}
	self.Data.Paperdoll = self.Data.Paperdoll or {}
	if not strItem or self:GetSlot(strSlot) == strItem then
		if tblItemTable.Set and self:HasSet(tblItemTable.Set) then
			local tblSetTable = EquipmentSetTable(tblItemTable.Set)
			self:ApplyBuffTable(tblSetTable.Buffs, -1)
		end
		self.Data.Paperdoll[strSlot] = nil
		self:ApplyBuffTable(tblItemTable.Buffs, -1)
	else
		if self:GetSlot(strSlot) then
			if ItemTable(self:GetSlot(strSlot)).Set and self:HasSet(ItemTable(self:GetSlot(strSlot)).Set) then
				local tblSetTable = EquipmentSetTable(ItemTable(self:GetSlot(strSlot)).Set)
				self:ApplyBuffTable(tblSetTable.Buffs, -1)
			end
			self:ApplyBuffTable(ItemTable(self:GetSlot(strSlot)).Buffs, -1)
		end
		self.Data.Paperdoll[strSlot] = strItem
		if tblItemTable.Set and self:HasSet(tblItemTable.Set) then
			local tblSetTable = EquipmentSetTable(tblItemTable.Set)
			self:ApplyBuffTable(tblSetTable.Buffs)
		end
		self:ApplyBuffTable(tblItemTable.Buffs)
	end
	if SERVER then
		for strChkSlot, strChkItem in pairs(self.Data.Paperdoll or {}) do
			local tblSlotTable = GAMEMODE.DataBase.Slots[strChkSlot]
			if strChkSlot ~= strSlot and tblSlotTable.ShouldClear and tblSlotTable:ShouldClear(self, tblItemTable) then
				self:UseItem(strChkItem)
			end
		end
		SendUsrMsg("UD_UpdatePaperDoll", player.GetAll(), {self, strSlot, self:GetSlot(strSlot)})
		self:SaveGame()
	end
end

function Player:GetSlot(strSlot)
	if self.Data and self.Data.Paperdoll and self.Data.Paperdoll[strSlot] then return self.Data.Paperdoll[strSlot] end
	return
end

if CLIENT then
	GM.PaperDollEnts = {}
	function UpdatePaperDollUsrMsg(usrMsg)
		local plyPlayer = usrMsg:ReadEntity()
		if not IsValid(plyPlayer) then return end
		local strSlot = usrMsg:ReadString()
		local strItem = usrMsg:ReadString()
		if strItem == "" then strItem = nil end
		plyPlayer:SetPaperDoll(strSlot, strItem)
		plyPlayer:PaperDollBuildSlot(strSlot, strItem)
		if plyPlayer == LocalPlayer() and GAMEMODE.MainMenu then
			GAMEMODE.MainMenu.InventoryTab:LoadInventory()
		end
	end
	usermessage.Hook("UD_UpdatePaperDoll", UpdatePaperDollUsrMsg)

	function Player:PaperDollBuildSlot(strSlot, strItem)
		if not self:Alive() then return end
		GAMEMODE.PaperDollEnts[self:EntIndex()] = GAMEMODE.PaperDollEnts[self:EntIndex()] or {}
		local tblPlayerTable = GAMEMODE.PaperDollEnts[self:EntIndex()]
		tblPlayerTable = tblPlayerTable or {}
		local entPaperDollEnt = tblPlayerTable[strSlot]
		if entPaperDollEnt and entPaperDollEnt:IsValid() then
			for _, kid in pairs(entPaperDollEnt.Children or {}) do SafeRemoveEntity(kid) end
			SafeRemoveEntity(entPaperDollEnt)
			GAMEMODE.PaperDollEnts[self:EntIndex()][strSlot] = nil
		end
		if strItem and strSlot then
			local tblItemTable = ItemTable(strItem)
			local tblSlotTable = SlotTable(strSlot)
			if tblItemTable and tblSlotTable then
				local entNewPart = GAMEMODE:BuildModel(tblItemTable.Model)
				if not entNewPart then error("help") end
				entNewPart:SetParent(self)
				entNewPart.Item = strItem
				entNewPart.Attachment = tblSlotTable.Attachment
				GAMEMODE.PaperDollEnts[self:EntIndex()][strSlot] = entNewPart
			end
		end
	end

	local function DrawPaperDoll()
		if LocalPlayer() and not LocalPlayer().Data then LocalPlayer().Data = {Paperdoll = {}} end

		for intEntID, tblPlayerTable in pairs(GAMEMODE.PaperDollEnts) do
			local plyPlayer = ents.GetByIndex(intEntID)

			for strSlot, entTarget in pairs(tblPlayerTable or {}) do
				if IsValid(plyPlayer) then
					for _, kid in pairs(entTarget.Children or {}) do SafeRemoveEntityDelayed(kid, 0) end
					SafeRemoveEntityDelayed(entTarget, 0)
					GAMEMODE.PaperDollEnts[intEntID] = nil

					break
				end

				local tblItemTable = ItemTable(entTarget.Item)
				if tblItemTable then
					local tblAttachment = plyPlayer:GetAttachment(plyPlayer:LookupAttachment(entTarget.Attachment))
					if not tblAttachment then
						local vecBonePostion, angBoneAngle = plyPlayer:GetBonePosition(plyPlayer:LookupBone(entTarget.Attachment))
						tblAttachment = {Pos = vecBonePostion, Ang = angBoneAngle}
					end
					if tblAttachment then
						entTarget:SetAngles(tblAttachment.Ang)
						entTarget:SetAngles(entTarget:LocalToWorldAngles(tblItemTable.Model[1].Angle))
						entTarget:SetPos(tblAttachment.Pos)
						entTarget:SetPos(entTarget:LocalToWorld(tblItemTable.Model[1].Position))
					end
					for k, kid in pairs(entTarget.Children or {}) do
						kid:SetAngles(entTarget:GetAngles())
						kid:SetAngles(kid:LocalToWorldAngles(tblItemTable.Model[k + 1].Angle))
						kid:SetPos(entTarget:GetPos())
						kid:SetPos(kid:LocalToWorld(tblItemTable.Model[k + 1].Position))
						kid:SetParent(entTarget)
					end
				end
			end
		end
	end
	hook.Add("RenderScreenspaceEffects", "UD_DrawPaperDoll", DrawPaperDoll)
end

function GM:BuildModel(tblModelTable)
	local tblLoopTable = tblModelTable
	if type(tblModelTable) == "string" then
		tblLoopTable = {}
		tblLoopTable[1] = {Model = tblModelTable, Position = Vector(0, 0, 0), Angle = Angle(0, 0, 0)}
	end
	local entReturnEnt = nil
	local entNewPart = nil
	for key, tblModelInfo in pairs(tblLoopTable) do
		if SERVER then
			entNewPart = ents.Create("prop_physics")
		elseif CLIENT then
			entNewPart = ents.CreateClientProp("prop_physics")
		end
		entNewPart:SetModel(tblModelInfo.Model)
		if entReturnEnt then entNewPart:SetAngles(entReturnEnt:GetAngles()) end
		if entReturnEnt then entNewPart:SetAngles(entNewPart:LocalToWorldAngles(tblModelInfo.Angle)) end
		if not entReturnEnt then entNewPart:SetAngles(tblModelInfo.Angle) end
		if entReturnEnt then entNewPart:SetPos(entReturnEnt:GetPos()) end
		if entReturnEnt then entNewPart:SetPos(entNewPart:LocalToWorld(tblModelInfo.Position)) end
		if not entReturnEnt then entNewPart:SetPos(tblModelInfo.Position) end
		entNewPart:SetParent(entReturnEnt)
		if SERVER then entNewPart:SetCollisionGroup(COLLISION_GROUP_WORLD) end
		if tblModelInfo.Material then entNewPart:SetMaterial(tblModelInfo.Material) end
		if tblModelInfo.Color then entNewPart:SetColor(Color(tblModelInfo.Color.r, tblModelInfo.Color.g, tblModelInfo.Color.b, tblModelInfo.Color.a)) end
		if tblModelInfo.Scale then
			local scale = type(tblModelInfo.Scale) == "Vector" and tblModelInfo.Scale or tonumber(tblModelInfo.Scale)
			if not scale then return ErrorNoHalt("scale is nil") end

			if CLIENT then
				local matrix = Matrix()
				matrix:Scale(scale)
				entNewPart:EnableMatrix("RenderMultiply", matrix)
				--entNewPart:SetModelScale(scale)
			else
				entNewPart:SetServerScale(scale)
			end
		end
		entNewPart:Spawn()
		if entReturnEnt then
			entReturnEnt.Children = entReturnEnt.Children or {}
			table.insert(entReturnEnt.Children, entNewPart)
		end
		if not entReturnEnt then entReturnEnt = entNewPart end
	end
	return entReturnEnt
end
