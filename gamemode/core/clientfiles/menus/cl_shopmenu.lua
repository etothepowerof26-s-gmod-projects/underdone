GM.ShopMenu = nil
PANEL = {}
PANEL.Frame = nil
PANEL.ShopInventoryPanel = nil
PANEL.WeightBar = nil
PANEL.PlayerInventoryPanel = nil
PANEL.ItemIconPadding = 1
PANEL.ItemIconSize = 39
PANEL.ItemRow = 6
PANEL.Shop = nil

function PANEL:Init()
	self.Frame = CreateGenericFrame("Shop Menu", false, true)
	self.Frame.btnClose.DoClick = function(btn)
		GAMEMODE.ShopMenu.Frame:Close()
		GAMEMODE.ShopMenu = nil
	end
	self.Frame:MakePopup()

	self.ShopInventoryPanel = CreateGenericList(self.Frame, self.ItemIconPadding, true, true)
	self.ShopInventoryPanel.DoDropedOn = function()
		if GAMEMODE.DraggingPanel.UseCommand == "sell" then
			GAMEMODE.DraggingPanel.DoDoubleClick()
		end
	end
	GAMEMODE:AddHoverObject(self.ShopInventoryPanel)
	GAMEMODE:AddHoverObject(self.ShopInventoryPanel.pnlCanvas, self.ShopInventoryPanel)

	self.WeightBar = CreateGenericWeightBar(self.Frame, LocalPlayer().Weight or 0, LocalPlayer():GetMaxWeight())
	self.PlayerInventoryPanel = CreateGenericList(self.Frame, self.ItemIconPadding, true, true)
	self.PlayerInventoryPanel.DoDropedOn = function()
		if GAMEMODE.DraggingPanel.UseCommand == "buy" then
			GAMEMODE.DraggingPanel.DoDoubleClick()
		end
	end
	GAMEMODE:AddHoverObject(self.PlayerInventoryPanel)
	GAMEMODE:AddHoverObject(self.PlayerInventoryPanel.pnlCanvas, self.PlayerInventoryPanel)

	self:PerformLayout()
end

function PANEL:LoadShop(strShop)
	self.Shop = self.Shop or strShop
	local tblShopTable = ShopTable(self.Shop)
	if tblShopTable then
		self.Frame:SetTitle(tblShopTable.PrintName)
		self.ShopInventoryPanel:Clear()
		for strItem, tblInfo in pairs(tblShopTable.Inventory or {}) do
			self:AddItem(self.ShopInventoryPanel, strItem, 1, "buy", tblInfo.Price or LocalPlayer():GetItemBuyPrice(strItem))
		end
	else
		ErrorNoHalt("missing shop for '" .. tostring(strShop) .. "'")
	end
end

function PANEL:LoadPlayer()
	self.WeightBar:Update(LocalPlayer().Weight or 0)
	local tblInventory = LocalPlayer().Data.Inventory or {}
	self.PlayerInventoryPanel:Clear()
	if tblInventory["money"] and tblInventory["money"] > 0 then
		self:AddItem(self.PlayerInventoryPanel, "money", tblInventory["money"], "sell")
	end
	for strItem, intAmount in pairs(tblInventory) do
		if intAmount > 0 and strItem ~= "money" then
			local tblItemTable = ItemTable(strItem)
			self:AddItem(self.PlayerInventoryPanel, strItem, intAmount, "sell", tblItemTable.SellPrice)
		end
	end
end

function PANEL:AddItem(lstAddList, item, amount, strCommand, intCost)
	local tblItemTable = ItemTable(item)
	if tblItemTable then
		local intListItems = 1
		if not tblItemTable.Stackable then intListItems = amount or 1 end
		if strCommand == "sell" and table.HasValue(LocalPlayer().Data.Paperdoll or {}, item) then intListItems = intListItems - 1 end
		if tblItemTable.QuestNeeded and not LocalPlayer():HasCompletedQuest(tblItemTable.QuestNeeded) then return end
		for i = 1, intListItems do
			local icnItem = vgui.Create("FIconItem")
			icnItem:SetSize(self.ItemIconSize, self.ItemIconSize)
			icnItem:SetItem(tblItemTable, amount, strCommand or "use", intCost or 0)
			if strCommand == "buy" and not LocalPlayer():HasItem("money", intCost) then
				icnItem:SetAlpha(100)
			end
			lstAddList:AddItem(icnItem)
		end
	else
		ErrorNoHalt("missing item for '" .. tostring(self.Shop) .. "', '" .. tostring(item) .. "'")
	end
end

function PANEL:PerformLayout()
	self.ShopInventoryPanel:SetPos(5, 25)
	self.ShopInventoryPanel:SetSize(((self.ItemIconSize + self.ItemIconPadding) * self.ItemRow) + self.ItemIconPadding, self.Frame:GetTall() - 30)

	self.PlayerInventoryPanel:SetPos(self.ShopInventoryPanel:GetWide() + 10, 45)
	self.PlayerInventoryPanel:SetSize(((self.ItemIconSize + self.ItemIconPadding) * self.ItemRow) + self.ItemIconPadding, self.Frame:GetTall() - 50)

	self.WeightBar:SetPos(self.ShopInventoryPanel:GetWide() + 10, 25)
	self.WeightBar:SetSize(self.PlayerInventoryPanel:GetWide(), 15)
	self.WeightBar:Update(LocalPlayer().Weight or 0)

	self:SetSize(self.ShopInventoryPanel:GetWide() + self.PlayerInventoryPanel:GetWide() + 15, 300)
	self.Frame:SetPos(self:GetPos())
	self.Frame:SetSize(self:GetSize())
end
vgui.Register("shopmenu", PANEL, "Panel")

concommand.Add("UD_OpenShopMenu", function(ply, command, args)
	local npc = ply:GetEyeTrace().Entity
	local tblNPCTable = NPCTable(npc:GetNWString("npc"))
	if not IsValid(npc) or not tblNPCTable or not tblNPCTable.Shop then return end
	GAMEMODE.ShopMenu = GAMEMODE.ShopMenu or vgui.Create("shopmenu")
	GAMEMODE.ShopMenu:SetSize(505, 300)
	GAMEMODE.ShopMenu:Center()
	GAMEMODE.ShopMenu:LoadShop(args[1])
	GAMEMODE.ShopMenu:LoadPlayer()
end)
