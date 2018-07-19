GM.ConVarShowHUD = CreateClientConVar("ud_showhud", 1, true, false)
GM.ConVarShowCrossHair = CreateClientConVar("ud_showcrosshair", 1, true, false)
GM.ConVarCrossHairProngs = CreateClientConVar("ud_crosshairprongs", 4, true, false)
GM.PlayerHUDBarWidth = 300
local CrossHairAngle = 45
local function GetAnglesCos(Angle, Size)
	return math.cos(math.rad(Angle)) * Size
end
local function GetAnglesSin(Angle, Size)
	return math.sin(math.rad(Angle)) * Size
end
local function DrawAngleLine(PosX, PosY, Angle, Size)
	surface.DrawLine(PosX, PosY, PosX + GetAnglesCos(Angle, Size), PosY + GetAnglesSin(Angle, Size))
end

local squad_leader = Material("icon16/star.png")
local done         = Material("icon16/accept.png")

function GM:HUDPaint()
	if not GAMEMODE.ConVarShowHUD:GetBool() then return end
	self.PlayerBox = jdraw.NewPanel()

	local wep = LocalPlayer():GetActiveWeapon()
	local drawAmmo = not LocalPlayer():IsMelee() and IsValid(wep) and wep.Primary and wep.Primary.ClipSize > 0

	if not drawAmmo then
		self.PlayerBox:SetDimensions(10, ScrH() - 55, GAMEMODE.PlayerHUDBarWidth, 45)
	else
		self.PlayerBox:SetDimensions(10, ScrH() - 73, GAMEMODE.PlayerHUDBarWidth, 63)
	end
	self.PlayerBox:SetStyle(4, Tan)
	self.PlayerBox:SetBorder(1, DrakGray)
	self:DrawSkillPoints()
	jdraw.DrawPanel(self.PlayerBox)

	self:DrawHealthBar()
	self:DrawLevelBar()

	if drawAmmo then self:DrawAmmoBar() end

	self:DrawQuestToDoList()
	local YOffset = self.PlayerBox.Position.Y
	if LocalPlayer():GetNWInt("SkillPoints") > 0 then YOffset = YOffset - 25 end
	self:DrawSquadMembers(10, -1)

	if GAMEMODE.ConVarShowCrossHair:GetBool() then
		local Size = 4
		local Lines = GAMEMODE.ConVarCrossHairProngs:GetInt()
		local Rate = 0
		local X = ScrW() / 2.0
		local Y = LocalPlayer():GetEyeTraceNoCursor().HitPos:ToScreen().y
		surface.SetDrawColor(Green)
		CrossHairAngle = CrossHairAngle + Rate
		for i = 0, (Lines - 1) do
			DrawAngleLine(X, Y, CrossHairAngle + ((i / Lines) * 360), Size)
		end
	end
	if not LocalPlayer():Alive() then
		surface.SetDrawColor(50, 50, 50, 200)
		local DrawBoxY = ScrH() * 0.1
		surface.DrawRect(0, DrawBoxY, ScrW(), 100)
		surface.SetDrawColor(10, 10, 10, 150)
		surface.DrawRect(0, DrawBoxY, ScrW(), 20)
		surface.DrawRect(0, DrawBoxY + 100 - 20, ScrW(), 20)
		if not LocalPlayer().Respawning then
			LocalPlayer().Respawning = true
			for i = 1, 10 do
				timer.Simple(i, function() RespawnTime = 10 - i end)
			end
			timer.Simple(10, function() LocalPlayer().Respawning = false end)
		end
		draw.DrawText("Respawn in: " .. (RespawnTime or 10) .. " Seconds", "ScoreboardDefaultTitle", ScrW() * 0.5, DrawBoxY + 35, White, 1, 1)
	end
end

function GM:DrawQuestToDoList()
	local YOffset = 200
	local Padding = 13
	local QuestNumber = 0
	local NameColour = White
	if not LocalPlayer().Data then return end
	for Quest, Info in pairs(LocalPlayer().Data.Quests or {}) do
		if LocalPlayer():GetQuest(Quest) and not LocalPlayer():HasCompletedQuest(Quest) then
			local QuestTable = QuestTable(Quest)
			local XOffset = ScrW() - 200
			if QuestTable.Level then
				if LocalPlayer():GetLevel() > QuestTable.Level then
					NameColour = Blue
				end
			end
			if LocalPlayer():CanTurnInQuest(Quest) then
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(Material("gui/accept"))
				surface.DrawTexturedRect(XOffset - 20, YOffset - 8, 16, 16)
			end
			draw.SimpleTextOutlined(QuestTable.PrintName, "Trebuchet20", XOffset, YOffset, NameColour, 0, 1, 1, DrakGray)
			YOffset = YOffset + Padding + 5
			XOffset = XOffset + 20
			for NPC, Amount in pairs(Info.Kills or {}) do
				if !NPCTable(NPC) then return end
				draw.SimpleTextOutlined(".", "Trebuchet20", XOffset - 8, YOffset - 5, white, 0, 1, 1, DrakGray)
				if Amount < QuestTable.Kill[NPC] then
					draw.SimpleTextOutlined("Kill " .. NPCTable(NPC).PrintName .. " (" .. Amount .. "/" .. QuestTable.Kill[NPC] .. ")", "Trebuchet18", XOffset, YOffset, White, 0, 1, 1, DrakGray)
					YOffset = YOffset + Padding
					for _, NPC in pairs(ents.FindByClass("npc_" .. NPC)) do
						if not NPC.HasWayPoint and not LocalPlayer():CanTurnInQuest(Quest) then
							NPC.HasWayPoint = true
							local vPoint = NPC:GetPos()
							WayPoint = EffectData()
							WayPoint:SetStart( vPoint )
							WayPoint:SetOrigin( vPoint )
							WayPoint:SetEntity(NPC)
							WayPoint:SetScale( 1 )
							util.Effect( "selection_ring", WayPoint )
						end
					end
				else
					draw.SimpleTextOutlined("Kill " .. NPCTable(NPC).PrintName .. " (" .. QuestTable.Kill[NPC] .. "/" .. QuestTable.Kill[NPC] .. ")", "Trebuchet18", XOffset, YOffset, White, 0, 1, 1, DrakGray)
					YOffset = YOffset + Padding
				end
			end
			for Item, AmountNeeded in pairs(QuestTable.ObtainItems or {}) do
				local ItemsGot = LocalPlayer():GetItem(Item) or 0
				local ItemTable = ItemTable(Item)
				draw.SimpleTextOutlined(".", "Trebuchet20", XOffset - 8, YOffset - 5, white, 0, 1, 1, DrakGray)
				if ItemsGot < AmountNeeded then
					draw.SimpleTextOutlined(ItemTable.PrintName .. " (" .. ItemsGot .. "/" .. AmountNeeded .. ")", "Trebuchet18", XOffset, YOffset, White, 0, 1, 1, DrakGray)
					YOffset = YOffset + Padding
					for _,prop in pairs(ents.FindByClass("prop_physics")) do
						if IsValid(prop) and ItemTable.Model == prop:GetModel() then
							if not prop.HasWayPoint and not LocalPlayer():CanTurnInQuest(Quest) then
								prop.HasWayPoint = true
								local vPoint = prop:GetPos()
								WayPoint = EffectData()
								WayPoint:SetStart( vPoint )
								WayPoint:SetOrigin( vPoint )
								WayPoint:SetEntity(prop)
								WayPoint:SetScale( 1 )
								util.Effect( "selection_ring", WayPoint )
							end
						end
					end
				else
					draw.SimpleTextOutlined(ItemTable.PrintName .. " (" .. AmountNeeded .. "/" .. AmountNeeded .. ")", "Trebuchet18", XOffset, YOffset, White, 0, 1, 1, DrakGray)
					YOffset = YOffset + Padding
				end
			end
			YOffset = YOffset + 10
			QuestNumber = QuestNumber + 1
		end
	end
end

function GM:DrawSquadMembers(YOffset, Direction)
	Direction = Direction or 1
	local Padding = 40
	local Key = 0
	if #(LocalPlayer().Squad or {}) <= 1 then return end
	for key, SquadMate in pairs(LocalPlayer().Squad or {}) do
		if not IsValid(SquadMate) then LocalPlayer().Squad[key] = nil end
		if IsValid(SquadMate) and SquadMate ~= LocalPlayer() then
			if SquadMate ~= LocalPlayer() then
				self:DrawSquadHealthBar(SquadMate)
			end
			jdraw.QuickDrawPanel(Tan, 10, YOffset - (Key * Padding * Direction), 250, Padding - 5)
			draw.SimpleTextOutlined(SquadMate:Nick() .. " lv." .. SquadMate:GetLevel(), "Trebuchet18", 15, YOffset - (Key * Padding * Direction), DrakGray, 0, 0, 0, DrakGray)
			jdraw.DrawHealthBar(SquadMate:Health(), SquadMate:GetNWInt("MaxHealth"), 15, YOffset - ((Key) * Padding * Direction) + 17, 250 - 10, 13)
			if SquadMate == LocalPlayer():GetNWEntity("SquadLeader") then
				jdraw.DrawIcon(squad_leader, 3, YOffset - 5 - (Key * Padding * Direction), 16)
			end
			Key = Key + 1
		end
	end
end

function GM:DrawSquadHealthBar(SquadMate)
	if SquadMate:GetPos():Distance(LocalPlayer():GetPos()) < 500 then
		local PosSquadPos = (SquadMate:GetPos() + Vector(0, 0, 80)):ToScreen()
		jdraw.DrawHealthBar(SquadMate:Health(), SquadMate:GetNWInt("MaxHealth"), PosSquadPos.x - (80 / 2), PosSquadPos.y + 8, 80, 11)
	end
end

function GM:DrawSkillPoints()
	if LocalPlayer():GetNWInt("SkillPoints") > 0 then
		self.SkillBar = jdraw.NewProgressBar(self.PlayerBox, true)
		self.SkillBar:SetDimensions(3, -21, 125, 23)
		self.SkillBar:SetStyle(4, Tan)
		self.SkillBar:SetText("UiBold", "Unused SkillPoints " .. LocalPlayer():GetNWInt("SkillPoints"), DrakGray)
		jdraw.DrawProgressBar(self.SkillBar)
	end
end

function GM:DrawHealthBar()
	local BarColor = Green
	if LocalPlayer():GetStat("stat_maxhealth") then
		if LocalPlayer():Health() <= (LocalPlayer():GetStat("stat_maxhealth") * 0.2) then BarColor = Red end
		self.HealthBar = jdraw.NewProgressBar(self.PlayerBox, true)
		self.HealthBar:SetDimensions(3, 3, self.PlayerBox.Size.Width - 6, 20)
		self.HealthBar:SetStyle(4, BarColor)
		self.HealthBar:SetValue(LocalPlayer():Health(), LocalPlayer():GetStat("stat_maxhealth"))
		self.HealthBar:SetText("UiBold", "Health " .. LocalPlayer():Health(), DrakGray)
		jdraw.DrawProgressBar(self.HealthBar)
	end
end

function GM:DrawLevelBar()
	local playerlevel = tonumber(LocalPlayer():GetLevel()) or 0
	local CurrentLevelExp = toExp(playerlevel)
	local NextLevelExp = toExp(playerlevel + 1)
	local BarColor = Orange
	self.LevelBar = jdraw.NewProgressBar(self.PlayerBox, true)
	self.LevelBar:SetDimensions(3, self.HealthBar.Size.Height + 6, self.PlayerBox.Size.Width - 6, 15)
	self.LevelBar:SetStyle(4, BarColor)
	self.LevelBar:SetValue(LocalPlayer():GetNWInt("exp") - CurrentLevelExp, NextLevelExp - CurrentLevelExp)
	self.LevelBar:SetText("UiBold", "Level " .. LocalPlayer():GetLevel(), DrakGray)
	jdraw.DrawProgressBar(self.LevelBar)
end

function GM:DrawAmmoBar()
	local entActiveWeapon = LocalPlayer():GetActiveWeapon()
	local CurrentClip = entActiveWeapon:Clip1()
	local WeaponTable = entActiveWeapon.WeaponTable or {}
	local AmmoType = WeaponTable.AmmoType or "none"
	local BarColor = Blue
	self.AmmoBar = jdraw.NewProgressBar(self.PlayerBox, true)
	self.AmmoBar:SetDimensions(3, self.HealthBar.Size.Height + self.LevelBar.Size.Height + 9, self.PlayerBox.Size.Width - 6, 15)
	self.AmmoBar:SetStyle(4, BarColor)
	self.AmmoBar:SetValue(CurrentClip, WeaponTable.ClipSize or 1)
	self.AmmoBar:SetText("UiBold", "Ammo " .. CurrentClip .. "  " .. LocalPlayer():GetAmmoCount(AmmoType), DrakGray)
	jdraw.DrawProgressBar(self.AmmoBar)
end

function GM:HUDShouldDraw(name)
	local ply = LocalPlayer()
	if ply and ply:IsValid() then
		local wep = ply:GetActiveWeapon()
		if wep and wep:IsValid() and wep.HUDShouldDraw ~= nil then
			return wep.HUDShouldDraw(wep, name)
		end
	end
	if name == "CHudHealth" or name == "CHudBattery" or name == "CHudAmmo" or name == "CHudSecondaryAmmo" or name == "CHudWeaponSelection" then
		return false
	end
	return true
end
