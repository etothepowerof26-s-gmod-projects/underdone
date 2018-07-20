local PANEL = {}

AccessorFunc(PANEL, "ItemIconSize", "IconSize")
PANEL.ItemIconSize = 39

function PANEL:Init()
	self.Slots = {}

	for _, slotTable in pairs(GAMEMODE.DataBase.Slots) do
		local Item = vgui.Create("FIconItem", self)
		Item:SetSize(self.ItemIconSize, self.ItemIconSize)
		Item:SetSlot(slotTable)
		Item.FromInventory = true

		self.Slots[slotTable.Name] = Item
	end

	self.ArmorRatingLabel = CreateGenericLabel(self, "UiBold", "Total Armor " .. LocalPlayer():GetArmorRating(), DrakGray)
end

function PANEL:PerformLayout(w, h)
	for name, Item in pairs(self.Slots) do
		local SlotTable = GAMEMODE.DataBase.Slots[name]
		local X = (w * (SlotTable.Position.x / 100)) - (self.ItemIconSize / 2)
		local Y = (h * (SlotTable.Position.y / 100)) - (self.ItemIconSize / 2)
		Item:SetPos(X, Y)
	end

	if IsValid(self.ArmorRatingLabel) then
		self.ArmorRatingLabel:SetPos(3, self:GetTall() - 15)
		self.ArmorRatingLabel:SetSize(self:GetWide() - 10, 15)
	end
end

function PANEL:Think()
	if IsValid(self.ArmorRatingLabel) then
		self.ArmorRatingLabel:SetText("Total Armor " .. LocalPlayer():GetArmorRating())
	end
end

vgui.Register("FPaperDoll", PANEL, "Panel")
