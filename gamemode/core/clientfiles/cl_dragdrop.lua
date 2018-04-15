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
			for intKey, tblBoundInfo in pairs(GAMEMODE.HotBarBoundKeys or {}) do
				if tblBoundInfo.Panel == GAMEMODE.DraggingPanel then
					tblBoundInfo.Panel:SetItem(nil, intKey, "none")
					tblBoundInfo.Panel:SetAlpha(255)
					GAMEMODE.HotBarBoundKeys[intKey] = {Panel = nil, Item = nil}
				end
			end
		end
		GAMEMODE.DraggingPanel = nil
	end
end
hook.Add("GUIMouseReleased", "DragDropGUIMouseReleased", function() GAMEMODE:DragDropGUIMouseReleased() end)

function GM:AddHoverObject(pnlNewHoverObject, pnlParentObject)
	if not pnlNewHoverObject.IsGhost then
		pnlNewHoverObject.OnCursorEntered = function()
			GAMEMODE.HoveredIcon = pnlParentObject or pnlNewHoverObject
			if pnlNewHoverObject.OnHover then pnlNewHoverObject.OnHover() end
		end
		pnlNewHoverObject.OnCursorExited = function()
			GAMEMODE.HoveredIcon = nil
		end
	end
end