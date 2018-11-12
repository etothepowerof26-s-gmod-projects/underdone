local DefaultAuctionTime = 24 --1 Day
local CleanUpTime = 168 --1 Week
PANEL = {}
function PANEL:Init()
	self.AuctionsList = CreateGenericList(self, 3, false, true)

	self.CreateAuction = CreateGenericPanel(self)
	self.ItemSellector = CreateGenericMultiChoice(self.CreateAuction)
	for Item, Amount in pairs(LocalPlayer().Data.Inventory or {}) do
		if (ItemTable(Item).SellPrice or 0) > 0 then
			self.ItemSellector.NewChoices = self.ItemSellector.NewChoices or {}
			self.ItemSellector.NewChoices[self.ItemSellector:AddChoice(ItemTable(Item).PrintName)] = Item
		end
	end
	local Item = ""
	self.ItemSellector.OnSelect = function(index, value, data)
		Item = self.ItemSellector.NewChoices[value]
		self.AmountEntry:SetValue(1)
		self.AmountEntry:SetMax(LocalPlayer().Data.Inventory[Item])
	end
	self.AmountEntry = vgui.Create("DNumberWang", self.CreateAuction)
	self.AmountEntry:SetDecimals(0)
	self.AmountEntry:SetMin(1)
	self.AmountEntry:SetMax(1)
	self.AmountEntry:SetValue(1)
	self.PriceEntry = vgui.Create("DTextEntry", self.CreateAuction)
	self.PriceEntry:SetText("Price")
	self.CreateAuctionButton = CreateGenericImageButton(self.CreateAuction, "gui/accept", "Create Auction", function()
		RunConsoleCommand("UD_CreateAuction", Item, tonumber(self.AmountEntry:GetValue()), tonumber(self.PriceEntry:GetValue()))
		timer.Simple(0.5, function()
			self.AmountEntry:SetValue(1)
			self.AmountEntry:SetMax(LocalPlayer().Data.Inventory[Item])
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
	local Counter = 0
	for Key, Info in pairs(GAMEMODE.Auctions) do
		if Info.TimeLeft > CleanUpTime - DefaultAuctionTime then
			if Counter >= (LocalPlayer():GetNWInt("AuctionPage") * GAMEMODE.AuctionsPerPage) and Counter < ((LocalPlayer():GetNWInt("AuctionPage") + 1) * GAMEMODE.AuctionsPerPage) then
				local Auction = vgui.Create("FListItem")
				Auction:SetHeaderSize(35)
				Auction:SetFont("MenuLarge")
				Auction:SetItemIcon(Info.Item, Info.Amount, 30)
				Auction:SetNameText(ItemTable(Info.Item).PrintName)
				Auction:SetDescText("$" .. Info.Price .. "   " .. math.Round(Info.TimeLeft - (CleanUpTime - DefaultAuctionTime)) .. " Hours Left")
				if Info.SellerID == LocalPlayer():SteamID() or game.SinglePlayer() then
					Auction:AddButton("icon16/check_off.png", "Cancel Auction", function() RunConsoleCommand("UD_CancelAuction", Key) end)
				end
				if Info.SellerID ~= LocalPlayer():SteamID() or game.SinglePlayer() then
					Auction:AddButton("gui/money", "Buy out Auction", function() RunConsoleCommand("UD_BuyOutAuction", Key) end)
				end
				self.AuctionsList:AddItem(Auction)
			end
			Counter = Counter + 1
		end
	end
end
vgui.Register("buyauctionstab", PANEL, "Panel")
