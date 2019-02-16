GM.QuestMenu = nil
PANEL = {}
PANEL.Frame = nil
PANEL.QuestList = nil
PANEL.QuestDescription = nil
PANEL.ItemIconSize = 39

function PANEL:Init()
	self.Frame = CreateGenericFrame("Quest Menu", false, true)
	self.Frame.InternalClose = self.Frame.Close
	self.Frame.Close = function()
		GAMEMODE.QuestMenu.Frame:InternalClose()
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
	for _, quest in pairs(Quests) do
		local QuestTable = QuestTable(quest)
		if not QuestTable.QuestNeeded or (QuestTable.QuestNeeded and LocalPlayer():HasCompletedQuest(QuestTable.QuestNeeded)) then
			local questbutton = vgui.Create("FListItem")
			questbutton:SetHeaderSize(20)
			questbutton:SetFont("UiBold")
			questbutton:SetNameText(QuestTable.PrintName)
			questbutton:SetDescText("Level " .. QuestTable.Level .. "+")
			questbutton.DoClick = function() self:SellectQuest(quest) end
			if LocalPlayer():CanAcceptQuest(quest) then
				questbutton:AddButton("gui/accept", "Accept Quest", function() RunConsoleCommand("UD_AcceptQuest", quest) end)
			else
				if LocalPlayer():GetQuest(quest) then
					if LocalPlayer():GetQuest(quest).Done then
						questbutton:SetDescText("Completed")
					else
						if LocalPlayer():CanTurnInQuest(quest) then
							questbutton:AddButton("gui/arrow_in", "Turn in quest", function()
								RunConsoleCommand("UD_TurnInQuest", quest)
								self:SellectQuest(quest)
							end)
						else
							local TurnInButton = questbutton:AddButton("gui/arrow_in", "Complete the quest first!", function() end)
							TurnInButton:SetAlpha(100)
						end
					end
				else
					questbutton:SetAlpha(100)
				end
			end
			self.QuestList:AddItem(questbutton)
		end
	end
end

function PANEL:SellectQuest(Quest)
	self.QuestDescription:Clear()
	local quest = QuestTable(Quest)
	local PlayerQuestTable = LocalPlayer():GetQuest(Quest) or {}
	if not quest or not PlayerQuestTable then return end
	self.QuestDescription:AddItem(CreateGenericLabel(nil, "MenuLarge", quest.PrintName, White))
	self.QuestDescription:AddItem(CreateGenericLabel(nil, nil, quest.Story, White))
	if PlayerQuestTable.Done and quest.TurnInStory then
		self.QuestDescription:AddItem(CreateGenericLabel(nil, nil, quest.TurnInStory, White))
	end
	for NPC, Amount in pairs(quest.Kill or {}) do
		local NPCTable = NPCTable(NPC)
		local KillTable = PlayerQuestTable.Kills or {}
		local KillsGot = KillTable[NPC] or 0
		local Text = "Kill " .. math.Clamp(KillsGot, 0, Amount) .. "/" .. Amount .. " " .. NPCTable.PrintName
		if PlayerQuestTable.Done or KillsGot >= Amount then Text = Text .. " (Done)" end
		self.QuestDescription:AddItem(CreateGenericLabel(nil, nil, Text, White))
	end
	for Item, Amount in pairs(quest.ObtainItems or {}) do
		local ItemTable = ItemTable(Item)
		local ItemsGot = LocalPlayer():GetItem(Item) or 0
		local Text = "Get " .. math.Clamp(ItemsGot, 0, Amount) .. "/" .. Amount .. " " .. ItemTable.PrintName
		if PlayerQuestTable.Done or ItemsGot >= Amount then Text = Text .. " (Done)" end
		self.QuestDescription:AddItem(CreateGenericLabel(nil, nil, Text, White))
	end
	self.QuestDescription:AddItem(CreateGenericLabel(nil, nil, "/n Rewards:", White))
	if quest.GainedExp or 0 > 0 then
		self.QuestDescription:AddItem(CreateGenericLabel(nil, nil, quest.GainedExp .. " Exp", White))
	end
	local ItemReward = nil
	for Item, Amount in pairs(quest.GainedItems or {}) do
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
	local npctab = NPCTable(npc:GetNWInt("npc"))
	if not IsValid(npc) or not npctab or not npctab.Quest then return end
	GAMEMODE.QuestMenu = GAMEMODE.QuestMenu or vgui.Create("questmenu")
	GAMEMODE.QuestMenu:SetSize(525, 320)
	GAMEMODE.QuestMenu:Center()
	GAMEMODE.QuestMenu:LoadQuests(NPCTable(args[1]).Quest)
end)