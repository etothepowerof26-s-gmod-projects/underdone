local intDefaultAuctionTime = 24 --1 Day
local intCleanUpTime = 168 --1 Week
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
	for intKey, tblInfo in pairs(GAMEMODE.Auctions) do
		if tblInfo then
			if tblInfo.TimeLeft <= intCleanUpTime - intDefaultAuctionTime then
				if tblInfo.SellerID == LocalPlayer():SteamID() or game.SinglePlayer() then
					local ltmAuction = vgui.Create("FListItem")
					ltmAuction:SetHeaderSize(35)
					ltmAuction:SetFont("MenuLarge")
					ltmAuction:SetItemIcon(tblInfo.Item, tblInfo.Amount, 30)
					ltmAuction:SetNameText(ItemTable(tblInfo.Item).PrintName)
					ltmAuction:SetDescText(tblInfo.TimeLeft .. " Hours Left")
						ltmAuction:AddButton("gui/arrow_up", "Pick up Auction", function() RunConsoleCommand("UD_PickUpAuction", intKey) end)
					self.AuctionsList:AddItem(ltmAuction)
				end
			end
		end
	end
end
vgui.Register("pickupauctionstab", PANEL, "Panel")