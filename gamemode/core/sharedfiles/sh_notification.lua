if CLIENT then
	local Notifications = {}
	local Delay = 15
	local StartPosition = ScrH() - 100
	local Spacing = 5
	local Height = 20

	local function DrawNotifications()
		local yOffset = StartPosition
		for _, Notification in pairs(Notifications) do
			surface.SetFont("MenuLarge")
			local wide, high = surface.GetTextSize(Notification)
			local NotifPanel = jdraw.NewPanel()
			NotifPanel:SetDimensions(ScrW() - (wide + 40), yOffset, wide + 30, Height)
			NotifPanel:SetStyle(4, clrTan)
			NotifPanel:SetBorder(1, clrDrakGray)
			jdraw.DrawPanel(NotifPanel)
			draw.SimpleText(Notification, "MenuLarge", NotifPanel.Position.X + Height, NotifPanel.Position.Y + 3, clrDrakGray, 0, 3)
			yOffset = yOffset - Height - Spacing
		end
	end
	hook.Add("HUDPaint", "DrawNotifications", DrawNotifications)
	
	net.Receive("UD_AddNotification", function()
		local Message = net.ReadString()
		
		table.insert(Notifications, 1, Message)
		timer.Simple(Delay, function() table.remove(Notifications) end)
	end)
end

if SERVER then
	util.AddNetworkString("UD_AddNotification")
	
	local Player = FindMetaTable("Player")
	function Player:CreateNotification(Message)
		net.Start"UD_AddNotification"
			net.WriteString(Message)
		net.Send(self)
	end
end
