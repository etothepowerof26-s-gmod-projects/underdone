GM.QuestMenu = nil
PANEL = {}
PANEL.Frame = nil
PANEL.QuestList = nil
PANEL.QuestDescription = nil
PANEL.ItemIconSize = 39

function PANEL:Init()
	self.Frame = CreateGenericFrame("Quest Menu", false, true)
	self.Frame.CloseButton.DoClick = function()
		GAMEMODE.QuestMenu.Frame:Close()
		GAMEMODE.QuestMenu = nil
	end
	self.Frame:MakePopup()

	self.QuestList = CreateGenericList(self.Frame, 2, false, true)
	self.QuestDescription = CreateGenericList(self.Frame, 5, false, true)
	self.QuestDescription:SetSpacing(1)

	self:PerformLayout()
end

function PANEL:LoadQuests(Quests)
	Quests = self.QuestTable or Quests
	self.QuestTable = Quests
	self.QuestList:Clear()
	for _, Quest in pairs(Quests) do
		local QuestTable = QuestTable(Quest)
		if not QuestTable.QuestNeeded or (QuestTable.QuestNeeded and LocalPlayer():HasCompletedQuest(QuestTable.QuestNeeded)) then
			local Quest = vgui.Create("FListItem")
			Quest:SetHeaderSize(20)
			Quest:SetFont("UiBold")
			Quest:SetNameText(QuestTable.PrintName)
			Quest:SetDescText("level " .. QuestTable.Level .. "+")
			Quest.DoClick = function() self:SellectQuest(Quest) end
			if LocalPlayer():CanAcceptQuest(Quest) then
				Quest:AddButton("gui/accept", "Accept Quest", function() RunConsoleCommand("UD_AcceptQuest", Quest) end)
			else
				if LocalPlayer():GetQuest(Quest) then
					if LocalPlayer():GetQuest(Quest).Done then
						Quest:SetDescText("Completed")
					else
						if LocalPlayer():CanTurnInQuest(Quest) then
							Quest:AddButton("gui/arrow_in", "Turn In Quest", function()
								RunConsoleCommand("UD_TurnInQuest", Quest)
								self:SellectQuest(Quest)
							end)
						else
							local TurnInButton = Quest:AddButton("gui/arrow_in", "Can't Turn In Quest", function() end)
							TurnInButton:SetAlpha(100)
						end
					end
				else
					Quest:SetAlpha(100)
				end
			end
			self.QuestList:AddItem(Quest)
		end
	end
end

function PANEL:SellectQuest(Quest)
	self.QuestDescription:Clear()
	local QuestTable = QuestTable(Quest)
	local PlayerQuestTable = LocalPlayer():GetQuest(Quest) or {}
	if not QuestTable or not PlayerQuestTable then return end
	self.QuestDescription:AddItem(CreateGenericLabel(nil, "MenuLarge", QuestTable.PrintName, White))
	self.QuestDescription:AddItem(CreateGenericLabel(nil, nil, QuestTable.Story, DrakGray))
	if PlayerQuestTable.Done and QuestTable.TurnInStory then
		self.QuestDescription:AddItem(CreateGenericLabel(nil, nil, QuestTable.TurnInStory, DrakGray))
	end
	for NPC, Amount in pairs(QuestTable.Kill or {}) do
		local NPCTable = NPCTable(NPC)
		local KillTable = PlayerQuestTable.Kills or {}
		local KillsGot = KillTable[NPC] or 0
		local Text = "Kill " .. math.Clamp(KillsGot, 0, Amount) .. "/" .. Amount .. " " .. NPCTable.PrintName
		if PlayerQuestTable.Done or KillsGot >= Amount then Text = Text .. " (Done)" end
		self.QuestDescription:AddItem(CreateGenericLabel(nil, nil, Text, DrakGray))
	end
	for Item, Amount in pairs(QuestTable.ObtainItems or {}) do
		local ItemTable = ItemTable(Item)
		local ItemsGot = LocalPlayer():GetItem(Item) or 0
		local Text = "Get " .. math.Clamp(ItemsGot, 0, Amount) .. "/" .. Amount .. " " .. ItemTable.PrintName
		if PlayerQuestTable.Done or ItemsGot >= Amount then Text = Text .. " (Done)" end
		self.QuestDescription:AddItem(CreateGenericLabel(nil, nil, Text, DrakGray))
	end
	self.QuestDescription:AddItem(CreateGenericLabel(nil, nil, "/n Rewards:", DrakGray))
	if QuestTable.GainedExp or 0 > 0 then
		self.QuestDescription:AddItem(CreateGenericLabel(nil, nil, QuestTable.GainedExp .. " Exp", DrakGray))
	end
	local ItemReward = nil
	for Item, Amount in pairs(QuestTable.GainedItems or {}) do
		if not ItemReward then
			ItemReward = CreateGenericList(nil, 1, true, false)
			ItemReward:SetTall(self.ItemIconSize + 2)
			ItemReward.Paint = function() end
			self.QuestDescription:AddItem(ItemReward)
		end
		local ItemTable = ItemTable(Item)
		local Item = vgui.Create("FIconItem")
		Item:SetSize(self.ItemIconSize, self.ItemIconSize)
		Item:SetItem(ItemTable, Amount, "")
		Item:SetDragable(false)
		ItemReward:AddItem(Item)
	end

	self.QuestDescription:InvalidateLayout()
end

function PANEL:PerformLayout()
	self.Frame:SetPos(self:GetPos())
	self.Frame:SetSize(self:GetSize())

	self.QuestList:SetPos(5, 25)
	self.QuestList:SetSize(self.Frame:GetWide() * 0.4, self.Frame:GetTall() - 30)
	self.QuestDescription:SetPos(self.QuestList:GetWide() + 10, 25)
	self.QuestDescription:SetSize(self.Frame:GetWide() - self.QuestList:GetWide() - 15, self.Frame:GetTall() - 30)
end
vgui.Register("questmenu", PANEL, "Panel")

concommand.Add("UD_OpenQuestMenu", function(ply, command, args)
	local npc = ply:GetEyeTrace().Entity
	local NPCTable = NPCTable(npc:GetNWing("npc"))
	if not IsValid(npc) or not NPCTable or not NPCTable.Quest then return end
	GAMEMODE.QuestMenu = GAMEMODE.QuestMenu or vgui.Create("questmenu")
	GAMEMODE.QuestMenu:SetSize(525, 320)
	GAMEMODE.QuestMenu:Center()
	GAMEMODE.QuestMenu:LoadQuests(NPCTable(args[1]).Quest)
end)