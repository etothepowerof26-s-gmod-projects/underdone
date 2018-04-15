AddCSLuaFile("shared.lua")
AddCSLuaFile("core/sh_resource.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
include("core/sharedfiles/database/items/sh_items_base.lua")
include("core/sh_resource.lua")

function GM:PlayerAuthed(ply,SteamID,UniqueID)
	ply:LoadGame()
end

function GM:PlayerSpawn(ply)
	hook.Call("PlayerLoadout", GAMEMODE, ply)
	ply:SendLua("RunConsoleCommand('cl_phys_props_max', '99999')")
	if not ply.Data then ply:SetModel("models/player/Group01/male_02.mdl") return end
	if not ply.Data.Model then ply:SetModel("models/player/Group01/male_02.mdl") return end
	ply:SetModel(ply.Data.Model or "models/player/Group01/male_02.mdl")
end

function GM:PlayerLoadout(ply)
	if not ply.Data or not ply.Data.Paperdoll then return end
	local strPrimaryWeapon = ply.Data.Paperdoll["slot_primaryweapon"]
	if not strPrimaryWeapon then return end
	local tblItemTable = GAMEMODE.DataBase.Items[strPrimaryWeapon]
	if not tblItemTable then return end
	ply:Give("weapon_primaryweapon")
	ply:GetWeapon("weapon_primaryweapon"):SetWeapon(tblItemTable)
	return true
end

function UseKeyPressed(ply, key)
	local vecHitPos = ply:GetEyeTrace().HitPos
	local entLookEnt = nil
	ply:SearchWorldProp(ply:GetEyeTrace().Entity, "models/props/cs_militia/footlocker01_closed.mdl",
	{"money", "wood", "item_canspoilingmeat", "item_orange"}, 1, "models/props/cs_militia/footlocker01_open.mdl")
	ply:SearchQuestProp(ply:GetEyeTrace().Entity, "models/props/cs_militia/caseofbeer01.mdl", "quest_beer", 1)
	ply:SearchQuestProp(ply:GetEyeTrace().Entity, "models/props_c17/oildrum001.mdl", "quest_oil", 1)
	for _, ent in pairs(ents.FindInSphere(vecHitPos, 20) or {}) do
		if (ent.Item or ent.Shop or ent.Quest or ent.Bank or ent.Auction or ent.Appearance or ent:GetClass() == "prop_physics") and ent:GetClass() ~= "weapon_primaryweapon" and ent:GetPos():Distance(ply:GetPos()) < 85 then
			if not entLookEnt or ent:GetPos():Distance(vecHitPos) < entLookEnt:GetPos():Distance(vecHitPos) then entLookEnt = ent end
		end
	end
	if not entLookEnt or not entLookEnt:IsValid() then return end
	if entLookEnt.Item then
		if entLookEnt:GetOwner() == ply or not IsValid(entLookEnt:GetOwner()) or ply:IsInSquad(entLookEnt:GetOwner()) then
			local intAmount = 1
			if entLookEnt.Amount then intAmount = entLookEnt.Amount end
			if ply:AddItem(entLookEnt.Item, intAmount) then
				if entLookEnt:GetParent() and entLookEnt:GetParent():IsValid() then
					entLookEnt:GetParent():Remove()
				end
				entLookEnt:Remove()
			end
		end
	end
	if entLookEnt.Shop then
		ply.UseTarget = entLookEnt
		ply:SendLua("RunConsoleCommand('UD_OpenShopMenu',\"" .. entLookEnt.Shop .. "\")")
	end
	if entLookEnt.Quest then
		ply.UseTarget = entLookEnt
		ply:SendLua("RunConsoleCommand('UD_OpenQuestMenu',\"" .. entLookEnt:GetNWString("npc") .. "\")")
	end
	if entLookEnt.Bank then
		ply.UseTarget = entLookEnt
		ply:SendLua("RunConsoleCommand('UD_OpenBankMenu',\"" .. entLookEnt:EntIndex() .. "\")")
	end
	if entLookEnt.Auction then
		ply.UseTarget = entLookEnt
		ply:SendLua("RunConsoleCommand('UD_OpenAuctionMenu')")
	end
	if entLookEnt.Appearance then
		ply.UseTarget = entLookEnt
		ply:SendLua("RunConsoleCommand('UD_OpenAppearanceMenu')")
	end
end
hook.Add("KeyPress", "UseKeyPressed", function(ply, key) if key == IN_USE then UseKeyPressed(ply, key) end end)
function GM:PlayerUse(plyPlayer, entEntity) return true end


local function ShowHelpMenu(ply)
	ply:ConCommand("UD_OpenHelp")
end
hook.Add("ShowHelp", "ShowHelpMenu", ShowHelpMenu)
