local DefaultAuctionTime = 24 --1 Day
local CleanUpTime = 168 --1 Week
PANEL = {}
function PANEL:Init()

	self.AuctionsList = CreateGenericList(self, 3, false, true)
	self:LoadAuctions()
end

function PANEL:PerformLayout()
	self.AuctionsList:SetSize(self:GetWide(), self:GetTall())
end

function PANEL:LoadAuctions()
	self.AuctionsList:Clear()
	for Key, Info in pairs(GAMEMODE.Auctions) do
		if Info then
			if Info.TimeLeft <= CleanUpTime - DefaultAuctionTime then
				if Info.SellerID == LocalPlayer():SteamID() or game.SinglePlayer() then
					local Auction = vgui.Create("FListItem")
					Auction:SetHeaderSize(35)
					Auction:SetFont("MenuLarge")
					Auction:SetItemIcon(Info.Item, Info.Amount, 30)
					Auction:SetNameText(ItemTable(Info.Item).PrintName)
					Auction:SetDescText(Info.TimeLeft .. " Hours Left")
						Auction:AddButton("gui/arrow_up", "Pick up Auction", function() RunConsoleCommand("UD_PickUpAuction", Key) end)
					self.AuctionsList:AddItem(Auction)
				end
			end
		end
	end
end
vgui.Register("pickupauctionstab", PANEL, "Panel")