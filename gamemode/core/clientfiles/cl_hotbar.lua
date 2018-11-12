local HotBarPadding = 1
local HotBarIconSize = 39
local Keys = 9
GM.HotBarBoundKeys = {}
function GM:SetHotBarKey(KeyIcon, Item, NewKey)
	local ItemTable = ItemTable(Item)
	if not ItemTable then return end
	for Key, BoundInfo in pairs(GAMEMODE.HotBarBoundKeys or {}) do
		if BoundInfo.Item == Item then
			BoundInfo.Panel:SetItem(nil, Key, "none")
			BoundInfo.Panel:SetAlpha(255)
			GAMEMODE.HotBarBoundKeys[Key] = {Panel = KeyIcon, Item = nil}
		end
	end
	KeyIcon:SetItem(ItemTable, NewKey, "none")
	if LocalPlayer():GetItem(Item) <= 0 then
		KeyIcon:SetAlpha(100)
	else
		KeyIcon:SetAlpha(255)
	end
	GAMEMODE.HotBarBoundKeys[NewKey] = {Panel = KeyIcon, Item = Item}
end

local function AddKeySlot(Parent, Key)
	local Item = vgui.Create("FIconItem", Parent)
	Item:SetSize(HotBarIconSize, HotBarIconSize)
	Item:SetText(Key)
	Item.FromHotBar = true
	Item:SetDropedOn(function()
		if GAMEMODE.DraggingPanel and GAMEMODE.DraggingPanel.Item and (GAMEMODE.DraggingPanel.FromInventory or GAMEMODE.DraggingPanel.FromHotBar) then
			GAMEMODE:SetHotBarKey(Item, GAMEMODE.DraggingPanel.Item, Key)
		end
	end)
	Parent:AddItem(Item)
	return Item
end

local function AttemptLoad()
	if LocalPlayer().Data and LocalPlayer():GetNWBool("Loaded") then
		local HotBarKeysPanel = vgui.Create("DPanel")
		GAMEMODE.HotBarPanel = HotBarKeysPanel

		HotBarKeysPanel:SetSize((HotBarIconSize + HotBarPadding) * Keys + HotBarPadding, HotBarIconSize + (HotBarPadding * 2))
		HotBarKeysPanel:SetPos(300 + 20, ScrH() - HotBarKeysPanel:GetTall() - 10)
		HotBarKeysPanel.Paint = function() end
		HotBarKeysPanel.KeysList = CreateGenericList(HotBarKeysPanel, HotBarPadding, true, false)
		HotBarKeysPanel.KeysList:SetSize(HotBarKeysPanel:GetWide(), HotBarKeysPanel:GetTall())

		for i = 1, Keys do
			local NewSlot = AddKeySlot(HotBarKeysPanel.KeysList, i)
			GAMEMODE:SetHotBarKey(NewSlot, cookie.GetString("ud_hotbarkeybinds_" .. i), i)
		end
		return
	end
	timer.Simple(0.1, AttemptLoad)
end
hook.Add("Initialize", "UD_HotBar_AttemptLoad", AttemptLoad)

function GM:UpdateHotBar()
	for Key, BoundInfo in pairs(GAMEMODE.HotBarBoundKeys) do
		GAMEMODE:SetHotBarKey(BoundInfo.Panel, BoundInfo.Item, Key)
	end
end

local function DoKeyRelease(Key)
	if GAMEMODE.HotBarBoundKeys[tonumber(Key) - 1] then
		RunConsoleCommand("UD_UseItem", GAMEMODE.HotBarBoundKeys[Key - 1].Item)
	end
end
local KeyEvents = {}
local KeyEventsDebug = false
local KeyEventsDebugChaty = false
local function ThinkKeyDetect()
	if IsValid(GAMEMODE.HotBarPanel) then
		GAMEMODE.HotBarPanel:SetVisible(GAMEMODE.ConVarShowHUD:GetBool())
	end

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
hook.Add("ShutDown", "UD_HotBar_PlayerSaveShutDown", function() for Key, Info in pairs(GAMEMODE.HotBarBoundKeys or {}) do cookie.Set("ud_hotbarkeybinds_" .. Key, Info.Item) end end)
