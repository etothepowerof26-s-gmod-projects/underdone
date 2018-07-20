GM.AuctionMenu = nil
PANEL = {}

function PANEL:Init()
	self.Frame = CreateGenericFrame("", false, false)
	self.Frame.Paint = function() end

	self.TabSheet = CreateGenericTabPanel(self.Frame)
	self.BuyAuctions = self.TabSheet:NewTab("Buy and Sell", "buyauctionstab", "gui/money", "Buy out auctions and create auctions here.")
	self.PlayerAuctions = self.TabSheet:NewTab("Your Auctions", "selfauctions", "gui/arrow_up", "See your own auctions")
	self.PickUpAuction = self.TabSheet:NewTab("Pick up Auctions", "pickupauctionstab", "gui/arrow_up", "Pick up auctions here.")

	self.Frame.Close = vgui.Create("DButton", self.Frame)
	self.Frame.Close:SetFont("Marlett")
	self.Frame.Close:SetText("r")
	self.Frame.Close.DoClick = function(pnlPanel)
		GAMEMODE.AuctionMenu.Frame:Close()
		GAMEMODE.AuctionMenu = nil
	end

	self.Frame.Close.Paint = function()
		jdraw.QuickDrawPanel(clrGray, 0, 0, self.Frame.Close:GetWide() - 1, self.Frame.Close:GetTall() - 1)
	end
	self.Frame:MakePopup()
	self:PerformLayout()
end

function PANEL:PerformLayout()
	self.Frame:SetPos(self:GetPos())
	self.Frame:SetSize(self:GetSize())
	self.Frame.Close:SetPos(self.Frame:GetWide() - 5, 10)

	self.TabSheet:SetPos(5, 5)
	self.TabSheet:SetSize(self.Frame:GetWide() - 10, self.Frame:GetTall() - 10)
end
vgui.Register("auctionmenu", PANEL, "Panel")

concommand.Add("UD_OpenAuctionMenu", function(ply, command, args)
	local npc = ply:GetEyeTrace().Entity
	local NPCTable = NPCTable(npc:GetNWString("npc"))
	if not IsValid(npc) or not NPCTable or not NPCTable.Auction then return end
	RunConsoleCommand("UD_RequestAuctionInfo")
	GAMEMODE.AuctionMenu = GAMEMODE.AuctionMenu or vgui.Create("auctionmenu")
	GAMEMODE.AuctionMenu:SetSize(520, 459)
	GAMEMODE.AuctionMenu:Center()
end)
