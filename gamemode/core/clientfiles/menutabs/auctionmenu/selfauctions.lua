local DefaultAuctionTime = 24 
local CleanUpTime = 168 
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
	for Key, Info in pairs(GAMEMODE.Auctions) do
		if Info.TimeLeft > CleanUpTime - DefaultAuctionTime then
			if Info.SellerID == LocalPlayer():SteamID() or game.SinglePlayer() then
				local Auction = vgui.Create("FListItem")
				Auction:SetHeaderSize(35)
				Auction:SetFont("MenuLarge")
				Auction:SetItemIcon(Info.Item, Info.Amount, 30)
				Auction:SetNameText(ItemTable(Info.Item).PrintName)
				Auction:SetDescText("$" .. Info.Price .. "   " .. math.Round(Info.TimeLeft - (CleanUpTime - DefaultAuctionTime)) .. " Hours Left")
				Auction:AddButton("icon16/check_off.png", "Cancel Auction", function()   RunConsoleCommand("UD_CancelAuction", Key)end)
				self.PlayerAuctionsList:AddItem(Auction)
			end
		end
	end
end
vgui.Register("selfauctions", PANEL, "Panel")
