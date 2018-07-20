local playerIcon = Material("gui/player")
local adminIcon = Material("gui/admin")

local MaxDist = 200^2

local function DrawPlayerInfo()
	local ply = LocalPlayer()
	local PlyPos = ply:GetPos()

	for _, ply in ipairs(player.GetAll()) do
		local pos = ply:GetPos()

		if ply ~= ply and pos:DistToSqr(PlyPos) < MaxDist then
			local eye_attch = ply:LookupAttachment("eyes")
			if eye_attch and eye_attch >= 0 then
				local eyes = ply:GetAttachment(eye_attch)
				local offset = eyes and eyes.Pos + Vector(0, 0, 15) or pos + Vector(0, 0, 80)

				local PlayerPos = offset:ToScreen()
				local DisplayText = ply:Nick() .. " lv." ..  ply:GetLevel()
				surface.SetFont("UiBold")

				local wide = surface.GetTextSize(DisplayText)
				draw.SimpleTextOutlined(DisplayText, "UiBold", PlayerPos.x - 8, PlayerPos.y, White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, DrakGray)

				local Icon = ply:IsAdmin() and adminIcon or playerIcon
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(Icon)
				surface.DrawTexturedRect(PlayerPos.x + (wide / 2) + 5 - 8, PlayerPos.y - 8, 16, 16)
			end
		end
	end
end
hook.Add("HUDPaint", "UD_DrawPlayerInfo", DrawPlayerInfo)
