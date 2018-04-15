GM.AppearanceMenu = nil
PANEL = {}

function PANEL:Init()
	self.Frame = CreateGenericFrame("Appearance Menu", false, false)
	
	self.LeftList = CreateGenericList(self.Frame, 10, 1, 0)
	self.RightList = CreateGenericList(self.Frame, 1, 1, 0)
	
	self.Frame.btnClose = vgui.Create("DSysButton", self.Frame)
	self.Frame.btnClose:SetType("close")
	self.Frame.btnClose.DoClick = function(pnlPanel)
		GAMEMODE.AppearanceMenu.Frame:Close()
		GAMEMODE.AppearanceMenu = nil
	end
	
	self.Frame.btnClose.Paint = function()
		jdraw.QuickDrawPanel(clrGray, 20,20, self.Frame.btnClose:GetWide() - 1, self.Frame.btnClose:GetTall() - 1)
	end
	

	self.ViewPlayerModel = vgui.Create( "DModelPanel" )
	self.ViewPlayerModel:SetModel( LocalPlayer():GetModel() )
	self.ViewPlayerModel:SetAnimated(ACT_WALK)
	self.ViewPlayerModel:SetAnimSpeed(1)
	self.ViewPlayerModel:SetFOV( 90 )
	self.RightList:AddItem(self.ViewPlayerModel)

	for _,Model in pairs(GAMEMODE.PlayerModel or {}) do
		local PlayerModel = vgui.Create("SpawnIcon")
		PlayerModel:SetModel(Model[1])
		PlayerModel.OnMousePressed = function()
			RunConsoleCommand("UD_UserChangeModel", Model[1])
			timer.Simple(0.25, function() self.ViewPlayerModel:SetModel(LocalPlayer():GetModel()) end)
		end
		self.LeftList:AddItem(PlayerModel)
	end
	
	self.Frame:MakePopup()
	self:PerformLayout()
end

function PANEL:PerformLayout()
	self.Frame:SetPos(self:GetPos())
	self.Frame:SetSize(self:GetSize())
	self.Frame.btnClose:SetPos(self.Frame:GetWide() - 5, 0)
	
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
	local tblNPCTable = NPCTable(npc:GetNWString("npc"))
	if not IsValid(npc) or not tblNPCTable or not tblNPCTable.Appearance then return end
	//if ply:GetPos():Distance(npc:GetPos()) > 100 then return end
	GAMEMODE.AppearanceMenu = GAMEMODE.AppearanceMenu or vgui.Create("Appearancemenu")
	GAMEMODE.AppearanceMenu:SetSize(520, 459)
	GAMEMODE.AppearanceMenu:Center()
end)
