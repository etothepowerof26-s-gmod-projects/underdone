jdraw = {}
local matGradiantDown = Material("gui/gradient_down")
local matGradiantUp = Material("gui/gradient_up")

function jdraw.NewPanel(tblParent, boolCopyStyle)
	local tblNewPanel = {}
	tblNewPanel.Position = {}
	tblNewPanel.Position.X = 0
	if tblParent then tblNewPanel.Position.X = tblParent.Position.X end
	tblNewPanel.Position.Y = 0
	if tblParent then tblNewPanel.Position.Y = tblParent.Position.Y end
	tblNewPanel.Size = {}
	tblNewPanel.Size.Width = 0
	tblNewPanel.Size.Height = 0
	function tblNewPanel:SetDemensions(intX, intY, intWidth, intHeight)
		tblNewPanel.Position.X = tblNewPanel.Position.X + intX
		tblNewPanel.Position.Y = tblNewPanel.Position.Y + intY
		tblNewPanel.Size.Width = intWidth
		tblNewPanel.Size.Height = intHeight
	end
	tblNewPanel.Radius = 0
	if tblParent and boolCopyStyle then tblNewPanel.Radius = tblParent.Radius end
	tblNewPanel.Color = Color(255, 255, 255, 255)
	if tblParent and boolCopyStyle then tblNewPanel.Color = tblParent.Color end
	function tblNewPanel:SetStyle(intRadius, clrColor)
		tblNewPanel.Radius = intRadius
		tblNewPanel.Color = clrColor
	end
	tblNewPanel.Boarder = 0
	if tblParent and boolCopyStyle then tblNewPanel.Boarder = tblParent.Boarder end
	tblNewPanel.BoarderColor = Color(255, 255, 255, 255)
	if tblParent and boolCopyStyle then tblNewPanel.BoarderColor = tblParent.BoarderColor end
	function tblNewPanel:SetBoarder(intBoarder, clrBoarderColor)
		tblNewPanel.Boarder = intBoarder
		tblNewPanel.BoarderColor = clrBoarderColor
	end
	return tblNewPanel
end

function jdraw.DrawPanel(tblPanelTable)
	local intRadius = tblPanelTable.Radius or 0
	local intBoarder = tblPanelTable.Boarder or 0
	local intX, intY = tblPanelTable.Position.X, tblPanelTable.Position.Y
	local intWidth, intHeight = tblPanelTable.Size.Width, tblPanelTable.Size.Height
	if tblPanelTable.Boarder > 0 then
		draw.RoundedBox(intRadius, intX, intY, intWidth, intHeight, tblPanelTable.BoarderColor)
		draw.RoundedBox(intRadius, intX + intBoarder, intY + intBoarder, intWidth - (intBoarder * 2), intHeight - (intBoarder * 2), tblPanelTable.Color)
	else
		draw.RoundedBox(intRadius, intX, intY, intWidth, intHeight, tblPanelTable.Color)
	end
end

function jdraw.NewProgressBar(tblParent, boolCopyStyle)
	local tblNewPanel = jdraw.NewPanel(tblParent, boolCopyStyle)
	tblNewPanel.Value = 0
	tblNewPanel.MaxValue = 0
	function tblNewPanel:SetValue(intValue, intMaxValue)
		tblNewPanel.Value = intValue
		tblNewPanel.MaxValue = intMaxValue or 0
	end
	tblNewPanel.Font = "Default"
	tblNewPanel.Text = ""
	tblNewPanel.TextColor = Color(255, 255, 255, 255)
	function tblNewPanel:SetText(strFont, strText, clrtextColor)
		tblNewPanel.Font = strFont
		tblNewPanel.Text = strText
		tblNewPanel.TextColor = clrtextColor
	end
	return tblNewPanel
end

function jdraw.DrawProgressBar(tblPanelTable)
	local intRadius = tblPanelTable.Radius or 0
	local intBoarder = tblPanelTable.Boarder or 0
	local intX, intY = tblPanelTable.Position.X, tblPanelTable.Position.Y
	local intWidth, intHeight = tblPanelTable.Size.Width, tblPanelTable.Size.Height
	local intValue = tblPanelTable.Value
	local intMaxValue = tblPanelTable.MaxValue
	local intBarWidth = ((intWidth - (intBoarder * 2)) / intMaxValue) * intValue
	local strText = tblPanelTable.Text
	if intRadius > intBarWidth then intRadius = 1 end
	draw.RoundedBox(intRadius, intX, intY, intWidth, intHeight, tblPanelTable.BoarderColor)
	draw.RoundedBox(intRadius, intX + intBoarder, intY + intBoarder, intWidth  - (intBoarder * 2), intHeight - (intBoarder * 2), clrGray)
	surface.SetDrawColor(0, 0, 0, 70)
	surface.SetMaterial(matGradiantDown)
	surface.DrawTexturedRect(intX, intY, intWidth, intHeight)
	if intValue > 0 then
		draw.RoundedBox(intRadius, intX + intBoarder, intY + intBoarder, intBarWidth, intHeight - (intBoarder * 2), tblPanelTable.Color)
		surface.SetDrawColor(0, 0, 0, 100)
		surface.SetMaterial(matGradiantUp)
		surface.DrawTexturedRect(intX + intBoarder, intY + intBoarder, intBarWidth, intHeight - (intBoarder * 2))
	end
	if strText and strText ~= "" then
		draw.SimpleText(strText, tblPanelTable.Font, intX + (intWidth / 2), intY + (intHeight / 2), tblPanelTable.TextColor, 1, 1)
	end
end

function jdraw.DrawHealthBar(intHealth, intMaxHealth, intX, intY, intWidth, intHeight, strPreHealth)
	intHealth = math.Clamp(intHealth, 0, 9999)
	intMaxHealth = intMaxHealth or 100
	local clrBarColor = clrGreen
	if intHealth <= (intMaxHealth * 0.2) then clrBarColor = clrRed end
	local tblNewHealthBar = jdraw.NewProgressBar()
	tblNewHealthBar:SetDemensions(intX, intY, intWidth, intHeight)
	tblNewHealthBar:SetStyle(4, clrBarColor)
	tblNewHealthBar:SetBoarder(1, clrDrakGray)
	tblNewHealthBar:SetText("Default", (strPreHealth or "") .. intHealth, clrDrakGray)
	tblNewHealthBar:SetValue(intHealth, intMaxHealth)
	jdraw.DrawProgressBar(tblNewHealthBar)
end

function jdraw.DrawIcon(strIcon, intX, intY, intWidth, intHeight)
	strIcon = strIcon or "gui/player"
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(strIcon)
	surface.DrawTexturedRect(intX, intY, intWidth, intHeight or intWidth)
end

function jdraw.QuickDrawPanel(clrColor, intX, intY, intWidth, intHeight)
	local tblNewPanel = jdraw.NewPanel()
	tblNewPanel:SetDemensions(intX, intY, intWidth, intHeight or intWidth)
	tblNewPanel:SetStyle(4, clrColor)
	tblNewPanel:SetBoarder(1, clrDrakGray)
	jdraw.DrawPanel(tblNewPanel)
end

function jdraw.QuickDrawGrad(clrColor, intX, intY, intWidth, intHeight, intDir)
	surface.SetDrawColor(clrColor)
	surface.SetMaterial(matGradiantUp)
	if intDir == -1 then surface.SetMaterial(matGradiantDown) end
	surface.DrawTexturedRect(intX, intY, intWidth, intHeight)
end
