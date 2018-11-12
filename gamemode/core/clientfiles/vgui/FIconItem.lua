-- Polkm 2015 | Still, your code is bad! ~26
local PANEL = {}
local GlossIcon = Material("icons/icon_gloss")
local BorderIcon = Material("icons/icon_border2")
local GradiantDown = Material("gui/gradient_down")
PANEL.Icon = nil
PANEL.Text = nil
PANEL.LastClick = 0
PANEL.Draggable = false
PANEL.Item = nil
PANEL.Slot = nil
PANEL.UseCommand = nil
PANEL.LeftMouseDown = false
PANEL.DoClick = function() end
PANEL.DoRightClick = function() end
PANEL.DoDoubleClick = function() end
PANEL.DoDropedOn = function() end
PANEL.OnHover = function() end

function PANEL:Init()
	GAMEMODE:AddHoverObject(self)
	self.OnHover = function()
		surface.PlaySound("UI/buttonrollover.wav")
	end
end

function PANEL:OnMousePressed(mousecode)
	if mousecode == MOUSE_LEFT and self.Draggable then
		timer.Simple(0.1, function()
			if IsValid(self) and self.Draggable and input.IsMouseDown(MOUSE_LEFT) then
				GAMEMODE.DraggingPanel = self
			end
		end)
	end
end

function PANEL:OnMouseReleased(mousecode)
	if mousecode == MOUSE_RIGHT then
		self.DoRightClick()
		if GAMEMODE.DraggingPanel then
			GAMEMODE.DraggingPanel = nil
		end
	end
	if mousecode == MOUSE_LEFT then
		if GAMEMODE.DraggingPanel then
			if GAMEMODE.HoveredIcon then
				GAMEMODE.HoveredIcon.DoDropedOn()
			end
			GAMEMODE.DraggingPanel = nil
		else
			if (SysTime() - self.LastClick) < 0.3 then
				self.DoDoubleClick()
			else
				self.DoClick()
			end
		end
		self.LastClick = SysTime()
	end
end

function PANEL:Paint(w, h)
	local DrawTexture = self.Icon or GradiantDown
	surface.SetDrawColor(0, 0, 0, 50)
	if DrawTexture == self.Icon then
		surface.SetDrawColor(self.Color or Color(255, 255, 255, 255))
	end
	surface.SetMaterial(DrawTexture)
	surface.DrawTexturedRect(0, 0, w, h)
	if DrawTexture == self.Icon then
		surface.SetDrawColor(255, 255, 255, 70)
		surface.SetMaterial(GlossIcon)
		surface.DrawTexturedRect(0, 0, w, h)
	end
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(BorderIcon)
	surface.DrawTexturedRect(0, 0, w, h)

	if self.Text then
		if tonumber(self.Text) and tonumber(self.Text) >= 1000  then
			local Amount = math.Round(tonumber(self.Text) / 1000)
			local Prefix = "K"
			if Amount > 1000 then
				Amount = math.Round(tonumber(self.Text) / 1000000)
				Prefix = "M"
			end
			self.Text = Amount .. "" .. Prefix
		end
		surface.SetFont("DefaultFixedOutline")
		local width, tall = surface.GetTextSize(tostring(self.Text))
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetTextPos(w - width - 2, h - tall - 1)
		surface.DrawText(tostring(self.Text))
	end

	-- spawnicon hover effect
	self.OverlayFade = math.Clamp((self.OverlayFade or 0) - RealFrameTime() * 640 * 2, 0, 255)
	if dragndrop.IsDragging() or not self:IsHovered() then return end
	self.OverlayFade = math.Clamp(self.OverlayFade + RealFrameTime() * 640 * 8, 0, 255)

	return true
end

do -- spawnicon hover effect
	local border = 4
	local border_w = 5
	local matHover = Material("gui/sm_hover.png", "nocull")
	local boxHover = GWEN.CreateTextureBorder(border, border, 64 - border * 2, 64 - border * 2, border_w, border_w, border_w, border_w, matHover)

	function PANEL:PaintOver(w, h)
		if self.OverlayFade > 0 then
			boxHover(0, 0, w, h, Color(255, 255, 255, self.OverlayFade))
		end
	end
end

function PANEL:SetIcon(IconText)
	self.Icon = IconText and Material(IconText)
end

function PANEL:SetText(Text)
	self.Text = Text
end

function PANEL:SetDragable(Draggable)
	self.Draggable = Draggable
end

function PANEL:SetRightClick(RightClick)
	self.DoRightClick = RightClick
end

function PANEL:SetDoubleClick(DoubleClick)
	self.DoDoubleClick = DoubleClick
end

function PANEL:SetDropedOn(DropedOn)
	self.DoDropedOn = DropedOn
end

function PANEL:SetColor(Color)
	self.Color = Color
end

function PANEL:SetItem(ItemTable, Amount, UseCommand, Cost)
	if not ItemTable then
		self:SetIcon(nil)
		self:SetText(Amount or nil)
		self:SetDragable(false)
		self:SetRightClick(function() end)
		self:SetDoubleClick(function() end)
		self:SetTooltip(nil)
		return
	end
	Cost = Cost or 0
	UseCommand = UseCommand or "use"
	self.UseCommand = UseCommand
	Amount = Amount or 1
	self:SetDragable(true)
	if ItemTable.Icon then self:SetIcon(ItemTable.Icon) end
	if ItemTable.Stackable and Amount > 1 then self:SetText(Amount) end
	if ItemTable.Name then self.Item = ItemTable.Name end
	if ItemTable.Slot then self.Slot = ItemTable.Slot end
	if UseCommand == "use" and ItemTable.Dropable then
		self.DoDropItem = function()
			self:RunPromptAmount(ItemTable, Amount, "How many to drop", "UD_DropItem")
		end
	end
	if UseCommand == "use" and ItemTable.Giveable then
		self.DoGiveItem = function(plyGivePlayer)
			if ItemTable.Stackable or Amount >= 5 then
				GAMEMODE:DisplayPrompt("number", "How many to give", function(itemamount)
					RunConsoleCommand("UD_GiveItem", ItemTable.Name, itemamount, plyGivePlayer:EntIndex())
				end, Amount)
			else
				RunConsoleCommand("UD_GiveItem", ItemTable.Name, 1, plyGivePlayer:EntIndex())
			end
		end
	end
	if UseCommand == "use" and ItemTable.Use then
		self.DoUseItem = function() RunConsoleCommand("UD_UseItem", ItemTable.Name) end
	end
	if UseCommand == "buy" then
		self.DoUseItem = function() RunConsoleCommand("UD_BuyItem", ItemTable.Name) end
	end
	if UseCommand == "sell" then
		self.DoUseItem = function(AmountToSell)
			self:RunPromptAmount(ItemTable, Amount, "How many to sell", "UD_SellItem", AmountToSell)
		end
	end
	if UseCommand == "deposit" then
		self.DoUseItem = function(AmountToDeposit)
			self:RunPromptAmount(ItemTable, Amount, "How many to deposit", "UD_DepositItem", AmountToDeposit)
		end
	end
	if UseCommand == "withdraw" then
		self.DoUseItem = function(AmountToWithdraw)
			self:RunPromptAmount(ItemTable, Amount, "How many to withdraw", "UD_WithdrawItem", AmountToWithdraw)
		end
	end
	---------ToolTip---------
	local Tooltip = Format("%s", ItemTable.PrintName)
	if Amount and Amount >= 1000 then Tooltip = Format("%s (x%s)", Tooltip, Amount) end
	if ItemTable.Level and ItemTable.Level > 1 then Tooltip = Format("%s (lv. %s)", Tooltip, ItemTable.Level) end
	if ItemTable.Level and ItemTable.Level > LocalPlayer():GetLevel() then self:SetColor(Red) end
	if ItemTable.Weight and ItemTable.Weight > 0 then Tooltip = Format("%s (%s Kgs)", Tooltip, ItemTable.Weight) end
	if ItemTable.Desc then Tooltip = Format("%s\n%s", Tooltip, ItemTable.Desc) end
	if ItemTable.Power then Tooltip = Format("%s\nDamage: %s", Tooltip, ItemTable.Power) end
	if ItemTable.NumOfBullets and ItemTable.NumOfBullets > 1 then Tooltip = Format("%sx%s", Tooltip, ItemTable.NumOfBullets) end
	if ItemTable.FireRate then Tooltip = Format("%s (%s)", Tooltip, ItemTable.Power * ItemTable.NumOfBullets * ItemTable.FireRate) end
	if ItemTable.FireRate then Tooltip = Format("%s\nSpeed: %s", Tooltip, ItemTable.FireRate) end
	if ItemTable.ClipSize and ItemTable.ClipSize >= 0 then Tooltip = Format("%s\nClipsize: %s", Tooltip, ItemTable.ClipSize) end
	if ItemTable.Slot and ItemTable.Slot ~= "slot_primaryweapon" then Tooltip = Format("%s\nSlot: %s", Tooltip, SlotTable(ItemTable.Slot).PrintName) end
	if ItemTable.Armor then Tooltip = Format("%s\nArmor: %s", Tooltip, ItemTable.Armor) end
	for Stat, Amount in pairs(ItemTable.Buffs or {}) do
		local StatTable = StatTable(Stat)
		Tooltip = Format("%s\n+%s %s", Tooltip, Amount, StatTable.PrintName)
	end
	local SetTable = EquipmentSetTable(ItemTable.Set) or {}
	if SetTable.Items then
		Tooltip = Format("%s\n\nSet: %s", Tooltip, SetTable.PrintName)
	end
	for _, Item in pairs(SetTable.Items or {}) do
		local ItemTable = ItemTable(Item)
		local Wearing = LocalPlayer():GetSlot(ItemTable.Slot) == ItemTable.Name
		if Wearing then Wearing = 1 end
		if not Wearing then Wearing = 0 end
		Tooltip = Format("%s\n%s/%s %s", Tooltip, tonumber(Wearing), 1, ItemTable.PrintName)
	end
	for Stat, Amount in pairs(SetTable.Buffs or {}) do
		local StatTable = StatTable(Stat)
		Tooltip = Format("%s\n+%s %s", Tooltip, Amount, StatTable.PrintName)
	end

	if UseCommand == "buy" and Cost > 0 then Tooltip = Format("%s\n\nBuy For $%s", Tooltip, Cost) end
	if UseCommand == "sell" and Cost > 0 then Tooltip = Format("%s\n\nSell For $%s", Tooltip, Cost) end
	self:SetTooltip(Tooltip)
	------Double Click------
	if self.DoUseItem then self:SetDoubleClick(self.DoUseItem) end
	-------Right Click-------
	local menuFunc = function()
		GAMEMODE.ActiveMenu = nil
		GAMEMODE.ActiveMenu = DermaMenu()
		if UseCommand == "use" and ItemTable.Use and self.DoUseItem then GAMEMODE.ActiveMenu:AddOption("Use", function() self.DoUseItem() end) end
		if UseCommand == "buy" and self.DoUseItem then GAMEMODE.ActiveMenu:AddOption("Buy", function() self.DoUseItem() end) end
		if UseCommand == "sell" and Cost > 0 and self.DoUseItem then GAMEMODE.ActiveMenu:AddOption("Sell", function() self.DoUseItem() end) end
		if UseCommand == "sell" and Cost > 0 and Amount > 1 then GAMEMODE.ActiveMenu:AddOption("Sell All", function() self.DoUseItem(Amount) end) end
		if UseCommand == "deposit" and self.DoUseItem then GAMEMODE.ActiveMenu:AddOption("Deposit", function() self.DoUseItem() end) end
		if UseCommand == "withdraw" and self.DoUseItem then GAMEMODE.ActiveMenu:AddOption("Withdraw", function() self.DoUseItem() end) end
		if UseCommand == "use" and ItemTable.Dropable then GAMEMODE.ActiveMenu:AddOption("Drop", function() self.DoDropItem() end) end
		if UseCommand == "use" and ItemTable.Giveable and player.GetCount() > 1 then
			local GiveSubMenu = nil
			for _, player in ipairs(player.GetAll()) do
				if player:GetPos():DistToSqr(LocalPlayer():GetPos()) < 62500 and player ~= LocalPlayer() then
					GiveSubMenu = GiveSubMenu or GAMEMODE.ActiveMenu:AddSubMenu("Give ...")
					GiveSubMenu:AddOption(player:Nick(), function() self.DoGiveItem(player) end)
				end
			end
		end
		GAMEMODE.ActiveMenu:Open()
	end
	self:SetRightClick(menuFunc)
end

function PANEL:RunPromptAmount(ItemTable, Amount, Question, Command, CallAmount)
	if (Amount >= 5) and not CallAmount then
		GAMEMODE:DisplayPrompt("number", Question, function(ItemAmount)
			RunConsoleCommand(Command, ItemTable.Name, ItemAmount)
		end, Amount)
	else
		RunConsoleCommand(Command, ItemTable.Name, CallAmount or 1)
	end
end

function PANEL:SetSlot(SlotTable)
	local Tooltip = ""
	if SlotTable then
		if SlotTable.PrintName then Tooltip = Format("%s", SlotTable.PrintName) end
		if SlotTable.Desc then Tooltip = Format("%s\n%s", Tooltip, SlotTable.Desc) end
	end
	self.IsPaperDollSlot = true
	self:SetDragable(false)
	self:SetIcon(nil)
	self:SetTooltip(Tooltip)
	self:SetDropedOn(function()
		if GAMEMODE.DraggingPanel and GAMEMODE.DraggingPanel.Slot and GAMEMODE.DraggingPanel.Slot == SlotTable.Name then
			if GAMEMODE.DraggingPanel.Item and LocalPlayer().Data.Paperdoll[SlotTable.Name] ~= GAMEMODE.DraggingPanel.Item then
				GAMEMODE.DraggingPanel.DoDoubleClick()
			end
		end
	end)
	self:SetDoubleClick(function() end)
	self:SetRightClick(function() end)
end

function PANEL:SetSkill(SkillTable, SkillLevel)
	if not SkillTable then return false end
	local Tooltip = ""
	if SkillTable.PrintName then Tooltip = Format("%s", SkillTable.PrintName) end
	if SkillTable.Desc["SkillNeeded"] then Tooltip = Format("%s\n%s", Tooltip, "Skill Needed: " .. SkillTable.Desc["SkillNeeded"]) end
	if SkillTable.Desc["story"] then Tooltip = Format("%s\n%s", Tooltip, SkillTable.Desc["story"]) end
	if SkillTable.Desc[SkillLevel] then Tooltip = Format("%s\n%s", Tooltip, SkillTable.Desc[SkillLevel]) end
	if SkillTable.Desc[SkillLevel + 1] and SkillTable.Desc[SkillLevel] then Tooltip = Format("%s\n\n%s", Tooltip, "Next Level") end
	if SkillTable.Desc[SkillLevel + 1] then Tooltip = Format("%s\n%s", Tooltip, SkillTable.Desc[SkillLevel + 1]) end
	self:SetTooltip(Tooltip)
	self:SetIcon(SkillTable.Icon or nil)
	self:SetText((SkillLevel or 0) .. "/" .. SkillTable.Levels)
	self:SetDragable(false)

	self:SetDoubleClick(function() RunConsoleCommand("UD_BuySkill", SkillTable.Name) end)
end
vgui.Register("FIconItem", PANEL, "Panel")
