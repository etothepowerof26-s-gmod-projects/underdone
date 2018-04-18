local intHotBarPadding = 1
local intHotBarIconSize = 39
local intKeys = 9
GM.HotBarBoundKeys = {}
function GM:SetHotBarKey(pnlKeyIcon, strItem, intNewKey)
	local tblItemTable = ItemTable(strItem)
	if not tblItemTable then return end
	for intKey, tblBoundInfo in pairs(GAMEMODE.HotBarBoundKeys or {}) do
		if tblBoundInfo.Item == strItem then
			tblBoundInfo.Panel:SetItem(nil, intKey, "none")
			tblBoundInfo.Panel:SetAlpha(255)
			GAMEMODE.HotBarBoundKeys[intKey] = {Panel = pnlKeyIcon, Item = nil}
		end
	end
	pnlKeyIcon:SetItem(tblItemTable, intNewKey, "none")
	if LocalPlayer():GetItem(strItem) <= 0 then
		pnlKeyIcon:SetAlpha(100)
	else
		pnlKeyIcon:SetAlpha(255)
	end
	GAMEMODE.HotBarBoundKeys[intNewKey] = {Panel = pnlKeyIcon, Item = strItem}
end

local function AddKeySlot(pnlParent, intKey)
	local icnItem = vgui.Create("FIconItem", pnlParent)
	icnItem:SetSize(intHotBarIconSize, intHotBarIconSize)
	icnItem:SetText(intKey)
	icnItem.FromHotBar = true
	icnItem:SetDropedOn(function()
		if GAMEMODE.DraggingPanel and GAMEMODE.DraggingPanel.Item and (GAMEMODE.DraggingPanel.FromInventory or GAMEMODE.DraggingPanel.FromHotBar) then
			GAMEMODE:SetHotBarKey(icnItem, GAMEMODE.DraggingPanel.Item, intKey)
		end
	end)
	pnlParent:AddItem(icnItem)
	return icnItem
end

local function AttemptLoad()
	if LocalPlayer().Data and LocalPlayer():GetNWBool("Loaded") then
		local pnlHotBarKeysPanel = vgui.Create("DPanel")
		GAMEMODE.HotBarPanel = pnlHotBarKeysPanel

		function pnlHotBarKeysPanel:Think()
			self:SetVisible(GAMEMODE.ConVarShowHUD:GetBool())
		end

		pnlHotBarKeysPanel:SetSize((intHotBarIconSize + intHotBarPadding) * intKeys + intHotBarPadding, intHotBarIconSize + (intHotBarPadding * 2))
		pnlHotBarKeysPanel:SetPos(300 + 20, ScrH() - pnlHotBarKeysPanel:GetTall() - 10)
		pnlHotBarKeysPanel.Paint = function() end
		pnlHotBarKeysPanel.KeysList = CreateGenericList(pnlHotBarKeysPanel, intHotBarPadding, true, false)
		pnlHotBarKeysPanel.KeysList:SetSize(pnlHotBarKeysPanel:GetWide(), pnlHotBarKeysPanel:GetTall())

		for i = 1, intKeys do
			local pnlNewSlot = AddKeySlot(pnlHotBarKeysPanel.KeysList, i)
			GAMEMODE:SetHotBarKey(pnlNewSlot, cookie.GetString("ud_hotbarkeybinds_" .. i), i)
		end
		return
	end
	timer.Simple(0.1, AttemptLoad)
end
hook.Add("Initialize", "UD_HotBar_AttemptLoad", AttemptLoad)

function GM:UpdateHotBar()
	for intKey, tblBoundInfo in pairs(GAMEMODE.HotBarBoundKeys) do
		GAMEMODE:SetHotBarKey(tblBoundInfo.Panel, tblBoundInfo.Item, intKey)
	end
end

local function DoKeyRelease(intKey)
	if GAMEMODE.HotBarBoundKeys[tonumber(intKey) - 1] then
		RunConsoleCommand("UD_UseItem", GAMEMODE.HotBarBoundKeys[intKey - 1].Item)
	end
end
local KeyEvents = {}
local KeyEventsDebug = false
local KeyEventsDebugChaty = false
local function ThinkKeyDetect()
	if LocalPlayer().UD_IsChating then return end
	for i = 1, 130 do
		KeyEvents[i] = KeyEvents[i] or 0
		if input.IsKeyDown(i) then
			if KeyEvents[i] == 0 then KeyEvents[i] = 1
			elseif KeyEvents[i] == 1 then KeyEvents[i] = 2
			elseif KeyEvents[i] == 2 then KeyEvents[i] = 2
			elseif KeyEvents[i] == 3 then KeyEvents[i] = 1 end
		else
			if KeyEvents[i] == 0 then KeyEvents[i] = 0
			elseif KeyEvents[i] == 1 then KeyEvents[i] = 3
			elseif KeyEvents[i] == 2 then KeyEvents[i] = 3
			elseif KeyEvents[i] == 3 then KeyEvents[i] = 0 end
		end
		if KeyEvents[i] == 3 then DoKeyRelease(i) end
		if KeyEventsDebug then
			if KeyEvents[i] == 1 then LocalPlayer():ChatPrint("You pressed key " .. i)
			elseif KeyEvents[i] == 3 then LocalPlayer():ChatPrint("You released key " .. i) end
		end
		if KeyEventsDebug and KeyEventsDebugChaty then
			if KeyEvents[i] == 0 then LocalPlayer():ChatPrint("You are not pressing key " .. i)
			elseif KeyEvents[i] == 2 then LocalPlayer():ChatPrint("You are hpressing key " .. i) end
		end
	end
end
hook.Add("Think", "UD_HotBar_ThinkKeyDetect", ThinkKeyDetect)

hook.Add("StartChat", "UD_HotBar_StartChatIsChatting", function() LocalPlayer().UD_IsChating = true end)
hook.Add("FinishChat", "UD_HotBar_FinishChatIsChatting", function() LocalPlayer().UD_IsChating = false end)
hook.Add("ShutDown", "UD_HotBar_PlayerSaveShutDown", function() for intKey, tblInfo in pairs(GAMEMODE.HotBarBoundKeys or {}) do cookie.Set("ud_hotbarkeybinds_" .. intKey, tblInfo.Item) end end)
