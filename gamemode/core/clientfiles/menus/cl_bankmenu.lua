GM.BankMenu = nil
PANEL = {}
PANEL.BankInventoryPanel = nil
PANEL.PlayerInventoryPanel = nil
PANEL.ItemIconPadding = 1
PANEL.ItemIconSize = 39
PANEL.ItemRow = 7

function PANEL:Init()
	self.Frame = CreateGenericFrame("Bank Menu", false, true)
	self.Frame.CloseButton.DoClick = function()
		GAMEMODE.BankMenu.Frame:Close()
		GAMEMODE.BankMenu = nil
	end
	self.Frame:MakePopup()
	
	self.BankWeightBar = CreateGenericWeightBar(self.Frame, LocalPlayer():GetBankSize(), LocalPlayer():GetBankTotalSize())
	self.BankInventoryPanel = CreateGenericList(self.Frame, self.ItemIconPadding, true, true)
	self.BankInventoryPanel.DoDropedOn = function()
		if GAMEMODE.DraggingPanel.UseCommand == "deposit" then
			GAMEMODE.DraggingPanel.DoDoubleClick()
		end
	end
	GAMEMODE:AddHoverObject(self.BankInventoryPanel)
	GAMEMODE:AddHoverObject(self.BankInventoryPanel.pnlCanvas, self.BankInventoryPanel)
	
	self.WeightBar = CreateGenericWeightBar(self.Frame, (LocalPlayer().Weight or 0), LocalPlayer():GetMaxWeight())
	self.PlayerInventoryPanel = CreateGenericList(self.Frame, self.ItemIconPadding, true, true)
	self.PlayerInventoryPanel.DoDropedOn = function()
		if GAMEMODE.DraggingPanel.UseCommand == "withdraw" then
			GAMEMODE.DraggingPanel.DoDoubleClick()
		end
	end
	GAMEMODE:AddHoverObject(self.PlayerInventoryPanel)
	GAMEMODE:AddHoverObject(self.PlayerInventoryPanel.pnlCanvas, self.PlayerInventoryPanel)
	
	self:PerformLayout()
end

function PANEL:LoadBank()
	self.BankWeightBar:Update(LocalPlayer():GetBankSize())
	local Bank = LocalPlayer().Data.Bank or {}
	self.BankInventoryPanel:Clear()
	if Bank["money"] and Bank["money"] > 0 then
		self:AddItem(self.BankInventoryPanel, "money", Bank["money"], "withdraw")
	end
	for Item, Amount in pairs(Bank or {}) do
		if Amount > 0 and Item ~= "money" then
			local ItemTable = ItemTable(Item)
			self:AddItem(self.BankInventoryPanel, Item, Amount, "withdraw")
		end
	end
end

function PANEL:LoadPlayer()
	self.WeightBar:Update(LocalPlayer().Weight or 0)
	local Inventory = LocalPlayer().Data.Inventory or {}
	self.PlayerInventoryPanel:Clear()
	if Inventory["money"] and Inventory["money"] > 0 then
		self:AddItem(self.PlayerInventoryPanel, "money", Inventory["money"], "deposit")
	end
	for Item, Amount in pairs(Inventory or {}) do
		if Amount > 0 and Item ~= "money" then
			local ItemTable = ItemTable(Item)
			self:AddItem(self.PlayerInventoryPanel, Item, Amount, "deposit")
		end
	end
end

function PANEL:AddItem(AddList, item, amount, Command)
	local ItemTable = ItemTable(item)
	local ListItems = 1
	if not ItemTable.Stackable then ListItems = amount or 1 end
	for i = 1, ListItems do
		local Item = vgui.Create("FIconItem")
		Item:SetSize(self.ItemIconSize, self.ItemIconSize)
		Item:SetItem(ItemTable, amount, Command or "use")
		AddList:AddItem(Item)
	end
end

function PANEL:PerformLayout()
	self.BankInventoryPanel:SetPos(5, 45)
	self.BankInventoryPanel:SetSize(((self.ItemIconSize + self.ItemIconPadding) * self.ItemRow) + self.ItemIconPadding, self.Frame:GetTall() - 50)
	
	self.BankWeightBar:SetPos(5, 25)
	self.BankWeightBar:SetSize(self.BankInventoryPanel:GetWide(), 15)
	self.BankWeightBar:Update(LocalPlayer():GetBankSize())
	
	self.PlayerInventoryPanel:SetPos(self.BankInventoryPanel:GetWide() + 10, 45)
	self.PlayerInventoryPanel:SetSize(((self.ItemIconSize + self.ItemIconPadding) * self.ItemRow) + self.ItemIconPadding, self.Frame:GetTall() - 50)
	
	self.WeightBar:SetPos(self.BankInventoryPanel:GetWide() + 10, 25)
	self.WeightBar:SetSize(self.PlayerInventoryPanel:GetWide(), 15)
	self.WeightBar:Update(LocalPlayer().Weight or 0)
	
	self:SetSize(self.BankInventoryPanel:GetWide() + self.PlayerInventoryPanel:GetWide() + 15, 300)
	self.Frame:SetPos(self:GetPos())
	self.Frame:SetSize(self:GetSize())
end
vgui.Register("bankmenu", PANEL, "Panel")

concommand.Add("UD_OpenBankMenu", function(ply, command, args)
	local npc = ply:GetEyeTrace().Entity
	local NPCTable = NPCTable(npc:GetNWString("npc"))
	if not IsValid(npc) or not NPCTable or not NPCTable.Bank then return end
	GAMEMODE.BankMenu = GAMEMODE.BankMenu or vgui.Create("bankmenu")
	GAMEMODE.BankMenu:SetSize(505, 340)
	GAMEMODE.BankMenu:Center()
	GAMEMODE.BankMenu:LoadBank()
	GAMEMODE.BankMenu:LoadPlayer()
end)