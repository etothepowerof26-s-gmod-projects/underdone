local PANEL = {}
-- TODO: remake | Yea, you should. ~26
PANEL.EnterText = {}
PANEL.EnterText["/n"] = "/n"
PANEL.EnterText["\n"] = "\n"
PANEL.EnterText["[n]"] = "[n]"

function PANEL:Init()
	self:SetDrawOnTop(false)
	self.DeleteContentsOnClose = true
	self.Text = {}
	self.Font = "Default"
	self.Color = Color(60, 60, 60, 255)
	self.FixedHieght = false
end

function PANEL:Paint()
	derma.SkinHook("Paint", "MultiLineLabel", self)
	local Yoffset = 0
	local Word = 1
	local CurrentLine = {}

	surface.SetFont(self.Font)
	surface.SetTextColor(self.Color)

	for _, word in pairs(self.Text) do
		local StringWidth, StringHieght = surface.GetTextSize(tostring(table.concat(CurrentLine, " ") .. " " .. word))
		StringWidth = StringWidth + 5
		if StringWidth <= self:GetWide() and not self.EnterText[word] then
			table.insert(CurrentLine, word)
		end
		if StringWidth > self:GetWide() or Word >= #self.Text or self.EnterText[word] then
			surface.SetTextPos(2, Yoffset)
			surface.DrawText(tostring(table.concat(CurrentLine, " ")))
			Yoffset = Yoffset + StringHieght
			table.Empty(CurrentLine)
			if word ~= "/n" and word ~= "[n]" then
				table.insert(CurrentLine, word)
			end
		end
		Word = Word + 1
	end

	if not self.FixedHieght and self:GetTall() ~= Yoffset + 2 then
		self:SetTall(Yoffset + 2)
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
