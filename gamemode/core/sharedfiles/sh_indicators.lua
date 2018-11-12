if CLIENT then
	local tblIndacators = {}
	local intLifeTime = 4
	local intFadeRate = 1
	local intGravity = 0.02
	local intFriction = 1.1

	local function DrawIndacators()
		for _, tblInfo in pairs(tblIndacators) do
			local posIndicatorPos = tblInfo.Position:ToScreen()
			local clrDrawColor = tblInfo.Color
			local clrDrawColorBorder = Color(clrDrakGray.r, clrDrakGray.g, clrDrakGray.b, clrDrawColor.a)
			draw.SimpleTextOutlined(tblInfo.String, "Trebuchet24", posIndicatorPos.x, posIndicatorPos.y, clrDrawColor, 1, 1, 1, clrDrawColorBorder)
			tblInfo.Color.a = math.Clamp(tblInfo.Color.a - intFadeRate, 0, 255) --Apply Fade
			tblInfo.Velocity.z = tblInfo.Velocity.z - intGravity --Apply Gravity
			tblInfo.Velocity = tblInfo.Velocity / intFriction --Apply Friction
			tblInfo.Position = tblInfo.Position + tblInfo.Velocity --Set Position based on Velocity
		end
	end
	hook.Add("HUDPaint", "DrawIndacators", DrawIndacators)

	function GM:AddIndacator(tblInfo)
		table.insert(tblIndacators, 1, tblInfo)
		timer.Simple(intLifeTime, function() table.remove(tblIndacators, #tblIndacators) end)
	end
	concommand.Add("UD_AddDamageIndacator", function(ply, command, args)
		local vecPosition = VectortizeString(args[2])
		local clrColor = GAMEMODE:GetColor(args[3])
		local tblInfo = {}
		tblInfo.String = string.gsub(args[1], "_", " ")
		tblInfo.Color = Color(clrColor.r, clrColor.g, clrColor.b, clrColor.a)
		tblInfo.Velocity = Vector(math.random(-3, 3), math.random(-3, 3), 3)
		tblInfo.Position = vecPosition + Vector(math.random(-10, 10), math.random(-10, 10), math.random(0, 20))
		GAMEMODE:AddIndacator(tblInfo)
	end)
end

if SERVER then
	local Player = FindMetaTable("Player")
	function Player:CreateIndicator(strMessage, vecPosition, strColor, boolSendAll)
		local strSendColor = strColor or "white"
		local strCommand = "UD_AddDamageIndacator " .. strMessage .. " " .. StringatizeVector(vecPosition) .. " " .. strSendColor
		self:ConCommand(strCommand)
		if boolSendAll then
			for _, ply in pairs(player.GetAll()) do
				if self ~= ply and ply:GetPos():Distance(self:GetPos()) < 200 then
					ply:ConCommand(strCommand)
				end
			end
		end
	end
end