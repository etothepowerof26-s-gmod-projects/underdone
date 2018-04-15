local Player = FindMetaTable("Player")
local intDefaultAuctionTime = 24 --1 Day
local intCleanUpTime = 168 --1 Week
GM.Auctions = {}

if SERVER then
	function GM:AddAuction(plySeller, strItem, intAmount, intSellPrice)
		if not IsValid(plySeller) or not plySeller:HasItem(strItem, intAmount) then return false end
		if not plySeller:RemoveItem(strItem, intAmount) then return false end
		if (ItemTable(strItem).SellPrice or 0) <= 0 then return false end
		if intAmount <= 0 or intSellPrice <= 0 then return false end
		table.insert(GAMEMODE.Auctions, {SellerID = plySeller:SteamID(), Item = strItem, Amount = intAmount, Price = intSellPrice, TimeLeft = intCleanUpTime})
		plySeller:CreateNotification("You created an auction for " .. intAmount .. " " .. ItemTable(strItem).PrintName .. " at the price of " .. intSellPrice .. ".")
		plySeller:ConCommand("UD_RequestAuctionInfo " .. #GAMEMODE.Auctions)
		GAMEMODE:SaveAuctions()
		return true
	end

	function GM:CancelAuction(plyCanceler, intKey)
		if not IsValid(plyCanceler) or not GAMEMODE.Auctions[intKey] then return false end
		if GAMEMODE.Auctions[intKey].SellerID ~= plyCanceler:SteamID() then return false end
		if GAMEMODE.Auctions[intKey].TimeLeft <= intCleanUpTime - intDefaultAuctionTime then return false end
		GAMEMODE.Auctions[intKey].TimeLeft = intCleanUpTime - intDefaultAuctionTime
		plyCanceler:CreateNotification("You canceled the auction.")
		plyCanceler:ConCommand("UD_RequestAuctionInfo " .. intKey)
		GAMEMODE:SaveAuctions()
		return true
	end

	function GM:PickUpAuction(plyPickerUper, intKey)
		if not IsValid(plyPickerUper) or not GAMEMODE.Auctions[intKey] then return false end
		local tblAuctionTable = GAMEMODE.Auctions[intKey]
		if tblAuctionTable.TimeLeft <= intCleanUpTime - intDefaultAuctionTime then
			if tblAuctionTable.SellerID == plyPickerUper:SteamID() then
				if plyPickerUper:HasRoomFor({[tblAuctionTable.Item] = tblAuctionTable.Amount}) then
					plyPickerUper:AddItem(tblAuctionTable.Item, tblAuctionTable.Amount)
					plyPickerUper:CreateNotification("You picked up your auction.")
					plyPickerUper:ConCommand("UD_RequestAuctionInfo " .. intKey)
					GAMEMODE.Auctions[intKey] = nil
					GAMEMODE:SaveAuctions()
					return true
				end
			end
		end
	end

	function GM:BuyOutAuction(plyBuyer, intKey)
		if not IsValid(plyBuyer) or not GAMEMODE.Auctions[intKey] then return false end
		if GAMEMODE.Auctions[intKey].SellerID == plyBuyer:SteamID() then return false end
		if GAMEMODE.Auctions[intKey].TimeLeft <= intCleanUpTime - intDefaultAuctionTime then return false end
		local tblAuctionTable = GAMEMODE.Auctions[intKey]
		if plyBuyer:HasItem("money", tblAuctionTable.Price) and plyBuyer:HasRoomFor({[tblAuctionTable.Item] = tblAuctionTable.Amount}) then
			plyBuyer:RemoveItem("money", tblAuctionTable.Price)
			plyBuyer:AddItem(tblAuctionTable.Item, tblAuctionTable.Amount)
			GAMEMODE.Auctions[intKey].Item = "money"
			GAMEMODE.Auctions[intKey].Amount = tblAuctionTable.Price
			GAMEMODE.Auctions[intKey].TimeLeft = intCleanUpTime - intDefaultAuctionTime
			plyBuyer:CreateNotification("You bought out an auction.")
			plyBuyer:ConCommand("UD_RequestAuctionInfo " .. intKey)
			GAMEMODE:SaveAuctions()
			return true
		end
	end

	function GM:LoadAuctions()
		local strFileName = "underdone/Auctions.txt"
		if file.Exists(strFileName, "DATA") then
			GAMEMODE.Auctions = util.JSONToTable(file.Read(strFileName))
		end
	end

	function GM:SaveAuctions()
		local strFileName = "underdone/Auctions.txt"
		--PrintTable(GAMEMODE.Auctions)
		file.Write(strFileName, util.TableToJSON(GAMEMODE.Auctions))
	end

	function GM:TimerUpdateAuctions()
		for intKey, tlInfo in pairs(GAMEMODE.Auctions) do
			tlInfo.TimeLeft = tlInfo.TimeLeft - 0.25
		end
	end

	hook.Add("Initialize", "AuctionsInitialize", function()
		GAMEMODE:LoadAuctions()
		--3600 seconds in an hour 900 in 15 min
		timer.Create("UD_AuctionsHourTimer", 900, 0, function() GAMEMODE:TimerUpdateAuctions() end)
	end)

	concommand.Add("UD_RequestAuctionInfo", function(ply, command, args)
		if args[1] then
			local tblAuctionTable = GAMEMODE.Auctions[tonumber(args[1])] or {}
			SendUsrMsg("UD_UpdateAuctions", ply, {tonumber(args[1]), tblAuctionTable.SellerID, tblAuctionTable.Item, tblAuctionTable.Amount, tblAuctionTable.Price, tblAuctionTable.TimeLeft})
			SendUsrMsg("UD_UpdateAuctions", ply, {0, "", "", 0, 0, 0, true})
		else
			if (ply.NextRequest or 0) > CurTime() then return end
			local intCounter = 0
			for intKey, tblInfo in pairs(GAMEMODE.Auctions) do
				if (intCounter >= (ply:GetNWInt("AuctionPage") * GAMEMODE.AuctionsPerPage) and intCounter < ((ply:GetNWInt("AuctionPage") + 1) * GAMEMODE.AuctionsPerPage)) or ply:SteamID() == tblInfo.SellerID or game.SinglePlayer()  then
					if tblInfo.TimeLeft > intCleanUpTime - intDefaultAuctionTime or ply:SteamID() == tblInfo.SellerID or game.SinglePlayer() then
						timer.Simple(intCounter / 200, function()
							SendUsrMsg("UD_UpdateAuctions", ply, {intKey, tblInfo.SellerID, tblInfo.Item, tblInfo.Amount, tblInfo.Price, tblInfo.TimeLeft})
						end)
					end
				end
				if tblInfo.TimeLeft > intCleanUpTime - intDefaultAuctionTime then
					intCounter = intCounter + 1
				end
			end
			timer.Simple(intCounter / 200, function()
				SendUsrMsg("UD_UpdateAuctions", ply, {0, "", "", 0, 0, 0, true})
			end)
			ply.NextRequest = CurTime() + 0
		end
	end)

	concommand.Add("UD_CreateAuction", function(ply, command, args)
		GAMEMODE:AddAuction(ply, args[1], math.Clamp(tonumber(args[2] or 1), 1, tonumber(args[2] or 1)), math.Clamp(tonumber(args[3] or 1), 1, tonumber(args[3] or 1)))
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
		ply:SetNWInt("AuctionPage", math.Clamp(tonumber(args[1]), 0, 9999))
		ply:ConCommand("UD_RequestAuctionInfo")
	end)
end

if CLIENT then
	usermessage.Hook("UD_UpdateAuctions", function(usrMsg)
		local intKey = usrMsg:ReadLong()
		local strSellerID = usrMsg:ReadString()
		local strItem = usrMsg:ReadString()
		local intAmount = usrMsg:ReadLong()
		local intPrice = usrMsg:ReadLong()
		local intTimeLeft = usrMsg:ReadLong()
		local boolReload = usrMsg:ReadBool()
		GAMEMODE.Auctions[intKey] = {SellerID = strSellerID, Item = strItem, Amount = intAmount, Price = intPrice, TimeLeft = intTimeLeft}
		if strItem == "" then
			GAMEMODE.Auctions[intKey] = nil
		end
		--print(intKey, strSellerID, strItem, intAmount, intPrice, intTimeLeft, boolReload)
		if boolReload and GAMEMODE.AuctionMenu then
			GAMEMODE.AuctionMenu.BuyAuctions:LoadAuctions()
			GAMEMODE.AuctionMenu.PickUpAuction:LoadAuctions()
			--PrintTable(GAMEMODE.Auctions)
		end
	end)
end
