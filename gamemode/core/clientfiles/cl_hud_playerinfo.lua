local playerIcon = Material("gui/player")
local adminIcon = Material("gui/admin")

local distSqr = 200^2

local function DrawPlayerInfo()
	local localPly    = LocalPlayer()
	local localPlyPos = localPly:GetPos()

	for _, ply in ipairs(player.GetAll()) do
		local pos = ply:GetPos()

		if ply ~= localPly and pos:DistToSqr(localPlyPos) < distSqr then
			local eye_attch = ply:LookupAttachment("eyes")
			if eye_attch and eye_attch >= 0 then
				local eyes = ply:GetAttachment(eye_attch)
				local offset = eyes and eyes.Pos + Vector(0, 0, 15) or pos + Vector(0, 0, 80)

				local posPlayerPos = offset:ToScreen()
				local strDisplayText = ply:Nick() .. " lv." ..  ply:GetLevel()
				surface.SetFont("UiBold")

				local wide = surface.GetTextSize(strDisplayText)
				draw.SimpleTextOutlined(strDisplayText, "UiBold", posPlayerPos.x - 8, posPlayerPos.y, clrWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, clrDrakGray)

				local strIcon = ply:IsAdmin() and adminIcon or playerIcon
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(strIcon)
				surface.DrawTexturedRect(posPlayerPos.x + (wide / 2) + 5 - 8, posPlayerPos.y - 8, 16, 16)
			end
		end
	end
end
hook.Add("HUDPaint", "UD_DrawPlayerInfo", DrawPlayerInfo)
