-- This code is a mess but its basicly a dump for useful functions we cant live with out.
local Entity = FindMetaTable("Entity")
local Player = FindMetaTable("Player")

function toExp(intLevel)
	local intExp = math.max(0, tonumber(intLevel) or 0)

	intExp = intExp * 6
	intExp = math.pow(intExp, 2)
	intExp = math.floor(intExp)
	return tonumber(intExp)
end

function toLevel(intExp)
	local intLevel = math.sqrt(tonumber(intExp) or 0)

	intLevel = intLevel / 6
	intLevel = math.Clamp(intLevel, 1, intLevel)
	intLevel = math.floor(intLevel)
	return tonumber(intLevel)
end

function Entity:GetLevel()
	if self:IsPlayer() then
		return toLevel(self:GetNWInt("exp"))
	elseif self:IsNPC() then
		return self:GetNWInt("level")
	end
end

function Entity:CreateGrip()
	local entGrip = ents.Create("prop_physics")
		entGrip:SetModel("models/props_junk/cardboard_box004a.mdl")
		entGrip:SetPos(self:GetPos())
		entGrip:SetAngles(self:GetAngles())
		entGrip:SetCollisionGroup(COLLISION_GROUP_WORLD)
		entGrip:SetRenderMode(RENDERMODE_TRANSALPHA)
		entGrip:SetColor(Color(0, 0, 0, 0))
	entGrip:Spawn()
	self:SetParent(entGrip)
	self.Grip = entGrip
end

function GetPropClass(strModel)
	local strEntType = "prop_physics"
	if SERVER and strModel and not util.IsValidProp(strModel) then strEntType = "prop_dynamic" end
	return strEntType
end

function StringatizeVector(vecVector)
	local tblVector = {}
	tblVector[1] = math.Round(vecVector.x * 100) / 100
	tblVector[2] = math.Round(vecVector.y * 100) / 100
	tblVector[3] = math.Round(vecVector.z * 100) / 100
	return table.concat(tblVector, "!")
end

function VectortizeString(strVectorString)
	local tblDecodeTable = string.Explode("!", strVectorString)
	return Vector(tblDecodeTable[1] or 0, tblDecodeTable[2] or 0, tblDecodeTable[3] or 0)
end

function GetFlushToGround(entEntity)
	local tblTrace  = {}
	tblTrace.start  = entEntity:GetPos()
	tblTrace.endpos = entEntity:GetPos() + (entEntity:GetAngles():Up() * -500)
	tblTrace.filter = entEntity
	local trcNewTrace = util.TraceLine(tblTrace)

	local vecNewPostion = trcNewTrace.HitPos - (trcNewTrace.HitNormal * 512)
	vecNewPostion = entEntity:NearestPoint(vecNewPostion)
	vecNewPostion = entEntity:GetPos() - vecNewPostion
	vecNewPostion = trcNewTrace.HitPos + vecNewPostion
	return vecNewPostion
end

function Player:ApplyBuffTable(tblBuffTable, intMultiplier)
	if not SERVER or not tblBuffTable then return end

	for strSkill, intAmount in pairs(tblBuffTable) do
		self:AddStat(strSkill, intAmount * (intMultiplier or 1))
	end
end

function ColorCopy(clrToCopy, intAlpha)
	return Color(clrToCopy.r, clrToCopy.g, clrToCopy.b, intAlpha or clrToCopy.a)
end

function GM:NotifyAll(strText)
	for _, ply in ipairs(player.GetAll()) do
		ply:CreateNotification(strText)
	end
end

if SERVER then
	function SendUsrMsg(strName, plyTarget, tblArgs) -- TODO: Replace with net
		umsg.Start(strName, plyTarget)
		for _, value in pairs(tblArgs or {}) do
			if type(value) == "string" then umsg.String(value)
			elseif type(value) == "number" then umsg.Long(value)
			elseif type(value) == "boolean" then umsg.Bool(value)
			elseif type(value) == "Entity" or type(value) == "Player" then umsg.Entity(value)
			elseif type(value) == "Vector" then umsg.Vector(value)
			elseif type(value) == "Angle" then umsg.Angle(value)
			elseif type(value) == "table" then umsg.String(util.TableToJSON(value)) end
		end
		umsg.End()
	end

	local origin = Vector(0, 0, 0)
	function CreateWorldItem(strItem, intAmount, vecPostion)
		local tblItemTable = ItemTable(strItem)
		if not tblItemTable then return NULL end -- type correct

		local entWorldProp = GAMEMODE:BuildModel(tblItemTable.Model)
		if not IsValid(entWorldProp) then return NULL end
			entWorldProp.Item = strItem
			entWorldProp.Amount = intAmount or 1
			entWorldProp:SetPos(vecPostion or origin)
		entWorldProp:Spawn()

		entWorldProp:SetNWString("PrintName", tblItemTable.PrintName)
		entWorldProp:SetNWInt("Amount", entWorldProp.Amount)

		if not util.IsValidProp(entWorldProp:GetModel()) then
			entWorldProp:CreateGrip()
		end

		if not tblItemTable.QuestItem then
			-- After 15 seconds the item can be picked up by anyone
			-- TODO: config?
			timer.Simple(15 ,function()
				if IsValid(entWorldProp) then
					entWorldProp:SetOwner(nil)
				end
			end)
		end

		-- Clean up if nobody wants it after a minute
		SafeRemoveEntityDelayed(entWorldProp, 60) -- TODO: config?

		return entWorldProp
	end

	function Entity:Stun(intTime, intSeverity)
		if self.Resistance and self.Resistance == "Ice" then return end
		if self.UD_BeingSlowed then return end

		intTime = intTime or 3
		intSeverity = intSeverity or 0.1

		local intTotalTime = 0
		local intSlowRate = 0.1
		self.UD_originalColor = self.UD_originalColor or self:GetColor()

		local function _statusEffect()
			if not IsValid(self) then return end

			if intTotalTime < intTime then
				self:SetPlaybackRate(intSeverity)

				intTotalTime = intTotalTime + intSlowRate
				timer.Create("UD_Stun" .. self:EntIndex(), intSlowRate, 1, _statusEffect)
			else
				self:SetPlaybackRate(1)
				self.UD_BeingSlowed = false

				if self.UD_originalColor then
					self:SetColor(self.UD_originalColor)
					self.UD_originalColor = nil
				end
			end
		end

		self:SetColor(Color(200, 200, 255, 255))
		self.UD_BeingSlowed = true
		_statusEffect()
	end

	function Entity:IgniteFor(intTime, intDamage, plyPlayer)
		if self.Resistance and self.Resistance == "Fire" then return end
		if self.UD_BeingBurned then return end

		intTime = intTime or 3
		intDamage = intDamage or 1

		local intTotalTime = 0
		local intIgnitedRate = 0.35
		self.UD_originalColor = self.UD_originalColor or self:GetColor()

		local function _statusEffect()
			if not IsValid(self) then return end

			if intTotalTime < intTime then
				if IsValid(plyPlayer) then
					plyPlayer:CreateIndicator(intDamage, self:GetPos(), "red", true)
				end

				local startingHealth = self:Health() -- Hacky way around self:Ignite dropping npc down to 40 health
				self:SetNWInt("Health", self:Health())
				self:Ignite(intTime, 0) -- Used for the effect
				self:SetHealth(startingHealth - intDamage) -- Starts taking damage

				intTotalTime = intTotalTime + intIgnitedRate
				timer.Create("UD_Burn" .. self:EntIndex(), intIgnitedRate, 1, _statusEffect)
			else
				self:Extinguish()
				self.UD_BeingBurned = false

				if self.UD_originalColor then
					self:SetColor(self.UD_originalColor)
					self.UD_originalColor = nil
				end
			end
		end

		self:SetColor(Color(200, 0, 0, 255))
		self.UD_BeingBurned = true
		_statusEffect()
	end

	function GM:RemoveAll(strClass, intTime)
		table.foreach(ents.FindByClass(strClass .. "*"), function(_, ent) SafeRemoveEntityDelayed(ent, intTime or 0) end)
	end
end

if CLIENT then
	function CreateGenericFrame(strTitle, boolDrag, boolClose)
		local frmNewFrame = vgui.Create("DFrame")
		frmNewFrame:SetTitle(strTitle)
		frmNewFrame:SetDraggable(boolDrag)
		frmNewFrame:ShowCloseButton(boolClose)

		if boolClose then
			frmNewFrame.btnClose:SetFont("Marlett")
			frmNewFrame.btnClose:SetText("r")
			frmNewFrame.btnClose.Paint = function() end

			frmNewFrame.btnMaxim:SetFont("Marlett")
			frmNewFrame.btnMaxim:SetText("1")
			frmNewFrame.btnMaxim.Paint = function() end

			frmNewFrame.btnMinim:SetFont("Marlett")
			frmNewFrame.btnMinim:SetText("0")
			frmNewFrame.btnMinim.Paint = function() end
		end

		local tblPaintPanel = jdraw.NewPanel()
		frmNewFrame.tblPaintPanel = tblPaintPanel
			tblPaintPanel:SetStyle(4, clrTan)
			tblPaintPanel:SetBorder(1, clrDrakGray)

		local tblPaintPanel2 = jdraw.NewPanel()
		frmNewFrame.tblPaintPanel2 = tblPaintPanel2
			tblPaintPanel:SetStyle(4, clrGray)
			tblPaintPanel:SetBorder(1, clrDrakGray)

		function frmNewFrame:Paint(w, h)
				self.tblPaintPanel:SetDimensions(0, 0, w, h)
			jdraw.DrawPanel(self.tblPaintPanel)

				self.tblPaintPanel:SetDimensions(5, 5, w - 10, 15)
			jdraw.DrawPanel(self.tblPaintPanel2)
		end

		return frmNewFrame
	end

	function CreateGenericList(pnlParent, intSpacing, boolHorz, boolScrollz)
		local pnlNewList = vgui.Create("DPanelList", pnlParent)
		pnlNewList:SetSpacing(intSpacing)
		pnlNewList:SetPadding(intSpacing)
		pnlNewList:EnableHorizontal(boolHorz)
		pnlNewList:EnableVerticalScrollbar(boolScrollz)

		local tblPaintPanel = jdraw.NewPanel()
		frmNewFrame.tblPaintPanel = tblPaintPanel
			tblPaintPanel:SetStyle(4, clrGray)
			tblPaintPanel:SetBorder(1, clrDrakGray)

		function pnlNewList:Paint(w, h)
				self.tblPaintPanel:SetDimensions(0, 0, w, h)
			jdraw.DrawPanel(self.tblPaintPanel)
		end

		return pnlNewList
	end

	function CreateGenericLabel(pnlParent, strFont, strText, clrColor)
		local lblNewLabel = vgui.Create("FMultiLabel", pnlParent)
		lblNewLabel:SetFont(strFont or "Default")
		lblNewLabel:SetText(strText or "Default")
		lblNewLabel:SetColor(clrColor or clrWhite)

		return lblNewLabel
	end

	local weight_format = "Weight %d/%d"
	function CreateGenericWeightBar(pnlParent, intWeight, intMaxWeight)
		local fpbWeightBar = vgui.Create("FPercentBar", pnlParent)
		fpbWeightBar:SetMax(intMaxWeight)
		fpbWeightBar:SetValue(intWeight)
		fpbWeightBar:SetText(string.format(weight_format, intWeight, intMaxWeight))

		function fpbWeightBar:Update(intNewValue)
			intNewValue = tonumber(intNewValue) or 0

			fpbWeightBar:SetValue(intNewValue)
			fpbWeightBar:SetText(string.format(weight_format, intNewValue, self:GetMax()))
		end

		return fpbWeightBar
	end

	function CreateGenericTabPanel(pnlParent)
		local tbsNewTabSheet = vgui.Create("DPropertySheet", pnlParent)

		function tbsNewTabSheet:Paint(w, h)
			jdraw.QuickDrawPanel(clrTan, 0, 20, w, h - 20)
		end

		function tbsNewTabSheet:NewTab(strName, strPanelObject, strIcon, strDesc)
			local pnlNewPanel = vgui.Create(strPanelObject)
			local tab = self:AddSheet(strName, pnlNewPanel, strIcon, false, false, strDesc).Tab

			function tab:Paint(w, h)
				local active = tbsNewTabSheet:GetActiveTab() == self
				local clrBackColor = active and clrTan or clrGray

				jdraw.QuickDrawPanel(clrBackColor, 0, 0, w, h - 1)

				-- TODO: Probably what's making them look broken
				if active then
					draw.RoundedBox(0, 1, h - 4, w - 2, 5, clrBackColor)
				else
					draw.RoundedBox(0, 1, h - 4, w - 2, 2, clrBackColor)
				end
			end

			return pnlNewPanel
		end

		return tbsNewTabSheet
	end

	function CreateGenericListItem(intHeaderSize, strNameText, strDesc, strIcon, clrColor, boolExpandable, boolExpanded)
		local lstNewListItem = vgui.Create("FListItem")
		lstNewListItem:SetHeaderSize(intHeaderSize)
		lstNewListItem:SetNameText(strNameText)
		lstNewListItem:SetDescText(strDesc)
		lstNewListItem:SetIcon(strIcon)
		lstNewListItem:SetColor(clrColor)
		lstNewListItem:SetExpandable(boolExpandable)
		lstNewListItem:SetExpanded(boolExpanded)

		return lstNewListItem
	end

	function CreateGenericSlider(pnlParent, strText, intMin, intMax, intDecimals, strConVar)
		local nmsNewNumSlider = vgui.Create("DNumSlider", pnlParent)
		nmsNewNumSlider:SetText(strText)
		nmsNewNumSlider:SetMin(intMin)
		nmsNewNumSlider:SetMax(intMax or intMin)
		nmsNewNumSlider:SetDecimals(intDecimals or 0)
		nmsNewNumSlider:SetConVar(strConVar)

		return nmsNewNumSlider
	end

	function CreateGenericCheckBox(pnlParent, strText, strConVar)
		local ckbNewCheckBox = vgui.Create("DCheckBoxLabel", pnlParent)
		ckbNewCheckBox:SetText(strText)
		ckbNewCheckBox:SetConVar(strConVar)
		ckbNewCheckBox:SizeToContents()

		return ckbNewCheckBox
	end

	function CreateGenericImageButton(pnlParent, strImage, strToolTip, fncFunction)
		local btnNewButton = vgui.Create("DImageButton", pnlParent)
		btnNewButton:SetImage(strImage)
		btnNewButton:SetTooltip(strToolTip)
		btnNewButton:SizeToContents()
		btnNewButton.DoClick = fncFunction

		return btnNewButton
	end

	local shade = Color(0, 0, 0, 100)
	function CreateGenericButton(pnlParent, strText)
		local btnNewButton = vgui.Create("DButton", pnlParent)
		btnNewButton:SetText(strText)
		btnNewButton:SetTextColor(color_white)

		function btnNewButton:Paint(w, h)
			local clrDrawColor = clrGray
			local intGradDir = 1

			if self:GetDisabled() then
				clrDrawColor = ColorCopy(clrGray, 100)
			elseif self.Depressed or self:IsDown() then
				intGradDir = -1
			elseif btnNewButton.Hovered then
				-- TODO: maybe more visual feedback?
			end

			jdraw.QuickDrawPanel(clrDrawColor, 0, 0, w, h)
			jdraw.QuickDrawGrad(shade, 0, 0, w, h, intGradDir)
		end

		return btnNewButton
	end

	function CreateGenericPanel(pnlParent, intX, intY, intWidth, intHieght)
		local pnlNewPanel = vgui.Create("DPanel", pnlParent)
		pnlNewPanel:SetPos(intX, intY)
		pnlNewPanel:SetSize(intWidth, intHieght)

		function pnlNewPanel:Paint(w, h)
			jdraw.QuickDrawPanel(clrGray, 0, 0, w, h)
		end

		return pnlNewPanel
	end

	function CreateGenericMultiChoice(pnlParent, strText, boolEditable)
		local mlcNewMultiChoice = vgui.Create("DComboBox", pnlParent)
		mlcNewMultiChoice:SetText(strText or "")
		mlcNewMultiChoice:SetEnabled(boolEditable)

		return mlcNewMultiChoice
	end

	function CreateGenericCollapse(pnlParent, strName, intSpacing, boolHorz)
		local cpcNewCollapseCat = vgui.Create("DCollapsibleCategory", pnlParent)
		cpcNewCollapseCat:SetLabel(strName)

		cpcNewCollapseCat.List = vgui.Create("DPanelList")
		cpcNewCollapseCat.List:SetAutoSize(true)
		cpcNewCollapseCat.List:SetSpacing(intSpacing)
		cpcNewCollapseCat.List:SetPadding(intSpacing)
		cpcNewCollapseCat.List:EnableHorizontal(boolHorz)
		cpcNewCollapseCat:SetContents(cpcNewCollapseCat.List)

		return cpcNewCollapseCat
	end
end
