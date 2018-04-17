-- Recreate old GM12 fonts
surface.CreateFont("UiBold", {
	font = "Tahoma",
	size = 12,
	weight = 1000,
})

surface.CreateFont("MenuLarge", {
	font = "Verdana",
	size = 15,
	weight = 600,
	antialias = true,
})

surface.CreateFont("Trebuchet22", {
	font = "Trebuchet MS",
	size = 22,
	weight = 900,
})

surface.CreateFont("DefaultFixedOutline", {
	font = "Lucida Console",
	size = 10,
	weight = 0,
	outline = true,
})

RunConsoleCommand("cl_phys_props_max", "99999")

include("shared.lua")
include("core/sharedfiles/database/items/sh_items_base.lua")
include("core/sh_resource.lua")

GM.TranslateColor = {}
GM.TranslateColor["green"]  = clrGreen
GM.TranslateColor["orange"] = clrOrange
GM.TranslateColor["purple"] = clrPurple
GM.TranslateColor["blue"]   = clrBlue
GM.TranslateColor["red"]    = clrRed
GM.TranslateColor["tan"]    = clrTan
GM.TranslateColor["white"]  = clrWhite

function GM:GetColor(strColorName)
	return GAMEMODE.TranslateColor[strColorName] or clrWhite
end

-- Disable new scoreboard
function GM:ScoreboardShow()
end

function GM:ScoreboardHide()
end

local function forceDataTbl()
	local ply = LocalPlayer()

	if IsValid(ply) then
		ply.Data = ply.Data or {}
		hook.Remove("Tick", "UD_ForceDataTbl")
	end
end
hook.Add("Tick", "UD_ForceDataTbl", forceDataTbl)

local Player = FindMetaTable("Player")
function Player:PlaySound(main, fallback)
	if not IsValid(self) then return end

	if main and file.Exists("sound/" .. main, "GAME") then
		surface.PlaySound(main)
	elseif fallback and file.Exists("sound/" .. fallback, "GAME") then
		surface.PlaySound(fallback)
	end
end

concommand.Add("UD_PlaySound", function(ply, command, args)
	ply:PlaySound(args[1], args[2])
end)

do
	local bool = false
	local function toggleScreenClicker()
		bool = not bool
		gui.EnableScreenClicker(bool)
	end

	hook.Add("PlayerBindPress", "UD_ToggleScreenClicker", function(ply, bind, pressed)
		if bind == "gm_showspare1" and pressed then
			toggleScreenClicker()
		end
	end)
end
