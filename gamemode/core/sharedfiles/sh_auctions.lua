local Player = FindMetaTable("Player")
--TODO: make these 2 variables global and integrate with GM.Auctions (?)
local DefaultAuctionTime = 24 --1 Day
local CleanUpTime = 168 --1 Week
GM.Auctions = {}

if SERVER then
	function GM:AddAuction(Seller, Item, Amount, SellPrice)
		if not IsValid(Seller) or not Seller:HasItem(Item, Amount) then return false end
		if not Seller:RemoveItem(Item, Amount) then return false end
		if (ItemTable(Item).SellPrice or 0) <= 0 then return false end
		if Amount <= 0 or SellPrice <= 0 then return false end
		table.insert(GAMEMODE.Auctions, {SellerID = Seller:SteamID(), Item = Item, Amount = Amount, Price = SellPrice, TimeLeft = CleanUpTime})
		Seller:CreateNotification("You created an auction for " .. Amount .. " " .. ItemTable(Item).PrintName .. " at the price of " .. SellPrice .. ".")
		Seller:ConCommand("UD_RequestAuctionInfo " .. #GAMEMODE.Auctions)
		GAMEMODE:SaveAuctions()
		return true
	end

	function GM:CancelAuction(Canceler, Key)
		if not IsValid(Canceler) or not GAMEMODE.Auctions[Key] then return false end
		if GAMEMODE.Auctions[Key].SellerID ~= Canceler:SteamID() then return false end
		if GAMEMODE.Auctions[Key].TimeLeft <= CleanUpTime - DefaultAuctionTime then return false end
		GAMEMODE.Auctions[Key].TimeLeft = CleanUpTime - DefaultAuctionTime
		Canceler:CreateNotification("You canceled the auction.")
		Canceler:ConCommand("UD_RequestAuctionInfo " .. Key)
		GAMEMODE:SaveAuctions()
		return true
	end

	function GM:PickUpAuction(PickerUpper, Key)
		if not IsValid(PickerUpper) or not GAMEMODE.Auctions[Key] then return false end
		local AuctionTable = GAMEMODE.Auctions[Key]
		if AuctionTable.TimeLeft <= CleanUpTime - DefaultAuctionTime then
			if AuctionTable.SellerID == PickerUpper:SteamID() then
				if PickerUpper:HasRoomFor({[AuctionTable.Item] = AuctionTable.Amount}) then
					PickerUpper:AddItem(AuctionTable.Item, AuctionTable.Amount)
					PickerUpper:CreateNotification("You picked up your auction.")
					PickerUpper:ConCommand("UD_RequestAuctionInfo " .. Key)
					GAMEMODE.Auctions[Key] = nil
					GAMEMODE:SaveAuctions()
					return true
				end
			end
		end
	end

	function GM:BuyOutAuction(Buyer, Key)
		if not IsValid(Buyer) or not GAMEMODE.Auctions[Key] then return false end
		if GAMEMODE.Auctions[Key].SellerID == Buyer:SteamID() then return false end
		if GAMEMODE.Auctions[Key].TimeLeft <= CleanUpTime - DefaultAuctionTime then return false end
		local AuctionTable = GAMEMODE.Auctions[Key]
		if Buyer:HasItem("money", AuctionTable.Price) and Buyer:HasRoomFor({[AuctionTable.Item] = AuctionTable.Amount}) then
			Buyer:RemoveItem("money", AuctionTable.Price)
			Buyer:AddItem(AuctionTable.Item, AuctionTable.Amount)
			GAMEMODE.Auctions[Key].Item = "money"
			GAMEMODE.Auctions[Key].Amount = AuctionTable.Price
			GAMEMODE.Auctions[Key].TimeLeft = CleanUpTime - DefaultAuctionTime
			GAMEMODE:SaveAuctions()
			Buyer:CreateNotification("You bought out an auction.")
			Buyer:ConCommand("UD_RequestAuctionInfo " .. Key)
			return true
		end
	end

	function GM:LoadAuctions()
		local FileName = "underdone/Auctions.txt"
		if file.Exists(FileName, "DATA") then
			GAMEMODE.Auctions = util.JSONToTable(file.Read(FileName))
		end
	end

	function GM:SaveAuctions()
		local FileName = "underdone/Auctions.txt"
		--PrintTable(GAMEMODE.Auctions)
		file.Write(FileName, util.TableToJSON(GAMEMODE.Auctions))
	end

	function GM:TimerUpdateAuctions()
		for Key, Info in pairs(GAMEMODE.Auctions) do
			Info.TimeLeft = Info.TimeLeft - 0.25
		end
	end

	hook.Add("Initialize", "AuctionsInitialize", function()
		GAMEMODE:LoadAuctions()
		timer.Create("UD_AuctionsHourTimer", 900, 0, function() GAMEMODE:TimerUpdateAuctions() end)
	end)
--SendNetworkMessage -> SendNetworkMessage
	concommand.Add("UD_RequestAuctionInfo", function(ply, command, args)
		if args[1] then
			local AuctionTable = GAMEMODE.Auctions[tonumber(args[1])] or {}
			SendNetworkMessage("UD_UpdateAuctions", ply, {tonumber(args[1]), AuctionTable.SellerID, AuctionTable.Item, AuctionTable.Amount, AuctionTable.Price, AuctionTable.TimeLeft})
			SendNetworkMessage("UD_UpdateAuctions", ply, {0, "", "", 0, 0, 0, true})
		else
			if (ply.NextRequest or 0) > CurTime() then return end
			local Counter = 0
			for Key, Info in pairs(GAMEMODE.Auctions) do
				if (Counter >= (ply:GetNWInt("AuctionPage") * GAMEMODE.AuctionsPerPage) and Counter < ((ply:GetNWInt("AuctionPage") + 1) * GAMEMODE.AuctionsPerPage)) or ply:SteamID() == Info.SellerID or game.SinglePlayer()  then
					if Info.TimeLeft > CleanUpTime - DefaultAuctionTime or ply:SteamID() == Info.SellerID or game.SinglePlayer() then
						timer.Simple(Counter / 200, function()
							SendNetworkMessage("UD_UpdateAuctions", ply, {Key, Info.SellerID, Info.Item, Info.Amount, Info.Price, Info.TimeLeft})
						end)
					end
				end
				if Info.TimeLeft > CleanUpTime - DefaultAuctionTime then
					Counter = Counter + 1
				end
			end
			timer.Simple(Counter / 200, function()
				SendNetworkMessage("UD_UpdateAuctions", ply, {0, "", "", 0, 0, 0, true})
			end)
			ply.NextRequest = CurTime() + 0
		end
	end)

	concommand.Add("UD_CreateAuction", function(ply, command, args)
		GAMEMODE:AddAuction(
			ply,
			args[1],
			math.max(tonumber(args[2] or 1), 1),
			math.max(tonumber(args[3] or 1), 1),
			tonumber(args[3] or 1)
		)
	end)

	concommand.Add("UD_CancelAuction", function(ply, command, args)
		GAMEMODE:CancelAuction(ply, tonumber(args[1]))
	end)

	concommand.Add("UD_PickUpAuction", function(ply, command, args)
		GAMEMODE:PickUpAuction(ply, tonumber(args[1]))
	end)

	concommand.Add("UD_BuyOutAuction", function(ply, command, args)
		GAMEMODE:BuyOutAuction(ply, tonumber(args[1]))
	end)

	concommand.Add("UD_SetAuctionPage", function(ply, command, args)
		ply:SetNWInt("AuctionPage", math.max(tonumber(args[1]), 0))
		ply:ConCommand("UD_RequestAuctionInfo")
	end)
end

if CLIENT then
	net.Receive("UD_UpdateAuctions", function()
		local Key = net.ReadInt(16)
		local SellerID = net.ReadString()
		local Item = net.ReadString()
		local Amount = net.ReadInt(16)
		local Price = net.ReadInt(16)
		local TimeLeft = net.ReadInt(16)
		local Reload = net.ReadBool()
		GAMEMODE.Auctions[Key] = {SellerID = SellerID, Item = Item, Amount = Amount, Price = Price, TimeLeft = TimeLeft}
		if Item == "" then
			GAMEMODE.Auctions[Key] = nil
		end

		if Reload and GAMEMODE.AuctionMenu then
			GAMEMODE.AuctionMenu.BuyAuctions:LoadAuctions()
			GAMEMODE.AuctionMenu.PickUpAuction:LoadAuctions()
		end
	end)
end
