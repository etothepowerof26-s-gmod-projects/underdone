local PANEL = {}
-- TODO: remake
PANEL.EnterText = {}
PANEL.EnterText["/n"] = "/n"
PANEL.EnterText["\n"] = "\n"
PANEL.EnterText["[n]"] = "[n]"

function PANEL:Init()
	self:SetDrawOnTop(false)
	self.DeleteContentsOnClose = true
	self.Text = {}
	--self.Font = "ConsoleText"
	self.Font = "Default"
	self.Color = Color(60, 60, 60, 255)
	self.FixedHieght = false
end

function PANEL:Paint()
	derma.SkinHook("Paint", "MultiLineLabel", self)
	local intYoffset = 0
	local intWord = 1
	local tblCurrentLine = {}

	--surface.SetDrawColor(200, 200, 200, 255)
	--surface.DrawRect(0, 0, self:GetWide(), self:GetTall())

	surface.SetFont(self.Font)
	surface.SetTextColor(self.Color)

	for _, word in pairs(self.Text) do
		local intStringWidth, intStringHieght = surface.GetTextSize(tostring(table.concat(tblCurrentLine, " ") .. " " .. word))
		intStringWidth = intStringWidth + 5
		if intStringWidth <= self:GetWide() and not self.EnterText[word] then
			table.insert(tblCurrentLine, word)
		end
		if intStringWidth > self:GetWide() or intWord >= #self.Text or self.EnterText[word] then
			surface.SetTextPos(2, intYoffset)
			surface.DrawText(tostring(table.concat(tblCurrentLine, " ")))
			intYoffset = intYoffset + intStringHieght
			table.Empty(tblCurrentLine)
			if word ~= "/n" and word ~= "[n]" then
				table.insert(tblCurrentLine, word)
			end
		end
		intWord = intWord + 1
	end

	if not self.FixedHieght and self:GetTall() ~= intYoffset + 2 then
		self:SetTall(intYoffset + 2)
		self:GetParent():InvalidateLayout()
	end

	return true
end

function PANEL:SetText(text)
	self.Text = string.Explode(" ", text)
end
function PANEL:GetText()
	return self.Text
end

function PANEL:SetFont(font)
	self.Font = font
end
function PANEL:GetFont()
	return self.Font
end

function PANEL:SetColor(color)
	self.Color = color
end
function PANEL:GetColor()
	return self.Color
end

function PANEL:SetFixed(fixed)
	self.FixedHieght = fixed
end
function PANEL:GetFixed()
	return self.FixedHieght
end
vgui.Register("FMultiLabel", PANEL)
