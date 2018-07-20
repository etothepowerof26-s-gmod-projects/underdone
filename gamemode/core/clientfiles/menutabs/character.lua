PANEL = {}
PANEL.HeaderHieght = 15
PANEL.ItemIconPadding = 1
PANEL.ItemIconSize = 39

function PANEL:Init()
	self.HeaderList = CreateGenericList(self, 1, true, false)
	self.SkillsList = CreateGenericList(self, self.ItemIconPadding, true, true)
	self.SkillsList.Tiers = {}
	self.MastersHeader = CreateGenericList(self, 1, true, false)
	self.MastersList = CreateGenericList(self, 2, false, false)
	self:LoadSkills()
	self:LoadMasters()
end

function PANEL:PerformLayout()
	self.HeaderList:SetPos(0, 0)
	self.HeaderList:SetSize(59 + (self.ItemIconSize * 6), self.HeaderHieght)
	self.SkillsList:SetPos(0, self.HeaderHieght + 5)
	self.SkillsList:SetSize(self.HeaderList:GetWide(), self:GetTall() - self.HeaderHieght - 5)
	for Tier, TierPanel in pairs(self.SkillsList.Tiers or {}) do
		TierPanel:SetSize(self.SkillsList:GetWide() - (self.ItemIconPadding * 2), self.ItemIconSize + (self.ItemIconPadding * 2))
		TierPanel.TierList:SetSize(TierPanel:GetWide() - 50, TierPanel:GetTall())
		TierPanel.TierList:SetPos(TierPanel:GetWide() - TierPanel.TierList:GetWide(), 0)
	end
	self.MastersHeader:SetPos(self.HeaderList:GetWide() + 5, 0)
	self.MastersHeader:SetSize(self:GetWide() - self.HeaderList:GetWide() - 5, self.HeaderHieght)
	self.MastersList:SetPos(self.HeaderList:GetWide() + 5, self.HeaderHieght + 5)
	self.MastersList:SetSize(self.MastersHeader:GetWide(), self:GetTall() - self.HeaderHieght - 5)
	for Master, MasterBar in pairs(self.MastersList.Masters or {}) do
		if MasterBar.TierUp then
			MasterBar.TierUp:SetPos(self.MastersList:GetWide() - 16 - 5, 2)
		end
	end
end

function PANEL:LoadSkills()
	self.SkillsList:Clear()
	self.SkillsList.Tiers = {}
	local AddTable = table.Copy(GAMEMODE.DataBase.Skills)
	AddTable = table.ClearKeys(AddTable)
	table.sort(AddTable, function(statA, statB) return statA.Tier < statB.Tier end)
	for _, SkillTable in pairs(AddTable) do
		local ExistingTierList = self.SkillsList.Tiers[SkillTable.Tier]
		if ExistingTierList then
			self:AddSkill(ExistingTierList, SkillTable.Name, SkillTable)
		else
			self:CreateNewTierList(self.SkillsList, SkillTable.SkillNeeded, SkillTable.Tier)
			self:AddSkill(self.SkillsList.Tiers[SkillTable.Tier], SkillTable.Name, SkillTable)
		end
	end
	--Since when did NWvars get slow :/
	timer.Simple(0.2, function() self:LoadHeader() end)
	self:PerformLayout()
end

function PANEL:CreateNewTierList(Parent, SkillNeeded, Tier)
	local NewTierPanel = vgui.Create("DPanel")
	NewTierPanel.Paint = function() end
	NewTierPanel.TierList = CreateGenericList(NewTierPanel, 1, true, false)
	NewTierPanel.TierList.Paint = function() end
	local TierText = vgui.Create("DLabel", NewTierPanel)
	TierText:SetFont("UiBold")
	TierText:SetColor(clrDrakGray)
	TierText:SetText("Tier " .. Tier .. "\nlv. " .. ((Tier - 1) * 5) .. "+")
	TierText:SizeToContents()
	TierText:SetPos(7, 8)
	if LocalPlayer():GetLevel() < ((Tier - 1) * 5) then
		NewTierPanel:SetAlpha(100)
	end
	Parent:AddItem(NewTierPanel)
	Parent.Tiers[Tier] = NewTierPanel
end

function PANEL:AddSkill(Parent, Skill, SkillTable)
	local SkillAmount = LocalPlayer():GetSkill(Skill)
	local Skill = vgui.Create("FIconItem")
	local SkillNeeded = SkillTable.SkillNeeded
	if SkillNeeded and LocalPlayer():GetSkill(SkillNeeded) == 0 then
		Skill:SetAlpha(100)
	end
	Skill:SetSize(self.ItemIconSize, self.ItemIconSize)
	Skill:SetSkill(SkillTable, SkillAmount)
	Parent.TierList:AddItem(Skill)
	return Skill
end

function PANEL:LoadMasters()
	self.MastersList:Clear()
	self.MastersList.Masters = {}
	for Name, MasterTable in pairs(table.Copy(GAMEMODE.DataBase.Masters)) do
		local MasterBar = vgui.Create("FPercentBar")
		local CurentLevel = LocalPlayer():GetMasterLevel(Name)
		local CurentExp =  LocalPlayer():GetMasterExp(Name) - toMasterExp(CurentLevel)
		local NextExp = toMasterExp(CurentLevel + 1) - toMasterExp(CurentLevel)
		MasterBar:SetTall(20)
		MasterBar:SetMax(NextExp - 1)
		MasterBar:SetValue(CurentExp)
		MasterBar:SetText(MasterTable.PrintName .. " Tier " .. CurentLevel)
		if LocalPlayer():GetMasterExp(Name) == LocalPlayer():GetMasterExpNextLevel(Name) - 1 then
			if LocalPlayer():GetTotalMasters() < GAMEMODE.MaxMaxtersTiers then
				MasterBar.TierUp = CreateGenericImageButton(MasterBar, "gui/arrow_up", "Tier Up", function()
					RunConsoleCommand("UD_BuyMasterLevel", Name)
				end)
			end
		end
		self.MastersList:AddItem(MasterBar)
		if MasterBar.TierUp then
			MasterBar.TierUp:SetPos(MasterBar:GetWide() - MasterBar.TierUp:GetWide() - 5, 2)
		end
		table.insert(self.MastersList.Masters, MasterBar)
	end
	self.MastersHeader:Clear()
	local Total = vgui.Create("DLabel")
	Total:SetFont("UiBold")
	Total:SetColor(clrDrakGray)
	Total:SetText("  Total Tiers " .. LocalPlayer():GetTotalMasters() .. "/" .. GAMEMODE.MaxMaxtersTiers)
	Total:SizeToContents()
	self.MastersHeader:AddItem(Total)
	self:PerformLayout()
end

function PANEL:LoadHeader()
	self.HeaderList:Clear()
	local SkillPoints = vgui.Create("DLabel")
	SkillPoints:SetFont("UiBold")
	SkillPoints:SetColor(clrDrakGray)
	SkillPoints:SetText("  Skill Points " .. LocalPlayer():GetNWInt("SkillPoints"))
	SkillPoints:SizeToContents()
	self.HeaderList:AddItem(SkillPoints)
end
vgui.Register("charactertab", PANEL, "Panel")