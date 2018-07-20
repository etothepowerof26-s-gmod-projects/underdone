-- This code is a mess but its basicly a dump for useful functions we cant live with out.
local Entity = FindMetaTable("Entity")
local Player = FindMetaTable("Player")

function toExp(Level)
	return math.floor(math.pow(math.max(0, tonumber(Level) or 0), 2))
end

function toLevel(Exp)
	return math.floor(math.Clamp(math.sqrt(tonumber(Exp) or 0) / 6, 1, Level))
end

function Entity:GetLevel()
	if self:IsPlayer() then
		return toLevel(self:GetNWInt("exp"))
	elseif self:IsNPC() then
		return self:GetNWInt("level")
	end
end

function Entity:CreateGrip()
	local Grip = ents.Create("prop_physics")
		Grip:SetModel("models/props_junk/cardboard_box004a.mdl")
		Grip:SetPos(self:GetPos())
		Grip:SetAngles(self:GetAngles())
		Grip:SetCollisionGroup(COLLISION_GROUP_WORLD)
		Grip:SetRenderMode(RENDERMODE_TRANSALPHA)
		Grip:SetColor(Color(0, 0, 0, 0))
	Grip:Spawn()
	self:SetParent(Grip)
	self.Grip = Grip
end

function GetPropClass(strModel)
	local EntClass = "prop_physics"
	if SERVER and strModel and not util.IsValidProp(strModel) then
		EntClass = "prop_dynamic"
	end
	return EntClass
end

function StringatizeVector(vec)
	local Vector_Table = {}
	Vector_Table[1] = math.Round(vec.x * 100) / 100
	Vector_Table[2] = math.Round(vec.y * 100) / 100
	Vector_Table[3] = math.Round(vec.z * 100) / 100
	return table.concat(Vector_Table, "!")
end

function VectortizeString(VectorString)
	local DecodeTable = string.Explode("!", VectorString)
	return Vector(DecodeTable[1] or 0, DecodeTable[2] or 0, DecodeTable[3] or 0)
end

function GetFlushToGround(entEntity)
	local Trace  = {}
	Trace.start  = entEntity:GetPos()
	Trace.endpos = entEntity:GetPos() + (entEntity:GetAngles():Up() * -500)
	Trace.filter = entEntity
	local NewTrace = util.TraceLine(Trace)

	local NewPosition = NewTrace.HitPos - (NewTrace.HitNormal * 512)
	NewPosition = entEntity:NearestPoint(NewPosition)
	NewPosition = entEntity:GetPos() - NewPosition
	NewPosition = NewTrace.HitPos + NewPosition
	return NewPosition
end

function Player:ApplyBuffTable(BuffTable, Multiplier)
	if not SERVER or not BuffTable then return end

	for Skill, Amount in pairs(BuffTable) do
		self:AddStat(Skill, Amount * (Multiplier or 1))
	end
end

function ColorCopy(ToCopy, Alpha)
	return Color(ToCopy.r, ToCopy.g, ToCopy.b, Alpha or ToCopy.a)
end

function GM:NotifyAll(Text)
	for _, ply in ipairs(player.GetAll()) do
		if not ply.CreateNotification then continue end
		
		ply:CreateNotification(Text)
	end
end

if SERVER then
	--SendUsrMsg -> SendNetworkMessage
	function SendNetworkMessage(Name, Target, Args) -- TODO: Replace with net ✓ 
		net.Start(Name)
		for _, value in pairs(Args or {}) do
			if (next(Args) == nil) then return end
		
			if type(value) == "string" then
				net.WriteString(value)
			elseif type(value) == "number" then
				net.WriteInt(value, 16)
			elseif type(value) == "boolean" then
				net.WriteBool(value)
			elseif IsEntity(value) then
				net.WriteEntity(value)
			elseif type(value) == "Vector" then
				net.WriteVector(value)
			elseif type(value) == "Angle" then
				net.WriteAngle(value)
			elseif type(value) == "table" then
				net.WriteString(util.TableToJSON(value))
			end
		end
		net.Send(Target)
	end

	local origin = Vector(0, 0, 0)
	function CreateWorldItem(Item, Amount, Position)
		local ItemTable = ItemTable(Item)
		if not ItemTable then return NULL end -- type correct

		local WorldProp = GAMEMODE:BuildModel(ItemTable.Model)
		if not IsValid(WorldProp) then return NULL end
			WorldProp.Item = Item
			WorldProp.Amount = Amount or 1
			WorldProp:SetPos(Position or origin)
		WorldProp:Spawn()

		WorldProp:SetNWString("PrintName", ItemTable.PrintName)
		WorldProp:SetNWInt("Amount", WorldProp.Amount)

		if not util.IsValidProp(WorldProp:GetModel()) then
			WorldProp:CreateGrip()
		end

		if not ItemTable.QuestItem then
			-- After 15 seconds the item can be picked up by anyone
			-- TODO: config?
			timer.Simple(15 ,function()
				if IsValid(WorldProp) then
					WorldProp:SetOwner(nil)
				end
			end)
		end

		-- Clean up if nobody wants it after a minute
		SafeRemoveEntityDelayed(WorldProp, 60) -- TODO: config?

		return WorldProp
	end

	function Entity:Stun(Time, Severity)
		if self.Resistance and self.Resistance == "Ice" then return end
		if self.UD_BeingSlowed then return end
		
		Time = Time or 3
		Severity = Severity or 0.1

		local TotalTime = 0
		local SlowRate = 0.1
		self.UD_originalColor = self.UD_originalColor or self:GetColor()

		timer.Create("UD_Stun" .. self:EntIndex(), SlowRate, 0, function()
			if not IsValid(self) then return end
			
			if TotalTime < Time then
				self:SetPlaybackRate(Severity)
				TotalTime = TotalTime + SlowRate
			else
				self:SetPlaybackRate(1)
				self.UD_BeingSlowed = false
				if self.UD_originalColor then
					self:SetColor(self.UD_originalColor)
					self.UD_originalColor = nil
				end
				timer.Remove("UD_Stun" .. self:EntIndex())
			end
		end)
		
		self:SetColor(Color(200, 200, 255, 255))
		self.UD_BeingSlowed = true
	end

	function Entity:IgniteFor(Time, Damage, Player)
		if self.Resistance and self.Resistance == "Fire" then return end
		if self.UD_BeingBurned then return end

		Time = Time or 3
		Damage = Damage or 1

		local TotalTime = 0
		local IgnitedRate = 0.35
		local startingHealth = self:Health()
		
		self.UD_originalColor = self.UD_originalColor or self:GetColor()
		
		timer.Create("UD_Burn", IgnitedRate, 0, function()
			if TotalTime < Time then
				if IsValid(Player) then
					Player:CreateIndicator(Damage, self:GetPos(), "red", true)
				end
				
				self:SetNWInt("Health", self:Health())
				self:Ignite(Time, 0) -- Used for the effect
				self:SetHealth(startingHealth - Damage) -- Starts taking damage
				TotalTime = TotalTime + IgnitedRate
			else
				self:Extinguish()
				self.UD_BeingBurned = false
				if self.UD_originalColor then
					self:SetColor(self.UD_originalColor)
					self.UD_originalColor = nil
				end
				timer.Remove("UD_Burn" .. self:EntIndex())
			end
		end)
		self:SetColor(Color(200, 0, 0, 255))
		self.UD_BeingBurned = true
	end

	function GM:RemoveAll(strClass, Time)
		table.foreach(ents.FindByClass(strClass .. "*"), function(_, ent) SafeRemoveEntityDelayed(ent, Time or 0) end)
	end
end

if CLIENT then
	function CreateGenericFrame(Title, Draggable, Close)
		local NewFrame = vgui.Create("DFrame")
		NewFrame:SetTitle(Title)
		NewFrame:SetDraggable(Draggable)
		NewFrame:ShowCloseButton(Close)

		if Close then
			NewFrame.Close:SetFont("Marlett")
			NewFrame.Close:SetText("r")
			NewFrame.Close:SetColor(Color(200, 200, 200, 255))
			NewFrame.Close.Paint = function() end

			NewFrame.Maxim:SetVisible(false)
			NewFrame.Minim:SetVisible(false)
		end

		local PaintPanel = jdraw.NewPanel()
		NewFrame.PaintPanel = PaintPanel
			PaintPanel:SetStyle(4, Tan)
			PaintPanel:SetBorder(1, DrakGray)

		local PaintPanel2 = jdraw.NewPanel()
		NewFrame.PaintPanel2 = PaintPanel2
			PaintPanel2:SetStyle(4, Gray)
			PaintPanel2:SetBorder(1, DrakGray)

		function NewFrame:Paint(w, h)
			self.PaintPanel:SetDimensions(0, 0, w, h)
			jdraw.DrawPanel(self.PaintPanel)

			self.PaintPanel2:SetDimensions(5, 5, w - 10, 15)
			jdraw.DrawPanel(self.PaintPanel2)
		end

		return NewFrame
	end

	function CreateGenericList(Parent, Spacing, HorizontalScrollEnabled, VerticalScrollEnabled)
		local NewList = vgui.Create("DPanelList", Parent)
		NewList:SetSpacing(Spacing)
		NewList:SetPadding(Spacing)
		NewList:EnableHorizontal(HorizontalScrollEnabled)
		NewList:EnableVerticalScrollbar(VerticalScrollEnabled)

		local PaintPanel = jdraw.NewPanel()
		NewList.PaintPanel = PaintPanel
			PaintPanel:SetStyle(4, Gray)
			PaintPanel:SetBorder(1, DrakGray)

		function NewList:Paint(w, h)
			self.PaintPanel:SetDimensions(0, 0, w, h)
			jdraw.DrawPanel(self.PaintPanel)
		end

		return NewList
	end

	function CreateGenericLabel(Parent, Font, Text, Color)
		local Label = vgui.Create("FMultiLabel", Parent)
		Label:SetFont(Font or "Default")
		Label:SetText(Text or "Default")
		Label:SetColor(Color or White)

		return Label
	end

	local weight_format = "Weight %d/%d"
	function CreateGenericWeightBar(Parent, Weight, MaxWeight)
		local WeightBar = vgui.Create("FPercentBar", Parent)
		WeightBar:SetMax(MaxWeight)
		WeightBar:SetValue(Weight)
		WeightBar:SetText(string.format(weight_format, Weight, MaxWeight))

		function WeightBar:Update(NewValue)
			NewValue = tonumber(NewValue) or 0

			WeightBar:SetValue(NewValue)
			WeightBar:SetText(string.format(weight_format, NewValue, self:GetMax()))
		end

		return WeightBar
	end

	function CreateGenericTabPanel(Parent)
		local TabSheet = vgui.Create("DPropertySheet", Parent)

		function TabSheet:Paint(w, h)
			jdraw.QuickDrawPanel(Tan, 0, 20, w, h - 20)
		end

		function TabSheet:NewTab(Name, PanelObject, Icon, Desc)
			local NewPanel = vgui.Create(PanelObject)
			local tab = self:AddSheet(Name, NewPanel, Icon, false, false, Desc).Tab

			function tab:Paint(w, h)
				local active = TabSheet:GetActiveTab() == self
				local BackColor = active and Tan or Gray

				if active then
					jdraw.QuickDrawPanel(BackColor, 0, 0, w, h - 6)
					draw.RoundedBox(0, 0, h - 8, w, 2, BackColor)
				else
					jdraw.QuickDrawPanel(BackColor, 0, 0, w, h + 2)
					draw.RoundedBox(0, 0, h - 4, w, 2, BackColor)
				end
			end

			return NewPanel
		end

		return TabSheet
	end

	function CreateGenericListItem(HeaderSize, NameText, Desc, Icon, Color, Expandable, Expanded)
		local NewListItem = vgui.Create("FListItem")
		NewListItem:SetHeaderSize(intHeaderSize)
		NewListItem:SetNameText(NameText)
		NewListItem:SetDescText(Desc)
		NewListItem:SetIcon(Icon)
		NewListItem:SetColor(Color)
		NewListItem:SetExpandable(Expandable)
		NewListItem:SetExpanded(Expanded)

		return NewListItem
	end

	function CreateGenericSlider(Parent, Text, Min, Max, Decimals, ConVar)
		local NewNumSlider = vgui.Create("DNumSlider", Parent)
		NewNumSlider:SetText(Text)
		NewNumSlider:SetMin(Min)
		NewNumSlider:SetMax(Max or Min)
		NewNumSlider:SetDecimals(Decimals or 0)
		NewNumSlider:SetConVar(ConVar)

		return NewNumSlider
	end

	function CreateGenericCheckbox(Parent, Text, ConVar)
		local NewCheckbox = vgui.Create("DCheckboxLabel", Parent)
		NewCheckbox:SetText(Text)
		NewCheckbox:SetConVar(ConVar)
		NewCheckbox:SizeToContents()

		return NewCheckbox
	end

	function CreateGenericImageButton(Parent, Image, ToolTip, Callback)
		local NewButton = vgui.Create("DImageButton", Parent)
		NewButton:SetImage(Image)
		NewButton:SetTooltip(ToolTip)
		NewButton:SizeToContents()
		NewButton.DoClick = Callback

		return NewButton
	end

	local shade = Color(0, 0, 0, 100)
	function CreateGenericButton(Parent, Text)
		local NewButton = vgui.Create("DButton", Parent)
		NewButton:SetText(Text)
		NewButton:SetTextColor(Color(200, 200, 200, 255))

		function NewButton:Paint(w, h)
			local DrawColor = Gray
			local GradDir = 1

			if self:GetDisabled() then
				DrawColor = ColorCopy(Gray, 100)
			elseif self.Depressed or self:IsDown() then
				GradDir = -1
			elseif NewButton.Hovered then
				-- TODO: maybe more visual feedback?
			end

			jdraw.QuickDrawPanel(DrawColor, 0, 0, w, h)
			jdraw.QuickDrawGrad(shade, 0, 0, w, h, GradDir)
		end

		return NewButton
	end

	function CreateGenericPanel(Parent, X, Y, Width, Hieght)
		local NewPanel = vgui.Create("DPanel", Parent)
		NewPanel:SetPos(X, Y)
		NewPanel:SetSize(Width, Hieght)

		function NewPanel:Paint(w, h)
			jdraw.QuickDrawPanel(Gray, 0, 0, w, h)
		end

		return NewPanel
	end

	function CreateGenericMultiChoice(Parent, Text, IsEditable)
		local NewMultiChoice = vgui.Create("DComboBox", Parent)
		NewMultiChoice:SetText(Text or "")
		NewMultiChoice:SetEnabled(IsEditable)

		return NewMultiChoice
	end

	function CreateGenericCollapse(Parent, Name, Spacing, HorizontalScrollEnabled)
		local NewCollapseCat = vgui.Create("DCollapsibleCategory", Parent)
		NewCollapseCat:SetLabel(Name)

		NewCollapseCat.List = vgui.Create("DPanelList")
		NewCollapseCat.List:SetAutoSize(true)
		NewCollapseCat.List:SetSpacing(Spacing)
		NewCollapseCat.List:SetPadding(Spacing)
		NewCollapseCat.List:EnableHorizontal(HorizontalScrollEnabled)
		NewCollapseCat:SetContents(NewCollapseCat.List)

		return NewCollapseCat
	end
end
