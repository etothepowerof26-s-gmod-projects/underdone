if CLIENT then
	local tblNotifications = {}
	local intLastTime = 15
	local intStartPosition = ScrH() - 100
	local intSpacing = 5
	local intHieght = 20

	local function DrawNotifications()
		local yOffset = intStartPosition
		for _, strNocification in pairs(tblNotifications) do
			surface.SetFont("MenuLarge")
			local wide, high = surface.GetTextSize(strNocification)
			local pnlNotification = jdraw.NewPanel()
			pnlNotification:SetDimensions(ScrW() - (wide + 40), yOffset, wide + 30, intHieght)
			pnlNotification:SetStyle(4, clrTan)
			pnlNotification:SetBorder(1, clrDrakGray)
			jdraw.DrawPanel(pnlNotification)
			draw.SimpleText(strNocification, "MenuLarge", pnlNotification.Position.X + intHieght, pnlNotification.Position.Y + 3, clrDrakGray, 0, 3)
			yOffset = yOffset - intHieght - intSpacing
		end
	end
	hook.Add("HUDPaint", "DrawNotifications", DrawNotifications)

	function AddNotification(strNotification)
		table.insert(tblNotifications, 1, strNotification)
		timer.Simple(intLastTime, function() table.remove(tblNotifications) end)
	end
	concommand.Add("UD_AddNotification", function(ply, command, args) AddNotification(table.concat(args, " ")) end)
end

if SERVER then
	local Player = FindMetaTable("Player")
	function Player:CreateNotification(strMessage)
		self:ConCommand("UD_AddNotification " .. strMessage)
	end
end
