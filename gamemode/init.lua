AddCSLuaFile("shared.lua")
AddCSLuaFile("core/sh_resource.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
include("core/sharedfiles/database/items/sh_items_base.lua")
include("core/sh_resource.lua")

--Add network strings
local NWStrings = {
	"UD_UpdateItem",
	"UD_UpdateBankItem"
	"UD_UpdateMasters",
	"UD_UpdateAuctions",
	"UD_UpdateLibrary",
	"UD_UpdatePaperDoll",
	"UD_UpdateSpawnPoint",
	"UD_RemoveSpawnPoint",
	"UD_UpdateWorldProp",
	"UD_RemoveWorldProp",
	"UD_UpdateCurrentBook",
	"UD_UpdateTradeItem",
	"UD_UpdateQuest",
	"UD_UpdateInvites",
	"UD_UpdateSquadTable",
	"UD_UpdateSkills",
	"UD_UpdateStats"
}

for _,v in ipairs(NWStrings) do
	util.AddNetworkString(v)
end

function GM:PlayerInitialSpawn(ply)
	timer.Simple(3, function() -- TODO: needs to be networked or something
		if not IsValid(ply) then return end

		ply:LoadGame()
	end)
end

-- TODO: likely not needed, shouldn't be called with playerclass?
-- honestly, most of the data should be moved to a playerclass
function GM:PlayerSpawn(ply)
	hook.Run("PlayerLoadout", ply)
	ply:SetModel(ply.Data and ply.Data.Model or "models/player/Group01/male_02.mdl")

	-- Stops status effects continuing after respawn
	timer.Remove("UD_Stun" .. ply:EntIndex())
	timer.Remove("UD_Burn" .. ply:EntIndex())
end

function GM:PlayerLoadout(ply)
	if not ply.Data or not ply.Data.Paperdoll then return end

	local PrimaryWeapon = ply.Data.Paperdoll["slot_primaryweapon"]
	if not PrimaryWeapon then return end

	local ItemTable = self.DataBase.Items[PrimaryWeapon]
	if not ItemTable then return end

	local primary = ply:Give("weapon_primaryweapon")
	if IsValid(primary) then
		primary:SetWeapon(ItemTable)
	else
		print("Failed to create 'weapon_primaryweapon' for " .. ply:Nick())
	end

	return true
end

local UseDistance = 85^2
local ignoreClasses = {
	weapon_primaryweapon = true
}

function GM:UseKeyPressed(ply)
	local trace = ply:GetEyeTrace()

	-- TODO: hardcoded, room for improvement here
	ply:SearchWorldProp(trace.Entity, "models/props/cs_militia/footlocker01_closed.mdl",
	{"money", "wood", "item_canspoilingmeat", "item_orange"}, 1, "models/props/cs_militia/footlocker01_open.mdl")
	ply:SearchQuestProp(trace.Entity, "models/props/cs_militia/caseofbeer01.mdl", "quest_beer", 1)
	ply:SearchQuestProp(trace.Entity, "models/props_c17/oildrum001.mdl", "quest_oil", 1)

	local UseTarget
	local dist = math.huge

	-- TODO: would be better using the dot product, but I'm not changing behavior for now, just cleanup
	for _, ent in ipairs(ents.FindInSphere(trace.HitPos, 20)) do
		local pos = ent:GetPos()

		if (ent.Item or ent.Shop or ent.Quest or ent.Bank or ent.Auction or ent.Appearance) and not ignoreClasses[ent:GetClass()] and pos:DistToSqr(ply:GetPos()) <= UseDistance then
			local testDist = pos:DistToSqr(trace.HitPos)

			if pos:DistToSqr(trace.HitPos) < dist then
				UseTarget = ent
				dist = pos:DistToSqr(trace.HitPos)
			end
		end
	end

	if not UseTarget or not UseTarget:IsValid() then return end
	ply.UseTarget = UseTarget

	-- TODO: this is pretty awful, should be done with net messages
	if UseTarget.Item then
		local owner = UseTarget:GetOwner()

		if (owner == ply or not IsValid(owner) or ply:IsInSquad(owner)) and
			ply:AddItem(UseTarget.Item, UseTarget.Amount or 1) then
			if IsValid(UseTarget:GetParent()) then
				UseTarget:GetParent():Remove()
			end

			UseTarget:Remove()
		end
	elseif UseTarget.Shop then
		ply:ConCommand("UD_OpenShopMenu " .. UseTarget.Shop)
	elseif UseTarget.Quest then
		ply:ConCommand("UD_OpenQuestMenu " .. UseTarget:GetNWString("npc"))
	elseif UseTarget.Bank then
		ply:ConCommand("UD_OpenBankMenu " .. UseTarget:EntIndex())
	elseif UseTarget.Auction then
		ply:ConCommand("UD_OpenAuctionMenu")
	elseif UseTarget.Appearance then
		ply:ConCommand("UD_OpenAppearanceMenu")
	end
end

function GM:KeyPress(ply, key)
	if key == IN_USE then
		self:UseKeyPressed(ply, key)
	end
end

function GM:PlayerUse(ply, ent)
	return true
end

function GM:ShowHelp(ply)
	ply:ConCommand("UD_OpenHelp")
end

