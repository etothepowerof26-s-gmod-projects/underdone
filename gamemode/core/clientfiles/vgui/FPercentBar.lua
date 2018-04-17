local PANEL = {}
PANEL.Max = 1
PANEL.Value = 1
PANEL.Text = ""

AccessorFunc(PANEL, "Max", "Max")
AccessorFunc(PANEL, "Value", "Value")
AccessorFunc(PANEL, "Text", "Text")

function PANEL:Init()
	self.PercentBar = jdraw.NewProgressBar()
		self.PercentBar:SetStyle(4, clrBlue)
		self.PercentBar:SetBorder(1, clrDrakGray)
end

function PANEL:Paint(w, h)
		self.PercentBar:SetDimensions(0, 0, w, h)
		self.PercentBar:SetValue(self.Value, self.Max)
		self.PercentBar:SetText("UiBold", self.Text, clrDrakGray)
	jdraw.DrawProgressBar(self.PercentBar)
end

vgui.Register("FPercentBar", PANEL, "Panel")
