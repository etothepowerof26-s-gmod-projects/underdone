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
	for intTier, pnlTierPanel in pairs(self.SkillsList.Tiers or {}) do
		pnlTierPanel:SetSize(self.SkillsList:GetWide() - (self.ItemIconPadding * 2), self.ItemIconSize + (self.ItemIconPadding * 2))
		pnlTierPanel.TierList:SetSize(pnlTierPanel:GetWide() - 50, pnlTierPanel:GetTall())
		pnlTierPanel.TierList:SetPos(pnlTierPanel:GetWide() - pnlTierPanel.TierList:GetWide(), 0)
	end
	self.MastersHeader:SetPos(self.HeaderList:GetWide() + 5, 0)
	self.MastersHeader:SetSize(self:GetWide() - self.HeaderList:GetWide() - 5, self.HeaderHieght)
	self.MastersList:SetPos(self.HeaderList:GetWide() + 5, self.HeaderHieght + 5)
	self.MastersList:SetSize(self.MastersHeader:GetWide(), self:GetTall() - self.HeaderHieght - 5)
	for intMaster, pgbMasterBar in pairs(self.MastersList.Masters or {}) do
		if pgbMasterBar.TierUp then
			pgbMasterBar.TierUp:SetPos(self.MastersList:GetWide() - 16 - 5, 2)
		end
	end
end

function PANEL:LoadSkills()
	self.SkillsList:Clear()
	self.SkillsList.Tiers = {}
	local tblAddTable = table.Copy(GAMEMODE.DataBase.Skills)
	tblAddTable = table.ClearKeys(tblAddTable)
	table.sort(tblAddTable, function(statA, statB) return statA.Tier < statB.Tier end)
	for _, tblSkillTable in pairs(tblAddTable) do
		local pnlExistingTierList = self.SkillsList.Tiers[tblSkillTable.Tier]
		if pnlExistingTierList then
			self:AddSkill(pnlExistingTierList, tblSkillTable.Name, tblSkillTable)
		else
			self:CreateNewTierList(self.SkillsList, tblSkillTable.SkillNeeded, tblSkillTable.Tier)
			self:AddSkill(self.SkillsList.Tiers[tblSkillTable.Tier], tblSkillTable.Name, tblSkillTable)
		end
	end
	--Since when did NWvars get slow :/
	timer.Simple(0.2, function() self:LoadHeader() end)
	self:PerformLayout()
end

function PANEL:CreateNewTierList(pnlParent, intSkillNeeded, intTier)
	local pnlNewTierPanel = vgui.Create("DPanel")
	pnlNewTierPanel.Paint = function() end
	pnlNewTierPanel.TierList = CreateGenericList(pnlNewTierPanel, 1, true, false)
	pnlNewTierPanel.TierList.Paint = function() end
	local lblTierText = vgui.Create("DLabel", pnlNewTierPanel)
	lblTierText:SetFont("UiBold")
	lblTierText:SetColor(clrDrakGray)
	lblTierText:SetText("Tier " .. intTier .. "\nlv. " .. ((intTier - 1) * 5) .. "+")
	lblTierText:SizeToContents()
	lblTierText:SetPos(7, 8)
	if LocalPlayer():GetLevel() < ((intTier - 1) * 5) then
		pnlNewTierPanel:SetAlpha(100)
	end
	pnlParent:AddItem(pnlNewTierPanel)
	pnlParent.Tiers[intTier] = pnlNewTierPanel
end

function PANEL:AddSkill(pnlParent, strSkill, tblSkillTable)
	local intSkillAmount = LocalPlayer():GetSkill(strSkill)
	local icnSkill = vgui.Create("FIconItem")
	local SkillNeeded = tblSkillTable.SkillNeeded
	if SkillNeeded and LocalPlayer():GetSkill(SkillNeeded) == 0 then
		icnSkill:SetAlpha(100)
	end
	icnSkill:SetSize(self.ItemIconSize, self.ItemIconSize)
	icnSkill:SetSkill(tblSkillTable, intSkillAmount)
	pnlParent.TierList:AddItem(icnSkill)
	return icnSkill
end

function PANEL:LoadMasters()
	self.MastersList:Clear()
	self.MastersList.Masters = {}
	for strName, tblMasterTable in pairs(table.Copy(GAMEMODE.DataBase.Masters)) do
		local pgbMasterBar = vgui.Create("FPercentBar")
		local intCurentLevel = LocalPlayer():GetMasterLevel(strName)
		local intCurentExp =  LocalPlayer():GetMasterExp(strName) - toMasterExp(intCurentLevel)
		local intNextExp = toMasterExp(intCurentLevel + 1) - toMasterExp(intCurentLevel)
		pgbMasterBar:SetTall(20)
		pgbMasterBar:SetMax(intNextExp - 1)
		pgbMasterBar:SetValue(intCurentExp)
		pgbMasterBar:SetText(tblMasterTable.PrintName .. " Tier " .. intCurentLevel)
		if LocalPlayer():GetMasterExp(strName) == LocalPlayer():GetMasterExpNextLevel(strName) - 1 then
			if LocalPlayer():GetTotalMasters() < GAMEMODE.MaxMaxtersTiers then
				pgbMasterBar.TierUp = CreateGenericImageButton(pgbMasterBar, "gui/arrow_up", "Tier Up", function()
					RunConsoleCommand("UD_BuyMasterLevel", strName)
				end)
			end
		end
		self.MastersList:AddItem(pgbMasterBar)
		if pgbMasterBar.TierUp then
			pgbMasterBar.TierUp:SetPos(pgbMasterBar:GetWide() - pgbMasterBar.TierUp:GetWide() - 5, 2)
		end
		table.insert(self.MastersList.Masters, pgbMasterBar)
	end
	self.MastersHeader:Clear()
	local lblTotal = vgui.Create("DLabel")
	lblTotal:SetFont("UiBold")
	lblTotal:SetColor(clrDrakGray)
	lblTotal:SetText("  Total Tiers " .. LocalPlayer():GetTotalMasters() .. "/" .. GAMEMODE.MaxMaxtersTiers)
	lblTotal:SizeToContents()
	self.MastersHeader:AddItem(lblTotal)
	self:PerformLayout()
end

function PANEL:LoadHeader()
	self.HeaderList:Clear()
	local lblSkillPoints = vgui.Create("DLabel")
	lblSkillPoints:SetFont("UiBold")
	lblSkillPoints:SetColor(clrDrakGray)
	lblSkillPoints:SetText("  Skill Points " .. LocalPlayer():GetNWInt("SkillPoints"))
	lblSkillPoints:SizeToContents()
	self.HeaderList:AddItem(lblSkillPoints)
end
vgui.Register("charactertab", PANEL, "Panel")