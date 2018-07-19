local function DrawItemInfo() -- TODO: remake, easy job
	for _, ent in pairs(ents.FindByClass("prop_*")) do
		if IsValid(ent) and ent:GetNWString("PrintName") and ent:GetNWInt("Amount") > 0 then
			if ent:GetPos():Distance(LocalPlayer():GetPos()) < 200 then
				local EntPos = (ent:GetPos() + Vector(0, 0, 10)):ToScreen()
				local Text = ent:GetNWString("PrintName")
				if ent:GetNWInt("Amount") > 1 then Text = Text .. " x" .. ent:GetNWInt("Amount") end
				if ent:GetOwner() == LocalPlayer() or not IsValid(ent:GetOwner()) or LocalPlayer():IsInSquad(ent:GetOwner()) then
					draw.SimpleTextOutlined(Text, "UiBold", EntPos.x, EntPos.y - 10, White, 1, 1, 1, DrakGray)
					ent:SetColor(Color(255, 255, 255, 255))
				else
					ent:SetColor(Color(255, 255, 255, 0))
				end
			end
			if ent:GetModel() == "models/props/de_inferno/clayoven.mdl" then
				if ent:GetPos():Distance(LocalPlayer():GetPos()) < 200 then
					local EntPos = (ent:GetPos() + Vector(0, 0, 40)):ToScreen()
					draw.SimpleTextOutlined("Work Bench", "UiBold", EntPos.x, EntPos.y, White, 1, 1, 1, DrakGray)
				end
			end
		end
	end
end
hook.Add("HUDPaint", "UD_DrawItemInfo", DrawItemInfo)
