PANEL = {}
PANEL.inventorylist = nil
PANEL.Paperdoll = nil
PANEL.ItemIconPadding = 1
PANEL.ItemIconSize = 39
PANEL.ItemRow = 7

PANEL.AmmoDisplayTable = {}
PANEL.AmmoDisplayTable[1] = {Type = "smg1", PrintName = "Small"}
PANEL.AmmoDisplayTable[2] = {Type = "ar2", PrintName = "Rifle"}
PANEL.AmmoDisplayTable[3] = {Type = "buckshot", PrintName = "Buckshot"}
PANEL.AmmoDisplayTable[4] = {Type = "SniperRound", PrintName = "Sniper"}

function PANEL:Init()
	self.inventorylist = CreateGenericList(self, self.ItemIconPadding, true, true)
	self.inventorylist.DoDropedOn = function()
		if not LocalPlayer().Data.Paperdoll or not GAMEMODE.DraggingPanel or not GAMEMODE.DraggingPanel.IsPaperDollSlot then return end
		if GAMEMODE.DraggingPanel.Item and GAMEMODE.DraggingPanel.Slot then
			if LocalPlayer().Data.Paperdoll[GAMEMODE.DraggingPanel.Slot] == GAMEMODE.DraggingPanel.Item then
				GAMEMODE.DraggingPanel.DoDoubleClick()
			end
		end
	end
	GAMEMODE:AddHoverObject(self.inventorylist)
	GAMEMODE:AddHoverObject(self.inventorylist.pnlCanvas, self.inventorylist)

	self.WeightBar = CreateGenericWeightBar(self, LocalPlayer().Weight or 0, LocalPlayer():GetMaxWeight())
	self.LibraryButton = CreateGenericImageButton(self, "gui/book", "Library", function()
		GAMEMODE.ActiveMenu = nil
		GAMEMODE.ActiveMenu = DermaMenu()
		local ReadSubMenu = GAMEMODE.ActiveMenu:AddSubMenu("Read ...")
		ReadSubMenu.Panels = {}
		for Book, _ in pairs(LocalPlayer().Data.Library or {}) do
			local Item = ItemTable(Book)
			local Panel = ReadSubMenu:AddOption(Item.PrintName, function() RunConsoleCommand("UD_ReadBook", Book) end)
			ReadSubMenu.Panels[#ReadSubMenu.Panels] = Panel
			ReadSubMenu.Panels[#ReadSubMenu.Panels]:SetToolTip(Item.Desc)
		end
		local CraftSubMenu = GAMEMODE.ActiveMenu:AddSubMenu("Craft ...")
		CraftSubMenu.Panels = {}	
		for Recipe, _ in pairs(LocalPlayer().Recipes or {}) do
			local R = RecipeTable(Recipe)
			local Panel = CraftSubMenu:AddOption(R.PrintName, function()
				RunConsoleCommand("UD_CraftRecipe", Recipe)
			end)
			CraftSubMenu.Panels[#CraftSubMenu.Panels] = Panel
			local ToolTip = "Ingredients:"
			for Item, Amount in pairs(R.Ingredients) do
				ToolTip = ToolTip .. "\n" .. Amount .. " " .. ItemTable(Item).PrintName
			end
			ToolTip = ToolTip .. "\n\nProducts:"
			for Item, Amount in pairs(R.Products) do
				ToolTip = ToolTip .. "\n" .. Amount .. " " .. ItemTable(Item).PrintName
			end
			ToolTip = ToolTip .. "\n\nRequirements:"
			if R.NearFire then
				ToolTip = ToolTip .. "\nMust be done near fire"
			end
			for Master, Level in pairs(R.RequiredMasters) do
				ToolTip = ToolTip .. "\n" .. Level .. " " .. MasterTable(Master).PrintName
			end
			CraftSubMenu.Panels[#CraftSubMenu.Panels]:SetToolTip(ToolTip)
			if not LocalPlayer():CanMake(Recipe) then
				CraftSubMenu.Panels[#CraftSubMenu.Panels]:SetDisabled(true)
				CraftSubMenu.Panels[#CraftSubMenu.Panels]:SetAlpha(100)
			end
		end
		GAMEMODE.ActiveMenu:Open()
	end)

	self.Paperdoll = vgui.Create("FPaperDoll", self)
	self.Paperdoll.Paint = function()
		local PaintPanel = jdraw.NewPanel()
		PaintPanel:SetDimensions(0, 0, self.Paperdoll:GetWide(), self.Paperdoll:GetTall())
		PaintPanel:SetStyle(4, Gray)
		PaintPanel:SetBorder(1, DrakGray)
		jdraw.DrawPanel(PaintPanel)
	end

	self.StatsDisplay = CreateGenericList(self, 3, false, false)
	self.StatsDisplay:SetSpacing(0)

	self.AmmoDisplay = CreateGenericList(self, 3, false, false)
	self.AmmoDisplay:SetSpacing(0)

	self:LoadInventory()
end

function PANEL:PerformLayout()
	self.inventorylist:SetPos(0, 20)
	self.inventorylist:SetSize(((self.ItemIconSize + self.ItemIconPadding) * self.ItemRow) + self.ItemIconPadding, self:GetTall() - 20)

	self.WeightBar:SetPos(0, 0)
	self.WeightBar:SetSize(self.inventorylist:GetWide() - self.LibraryButton:GetWide() - 5, 15)
	self.WeightBar:Update(LocalPlayer().Weight or 0)
	self.LibraryButton:SetPos(self.WeightBar:GetWide() + 5, 0)

	self.Paperdoll:SetPos(self.inventorylist:GetWide() + 5, 0)
	self.Paperdoll:SetSize(self:GetWide() - (self.inventorylist:GetWide() + 5), self:GetTall() - 85)

	self.StatsDisplay:SetPos(self.inventorylist:GetWide() + 5, self.Paperdoll:GetTall() + 5)
	self.StatsDisplay:SetSize((self.Paperdoll:GetWide() * 0.60) - 5, self:GetTall() - self.Paperdoll:GetTall() - 5)

	self.AmmoDisplay:SetPos((self.inventorylist:GetWide() + 5) + self.StatsDisplay:GetWide() + 5, self.Paperdoll:GetTall() + 5)
	self.AmmoDisplay:SetSize((self.Paperdoll:GetWide() - self.StatsDisplay:GetWide()) - 5, self:GetTall() - self.Paperdoll:GetTall() - 5)
end

function PANEL:LoadInventory(Temp)
	local TempInv = Temp or false
	local WorkInv = LocalPlayer().Data.Inventory or {}
	self.inventorylist:Clear()
	if WorkInv["money"] and WorkInv["money"] > 0 then self:AddItem("money", WorkInv["money"]) end
	for item, amount in pairs(WorkInv) do
		if amount > 0 and item ~= "money" then
			self:AddItem(item, amount)
		end
	end

	for name, slotTable in pairs(GAMEMODE.DataBase.Slots) do
		if self.Paperdoll.Slots[slotTable.Name] then
			if LocalPlayer().Data.Paperdoll[slotTable.Name] then
				self.Paperdoll.Slots[slotTable.Name]:SetItem(GAMEMODE.DataBase.Items[LocalPlayer().Data.Paperdoll[slotTable.Name]])
			else
				self.Paperdoll.Slots[slotTable.Name]:SetSlot(slotTable)
			end
		end
	end

	self.StatsDisplay:Clear()
	local AddTable = table.Copy(GAMEMODE.DataBase.Stats)
	AddTable = table.ClearKeys(AddTable)
	table.sort(AddTable, function(statA, statB) return statA.Index < statB.Index end)
	for key, stat in pairs(AddTable) do
		if LocalPlayer().Stats and not stat.Hide then
			if not LocalPlayer().Stats[stat.Name] then
				print("stat '"..stat.Name.."' doesn't exist for "..tostring(LocalPlayer()))
				return
			end

			local NewStat = vgui.Create("DLabel")
			NewStat:SetFont("UiBold")
			NewStat:SetColor(DrakGray)
			NewStat:SetText(stat.PrintName .. " " .. LocalPlayer().Stats[stat.Name])
			NewStat:SizeToContents()
			self.StatsDisplay:AddItem(NewStat)
		end
	end

	self:ReloadAmmoDisplay()
	self:PerformLayout()
end

function PANEL:ReloadAmmoDisplay()
	self.AmmoDisplay:Clear()
	for _, Info in pairs(self.AmmoDisplayTable) do
		local NewAmmoType = vgui.Create("DLabel")
		NewAmmoType:SetFont("UiBold")
		NewAmmoType:SetColor(DrakGray)
		NewAmmoType:SetText(Info.PrintName .. " " .. LocalPlayer():GetAmmoCount(Info.Type))
		NewAmmoType:SizeToContents()
		self.AmmoDisplay:AddItem(NewAmmoType)
	end
end

function PANEL:AddItem(item, amount)
	local AddList = self.inventorylist
	local ItemTable = GAMEMODE.DataBase.Items[item]
	local ListItems = 1
	if not ItemTable.Stackable then ListItems = amount or 1 end
	if table.HasValue(LocalPlayer().Data.Paperdoll or {}, item) then ListItems = ListItems - 1 end
	for i = 1, ListItems do
		local icnItem = vgui.Create("FIconItem")
		icnItem:SetSize(self.ItemIconSize, self.ItemIconSize)
		icnItem:SetItem(ItemTable, amount)
		icnItem.FromInventory = true
		AddList:AddItem(icnItem)
	end
end

vgui.Register("inventorytab", PANEL, "Panel")
