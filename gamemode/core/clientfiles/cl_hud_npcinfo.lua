local Icon = Material("icon16/emoticon_smile.png")

local function DrawNPCIcon(NPC, NPCPos)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(Icon)
	surface.DrawTexturedRect(NPCPos.x - 8, NPCPos.y - 25 + 8, 16, 16)
end

local function DrawNameText(NPC, NPCPos, Friendly)
	local NpcTable = NPCTable(NPC:GetNWInt("npc"))
	if not NpcTable then return end

	local Level = NPC:GetNWInt("level")
	local PLevel = math.Clamp(LocalPlayer():GetLevel(),0,math.huge)
	local DrawColor = White

	if Level < PLevel then DrawColor = Green end
	if Level > PLevel then DrawColor = Red   end
	if Friendly then DrawColor = White end

	local Title = NpcTable.Title or ""
	if NpcTable.Shop then
		local Shop = ShopTable(NpcTable.Shop)
		if Shop then
			Title = Shop.PrintName
		end
	end
	draw.SimpleTextOutlined(Title, "UiBold", NPCPos.x - 8, NPCPos.y - 20, DrawColor, 1, 1, 1, DrakGray)

	local DrawText = NpcTable.PrintName
	if not Friendly and not NPC:IsBuilding() then DrawText = DrawText .. " lv. " .. Level end

	draw.SimpleTextOutlined(DrawText, "UiBold", NPCPos.x - 8, NPCPos.y - 10, DrawColor, 1, 1, 1, DrakGray)

	if Friendly then
		surface.SetFont("UiBold")
		local wide1 = surface.GetTextSize(Title)
		local wide2 = surface.GetTextSize(DrawText)
		NPCPos.x = NPCPos.x + (math.Max(wide1, wide2) / 2) + 5
		DrawNPCIcon(NPC, NPCPos)
	end
end

local function DrawNPCHealthBar(NPC, NPCPos)
	local BarColor = Green
	local Health = math.Clamp(NPC:Health(),0,9999)
	local MaxHealth = NPC:GetNWInt("MaxHealth")
	if Health <= (MaxHealth * 0.2) then BarColor = Red end

	local NpcHealthBar = jdraw.NewProgressBar()
	NpcHealthBar:SetDimensions(NPCPos.x  - (80 / 2), NPCPos.y, 80, 11)
	NpcHealthBar:SetStyle(4, BarColor)
	NpcHealthBar:SetBorder(1, DrakGray)
	NpcHealthBar:SetText("UiBold", Health, DrakGray)
	NpcHealthBar:SetValue(Health, MaxHealth)
	jdraw.DrawProgressBar(NpcHealthBar)
end

local function DrawNPCInfo()
	for _, ent in pairs(ents.GetAll()) do
		if IsValid(ent) and (ent:IsNPC() or ent:IsBuilding()) and ent:GetNWInt("level") > 0 then
			if ent:GetPos():Distance(LocalPlayer():GetPos()) < 500 then
				local NpcTable = NPCTable(ent:GetNWInt("npc"))
				if not NpcTable then return end
				local Friendly = NpcTable.Race == "human"
				local NPCPos = (ent:GetPos() + Vector(0, 0, 80)):ToScreen()
				DrawNameText(ent, NPCPos, Friendly)
				if not Friendly then DrawNPCHealthBar(ent, NPCPos) end
			end
		end
	end
end
hook.Add("HUDPaint", "UD_DrawNPCInfo", DrawNPCInfo)
