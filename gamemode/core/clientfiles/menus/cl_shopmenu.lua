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
	self.Frame.InternalClose = self.Frame.Close
	self.Frame.Close = function()
		GAMEMODE.ShopMenu.Frame:InternalClose()
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
	GAMEMODE:AddHoverObject(self.ShopInventoryPanel.Canvas, self.ShopInventoryPanel)

	self.WeightBar = CreateGenericWeightBar(self.Frame, LocalPlayer().Weight or 0, LocalPlayer():GetMaxWeight())
	self.PlayerInventoryPanel = CreateGenericList(self.Frame, self.ItemIconPadding, true, true)
	self.PlayerInventoryPanel.DoDropedOn = function()
		if GAMEMODE.DraggingPanel.UseCommand == "buy" then
			GAMEMODE.DraggingPanel.DoDoubleClick()
		end
	end
	GAMEMODE:AddHoverObject(self.PlayerInventoryPanel)
	GAMEMODE:AddHoverObject(self.PlayerInventoryPanel.Canvas, self.PlayerInventoryPanel)

	self:PerformLayout()
end

function PANEL:LoadShop(Shop)
	self.Shop = self.Shop or Shop
	local ShopTable = ShopTable(self.Shop)
	if ShopTable then
		self.Frame:SetTitle(ShopTable.PrintName)
		self.ShopInventoryPanel:Clear()
		for Item, Info in pairs(ShopTable.Inventory or {}) do
			self:AddItem(self.ShopInventoryPanel, Item, 1, "buy", Info.Price or LocalPlayer():GetItemBuyPrice(Item))
		end
	else
		ErrorNoHalt("missing shop for '" .. tostring(Shop) .. "'")
	end
end

function PANEL:LoadPlayer()
	self.WeightBar:Update(LocalPlayer().Weight or 0)
	local Inventory = LocalPlayer().Data.Inventory or {}
	self.PlayerInventoryPanel:Clear()
	if Inventory["money"] and Inventory["money"] > 0 then
		self:AddItem(self.PlayerInventoryPanel, "money", Inventory["money"], "sell")
	end
	for Item, Amount in pairs(Inventory) do
		if Amount > 0 and Item ~= "money" then
			local ItemTable = ItemTable(Item)
			self:AddItem(self.PlayerInventoryPanel, Item, Amount, "sell", ItemTable.SellPrice)
		end
	end
end

function PANEL:AddItem(AddList, item, amount, Command, Cost)
	local ItemTable = ItemTable(item)
	if ItemTable then
		local ListItems = 1
		if not ItemTable.Stackable then ListItems = amount or 1 end
		if Command == "sell" and table.HasValue(LocalPlayer().Data.Paperdoll or {}, item) then ListItems = ListItems - 1 end
		if ItemTable.QuestNeeded and not LocalPlayer():HasCompletedQuest(ItemTable.QuestNeeded) then return end
		for i = 1, ListItems do
			local Item = vgui.Create("FIconItem")
			Item:SetSize(self.ItemIconSize, self.ItemIconSize)
			Item:SetItem(ItemTable, amount, Command or "use", Cost or 0)
			if Command == "buy" and not LocalPlayer():HasItem("money", Cost) then
				Item:SetAlpha(100)
			end
			AddList:AddItem(Item)
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
	local NPCTable = NPCTable(npc:GetNWString("npc"))
	if not IsValid(npc) or not NPCTable or not NPCTable.Shop then return end
	GAMEMODE.ShopMenu = GAMEMODE.ShopMenu or vgui.Create("shopmenu")
	GAMEMODE.ShopMenu:SetSize(505, 300)
	GAMEMODE.ShopMenu:Center()
	GAMEMODE.ShopMenu:LoadShop(args[1])
	GAMEMODE.ShopMenu:LoadPlayer()
end)
