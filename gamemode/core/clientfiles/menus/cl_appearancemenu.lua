GM.AppearanceMenu = nil
PANEL = {}

function PANEL:Init()
	self.Frame = CreateGenericFrame("Appearance Menu", false, false)

	self.LeftList = CreateGenericList(self.Frame, 10, 1, 0)
	self.RightList = CreateGenericList(self.Frame, 1, 1, 0)

	self.Frame.Close = vgui.Create("DButton", self.Frame)
	self.Frame.Close:SetFont("Marlett")
	self.Frame.Close:SetText("r")
	self.Frame.Close.DoClick = function(Panel)
		GAMEMODE.AppearanceMenu.Frame:Close()
		GAMEMODE.AppearanceMenu = nil
	end

	self.Frame.Close.Paint = function()
		jdraw.QuickDrawPanel(clrGray, 20,20, self.Frame.Close:GetWide() - 1, self.Frame.Close:GetTall() - 1)
	end

	self.ViewPlayerModel = vgui.Create( "DModelPanel" )
	self.ViewPlayerModel:SetModel( LocalPlayer():GetModel() )
	self.ViewPlayerModel:SetAnimated(ACT_WALK)
	self.ViewPlayerModel:SetAnimSpeed(1)
	self.ViewPlayerModel:SetFOV( 90 )
	self.RightList:AddItem(self.ViewPlayerModel)

	for model in pairs(GAMEMODE.PlayerModels or {}) do
		local PlayerModel = vgui.Create("SpawnIcon")
		PlayerModel:SetModel(model)
		PlayerModel.OnMousePressed = function()
			RunConsoleCommand("UD_UserChangeModel", model)

			timer.Simple(0.25, function()
				if not IsValid(self) then return end
				self.ViewPlayerModel:SetModel(LocalPlayer():GetModel())
			end)
		end
		self.LeftList:AddItem(PlayerModel)
	end

	self.Frame:MakePopup()
	self:PerformLayout()
end

function PANEL:PerformLayout()
	self.Frame:SetPos(self:GetPos())
	self.Frame:SetSize(self:GetSize())
	self.Frame.Close:SetPos(self.Frame:GetWide() - 5, 0)

	self.LeftList:SetPos(5, 25)
	self.LeftList:SetSize((self.Frame:GetWide() /2) - 10, self.Frame:GetTall() - 30)

	self.RightList:SetPos((self.Frame:GetWide() / 2) - 5, 25)
	self.RightList:SetSize((self.Frame:GetWide() /2), self.Frame:GetTall() - 30)

	self.ViewPlayerModel:SetSize( 250, 250 )
	self.ViewPlayerModel:SetCamPos( Vector( 50, 50, 50 ) )
	self.ViewPlayerModel:SetLookAt( Vector( 0, 0, 40 ) )

end
vgui.Register("Appearancemenu", PANEL, "Panel")

concommand.Add("UD_OpenAppearanceMenu", function(ply, command, args)
	local npc = ply:GetEyeTrace().Entity
	local NPCTable = NPCTable(npc:GetNWString("npc"))
	if not IsValid(npc) or not NPCTable or not NPCTable.Appearance then return end
	-- if ply:GetPos():Distance(npc:GetPos()) > 100 then return end
	GAMEMODE.AppearanceMenu = GAMEMODE.AppearanceMenu or vgui.Create("Appearancemenu")
	GAMEMODE.AppearanceMenu:SetSize(520, 459)
	GAMEMODE.AppearanceMenu:Center()
end)
