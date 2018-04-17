local intDefaultAuctionTime = 24 --1 Day
local intCleanUpTime = 168 --1 Week
PANEL = {}
function PANEL:Init()
	self.AuctionsList = CreateGenericList(self, 3, false, true)

	self.CreateAuction = CreateGenericPanel(self)
	self.ItemSellector = CreateGenericMultiChoice(self.CreateAuction)
	for strItem, intAmount in pairs(LocalPlayer().Data.Inventory or {}) do
		if (ItemTable(strItem).SellPrice or 0) > 0 then
			self.ItemSellector.NewChoices = self.ItemSellector.NewChoices or {}
			self.ItemSellector.NewChoices[self.ItemSellector:AddChoice(ItemTable(strItem).PrintName)] = strItem
		end
	end
	local strItem = ""
	self.ItemSellector.OnSelect = function(index, value, data)
		strItem = self.ItemSellector.NewChoices[value]
		self.AmountEntry:SetValue(1)
		self.AmountEntry:SetMax(LocalPlayer().Data.Inventory[strItem])
	end
	self.AmountEntry = vgui.Create("DNumberWang", self.CreateAuction)
	self.AmountEntry:SetDecimals(0)
	self.AmountEntry:SetMin(1)
	self.AmountEntry:SetMax(1)
	self.AmountEntry:SetValue(1)
	self.PriceEntry = vgui.Create("DTextEntry", self.CreateAuction)
	self.PriceEntry:SetText("Price")
	self.CreateAuctionButton = CreateGenericImageButton(self.CreateAuction, "gui/accept", "Create Auction", function()
		RunConsoleCommand("UD_CreateAuction", strItem, tonumber(self.AmountEntry:GetValue()), tonumber(self.PriceEntry:GetValue()))
		timer.Simple(0.5, function()
			self.AmountEntry:SetValue(1)
			self.AmountEntry:SetMax(LocalPlayer().Data.Inventory[strItem])
		end)
	end)

	self.PagesPanel = CreateGenericPanel(self)
	self.PageRight = vgui.Create("DButton", self.PagesPanel)
	self.PageLeft = vgui.Create("DButton", self.PagesPanel)
	self.PageLeft:SetFont("Marlett")
	self.PageLeft:SetText("3")
	self.PageLeft.DoClick = function()
		self.PageLabel:SetText("Page " .. math.Clamp((LocalPlayer():GetNWInt("AuctionPage") + 1) - 1, 1, 100))
		RunConsoleCommand("UD_SetAuctionPage", math.Clamp(LocalPlayer():GetNWInt("AuctionPage") - 1, 0, 100))
	end
	self.PageRight:SetFont("Marlett")
	self.PageRight:SetText("4")
	self.PageRight.DoClick = function()
		self.PageLabel:SetText("Page " .. math.Clamp((LocalPlayer():GetNWInt("AuctionPage") + 1) + 1, 1, 100))
		RunConsoleCommand("UD_SetAuctionPage", math.Clamp(LocalPlayer():GetNWInt("AuctionPage") + 1, 0, 100))
	end
	self.PageLabel = CreateGenericLabel(self.PagesPanel, "UiBold", "Page " .. (LocalPlayer():GetNWInt("AuctionPage") + 1), clrDrakGray)

	self:LoadAuctions()
end

function PANEL:PerformLayout()
	self.AuctionsList:SetSize(self:GetWide(), self:GetTall() - 35)

	self.CreateAuction:SetSize(self:GetWide() - 150, 30)
	self.CreateAuction:SetPos(0, self.AuctionsList:GetTall() + 5)
	self.ItemSellector:SetSize(150, 20)
	self.ItemSellector:SetPos(5, 5)
	self.AmountEntry:SetSize(50, 20)
	self.AmountEntry:SetPos(5 + self.ItemSellector:GetWide() + 5, 5)
	self.PriceEntry:SetSize(50, 20)
	self.PriceEntry:SetPos(5 + self.ItemSellector:GetWide() + 5 + self.AmountEntry:GetWide() + 5, 5)
	self.CreateAuctionButton:SetSize(16, 16)
	self.CreateAuctionButton:SetPos(self.CreateAuction:GetWide() - 16 - 5, (self.CreateAuction:GetTall() / 2) - (self.CreateAuctionButton:GetTall() / 2))

	self.PagesPanel:SetSize(self.AuctionsList:GetWide() - self.CreateAuction:GetWide() - 5, 30)
	self.PagesPanel:SetPos(self.CreateAuction:GetWide() + 5, self.AuctionsList:GetTall() + 5)
	self.PageLeft:SetSize(20, 20)
	self.PageLeft:SetPos(5, 5)
	self.PageRight:SetSize(20, 20)
	self.PageRight:SetPos(self.PagesPanel:GetWide() - self.PageLeft:GetWide() - 5, 5)
	self.PageLabel:SizeToContents()
	self.PageLabel:SetPos((self.PagesPanel:GetWide() / 2) - 23, 8)
end

function PANEL:LoadAuctions()
	self.AuctionsList:Clear()
	local intCounter = 0
	for intKey, tblInfo in pairs(GAMEMODE.Auctions) do
		if tblInfo.TimeLeft > intCleanUpTime - intDefaultAuctionTime then
			if intCounter >= (LocalPlayer():GetNWInt("AuctionPage") * GAMEMODE.AuctionsPerPage) and intCounter < ((LocalPlayer():GetNWInt("AuctionPage") + 1) * GAMEMODE.AuctionsPerPage) then
				local ltmAuction = vgui.Create("FListItem")
				ltmAuction:SetHeaderSize(35)
				ltmAuction:SetFont("MenuLarge")
				ltmAuction:SetItemIcon(tblInfo.Item, tblInfo.Amount, 30)
				ltmAuction:SetNameText(ItemTable(tblInfo.Item).PrintName)
				ltmAuction:SetDescText("$" .. tblInfo.Price .. "   " .. math.Round(tblInfo.TimeLeft - (intCleanUpTime - intDefaultAuctionTime)) .. " Hours Left")
				if tblInfo.SellerID == LocalPlayer():SteamID() or game.SinglePlayer() then
					ltmAuction:AddButton("icon16/check_off.png", "Cancel Auction", function() RunConsoleCommand("UD_CancelAuction", intKey) end)
				end
				if tblInfo.SellerID ~= LocalPlayer():SteamID() or game.SinglePlayer() then
					ltmAuction:AddButton("gui/money", "Buy out Auction", function() RunConsoleCommand("UD_BuyOutAuction", intKey) end)
				end
				self.AuctionsList:AddItem(ltmAuction)
			end
			intCounter = intCounter + 1
		end
	end
end
vgui.Register("buyauctionstab", PANEL, "Panel")
