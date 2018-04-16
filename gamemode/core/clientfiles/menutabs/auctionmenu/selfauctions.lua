local intDefaultAuctionTime = 24 --1 Day
local intCleanUpTime = 168 --1 Week
PANEL = {}
function PANEL:Init()

	self.PlayerAuctionsList = CreateGenericList(self, 3, false, true)

	self:LoadPlayerAuctions()
end

function PANEL:PerformLayout()
	self.PlayerAuctionsList:SetSize(self:GetWide(), self:GetTall())
end

function PANEL:LoadPlayerAuctions()
	self.PlayerAuctionsList:Clear()
	for intKey, tblInfo in pairs(GAMEMODE.Auctions) do
		if tblInfo.TimeLeft > intCleanUpTime - intDefaultAuctionTime then
			if tblInfo.SellerID == LocalPlayer():SteamID() or game.SinglePlayer() then
				local ltmAuction = vgui.Create("FListItem")
				ltmAuction:SetHeaderSize(35)
				ltmAuction:SetFont("MenuLarge")
				ltmAuction:SetItemIcon(tblInfo.Item, tblInfo.Amount, 30)
				ltmAuction:SetNameText(ItemTable(tblInfo.Item).PrintName)
				ltmAuction:SetDescText("$" .. tblInfo.Price .. "   " .. math.Round(tblInfo.TimeLeft - (intCleanUpTime - intDefaultAuctionTime)) .. " Hours Left")
				ltmAuction:AddButton("icon16/check_off.png", "Cancel Auction", function()   RunConsoleCommand("UD_CancelAuction", intKey)end)
				self.PlayerAuctionsList:AddItem(ltmAuction)
			end
		end
	end
end
vgui.Register("selfauctions", PANEL, "Panel")
