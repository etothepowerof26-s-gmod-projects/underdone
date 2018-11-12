GM.HoveredIcon = nil
GM.DraggingPanel = nil
GM.DraggingGhost = nil

function GM:DragDropThink()
	if GAMEMODE.DraggingPanel then
		if not GAMEMODE.DraggingGhost then
			GAMEMODE.DraggingGhost = vgui.Create("FIconItem")
			GAMEMODE.DraggingGhost:SetSize(GAMEMODE.DraggingPanel:GetWide(), GAMEMODE.DraggingPanel:GetTall())
			GAMEMODE.DraggingGhost.Icon = GAMEMODE.DraggingPanel.Icon
			GAMEMODE.DraggingGhost.Amount = GAMEMODE.DraggingPanel.Amount
			GAMEMODE.DraggingGhost:SetAlpha(255)
			GAMEMODE.DraggingGhost:MakePopup()
			GAMEMODE.DraggingGhost.IsGhost = true
		end
		GAMEMODE.DraggingGhost:SetPos(gui.MouseX() + 1, gui.MouseY() + 1)
		if not input.IsMouseDown(MOUSE_LEFT) then
			if GAMEMODE.HoveredIcon then
				GAMEMODE.HoveredIcon.DoDropedOn()
			end
			GAMEMODE.DraggingPanel = nil
		end
	else
		if GAMEMODE.DraggingGhost then
			GAMEMODE.DraggingGhost:Remove()
			GAMEMODE.DraggingGhost = nil
		end
	end
end
hook.Add("Think", "DragDropThink", function() GAMEMODE:DragDropThink() end)

function GM:DragDropGUIMouseReleased(mousecode)
	if GAMEMODE.DraggingPanel then
		if GAMEMODE.DraggingPanel.DoDropItem and GAMEMODE.DraggingPanel.FromInventory then
			GAMEMODE.DraggingPanel.DoDropItem()
		elseif GAMEMODE.DraggingPanel.FromHotBar then
			for Key, BoundInfo in pairs(GAMEMODE.HotBarBoundKeys or {}) do
				if BoundInfo.Panel == GAMEMODE.DraggingPanel then
					BoundInfo.Panel:SetItem(nil, Key, "none")
					BoundInfo.Panel:SetAlpha(255)
					GAMEMODE.HotBarBoundKeys[Key] = {Panel = nil, Item = nil}
				end
			end
		end
		GAMEMODE.DraggingPanel = nil
	end
end
hook.Add("GUIMouseReleased", "DragDropGUIMouseReleased", function() GAMEMODE:DragDropGUIMouseReleased() end)

function GM:AddHoverObject(NewHoverObject, ParentObject)
	if not NewHoverObject.IsGhost then
		NewHoverObject.OnCursorEntered = function()
			GAMEMODE.HoveredIcon = ParentObject or NewHoverObject
			if NewHoverObject.OnHover then NewHoverObject.OnHover() end
		end
		NewHoverObject.OnCursorExited = function()
			GAMEMODE.HoveredIcon = nil
		end
	end
end