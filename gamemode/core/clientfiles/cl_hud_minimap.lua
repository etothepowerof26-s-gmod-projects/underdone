local MPositionX = ScrW() - 200
local MPositionY = 15
local MSizeW = 160
local MSizeH = 160
local IconSize = 8

local mat_cache = {}

local function DrawUDMiniMap()

	local LocalPos = LocalPlayer():GetPos()

	local MapBorder = jdraw.NewPanel()
	MapBorder:SetDimensions( MPositionX - 5, MPositionY - 5, MSizeW + 10, MSizeH + 10)
	MapBorder:SetStyle(4, Tan)
	MapBorder:SetBorder(1, DrakGray)
	jdraw.DrawPanel(MapBorder)

	local MiniMapData = {}
	MiniMapData.angles = Angle(90,0,0)
	MiniMapData.origin = LocalPos + Vector(0,0,900)
	MiniMapData.x = MPositionX
	MiniMapData.y = MPositionY
	MiniMapData.w = MSizeW
	MiniMapData.h = MSizeH
	render.RenderView( MiniMapData )

	for _,v in pairs(ents.GetAll()) do
		if IsValid(v) then
			if v:IsPlayer() then
				MapIcon = "gui/player" -- I dont have any alternative
			end
			if v:IsNPC() then
				local NPCTable = NPCTable(v:GetNWInt("npc"))
				if not NPCTable then return end
				if NPCTable.Appearance then
					MapIcon = "icon16/palette.png"
				elseif NPCTable.Bank then
					MapIcon = "icon16/box.png"
				elseif NPCTable.Auction then
					MapIcon = "icon16/world.png"
				elseif NPCTable.Quest then
					MapIcon = "icon16/group.png"
				elseif NPCTable.Shop then
					MapIcon = "icon16/emoticon_smile.png"
				else
					MapIcon = "icon16/exclamation.png"
				end
			end
			if v:IsNPC() or v:IsPlayer() then
				if not MapIcon then return end
				local Distance = LocalPos - v:GetPos()
				Distance:Rotate( Angle(0,180,0) )
				local MapY = Distance.x * (MSizeW / ((900 * 1.5) + (Distance.z * 1.5)))
				local MapX = Distance.y * (MSizeH / ((900 * 1.5) + (Distance.z * 1.5)))

				if MapX < (MSizeH / 2.1) && MapX > (-MSizeH / 2.1) && MapY < (MSizeW / 2.1) && MapY > (-MSizeW / 2.1) then
					surface.SetDrawColor(255, 255, 255, 255)
					local mat = mat_cache[MapIcon]
					if not mat then
						mat = Material(MapIcon)
						mat_cache[MapIcon] = mat
					end
					surface.SetMaterial(mat)
					surface.DrawTexturedRect((MPositionX + (MSizeW / 2) - (IconSize / 2)) - MapX,(MPositionY + (MSizeH / 2 - (IconSize / 2))) - MapY, IconSize, IconSize)
				end
			end
		end
	end
end
hook.Add("HUDPaint", "DrawUDMiniMap", DrawUDMiniMap)
