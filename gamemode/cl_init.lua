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

surface.CreateFont("Trebuchet20", {
	font = "Trebuchet MS",
	size = 20,
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
GM.TranslateColor["green"]  = Green
GM.TranslateColor["orange"] = Orange
GM.TranslateColor["purple"] = Purple
GM.TranslateColor["blue"]   = Blue
GM.TranslateColor["red"]    = Red
GM.TranslateColor["tan"]    = Tan
GM.TranslateColor["white"]  = White

function GM:GetColor(ColorName)
	return GAMEMODE.TranslateColor[ColorName] or White
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