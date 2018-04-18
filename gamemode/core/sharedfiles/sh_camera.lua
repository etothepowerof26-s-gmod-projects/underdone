GM.ConVarCameraDistance = CreateClientConVar("ud_cameradistance", 100, true, false)
GM.AdditiveCameraDistance = 0
GM.CameraDelta = 0.4
GM.LastLookPos = nil

local Player = FindMetaTable("Player")
function Player:GetIdealCamPos()
	local vecPosition = self:EyePos()
	local intDistance = math.Clamp(GAMEMODE.ConVarCameraDistance:GetInt(), 50, 200) + GAMEMODE.AdditiveCameraDistance
	local intEditorRadiants = GAMEMODE.PaperDollEditor.CurrentCamRotation
	local intEditorDistance = GAMEMODE.PaperDollEditor.CurrentCamDistance
	if intEditorRadiants or intEditorDistance then
		intDistance = intDistance + (intEditorDistance or 0)
		local intAddedHeight = 5
		vecPosition.x = vecPosition.x + (math.cos(math.rad(intEditorRadiants or 0)) * intDistance)
		vecPosition.y = vecPosition.y + (math.sin(math.rad(intEditorRadiants or 0)) * intDistance)
		vecPosition.z = vecPosition.z + intAddedHeight
	else
		local tracedata = {}
		tracedata.start = vecPosition + Vector(0, 0, 25)
		tracedata.endpos = vecPosition + (self:EyeAngles():Forward() * -intDistance) + Vector(0, 0, 25)
		tracedata.filter = self.Owner
		local trace = util.TraceLine(tracedata)
		intDistance = trace.HitPos:Distance(tracedata.start) - 10
		vecPosition = vecPosition + (self:EyeAngles():Forward() * -intDistance) + Vector(0, 0,  25)
	end
	return vecPosition
end
function Player:GetIdealCamAngle()
	local intEditorRadiants = GAMEMODE.PaperDollEditor.CurrentCamRotation
	local intEditorDistance = GAMEMODE.PaperDollEditor.CurrentCamDistance
	if intEditorRadiants or intEditorDistance then
		local vecOldPosition = GAMEMODE.LastLookPos or LocalPlayer():GetEyeTraceNoCursor().HitPos
		local vecLookPos = LerpVector(GAMEMODE.CameraDelta * 2, vecOldPosition, LocalPlayer():GetEyeTraceNoCursor().HitPos)
		vecLookPos = LocalPlayer():GetPos() + Vector(0, 0, 55)
		local vecToLookPos = (vecLookPos - LocalPlayer():GetIdealCamPos())
		GAMEMODE.LastLookPos = vecLookPos
		return vecToLookPos:Angle()
	end
	return nil
end

if SERVER then
	local function PlayerSpawnHook(plySpawned)
		local entViewEntity = ents.Create("prop_dynamic")
		entViewEntity:SetModel("models/error.mdl")
		entViewEntity:Spawn()
		entViewEntity:SetMoveType(MOVETYPE_NONE)
		entViewEntity:SetParent(plySpawned)
		entViewEntity:SetPos(plySpawned:GetPos())
		entViewEntity:SetRenderMode(RENDERMODE_NONE)
		entViewEntity:SetSolid(SOLID_NONE)
		entViewEntity:SetNoDraw(true)
		plySpawned:SetViewEntity(entViewEntity)
	end
	hook.Add("PlayerSpawn", "PlayerSpawnHook", PlayerSpawnHook)
else
	hook.Add("Initialize", "InitAnimFix", function()
		RunConsoleCommand("cl_predict", 0)
	end)
	function GM:StutteryFix()
		local client = LocalPlayer()
		local frameTime = (FrameTime() * 100)
		client.AntiStutterAnimate = client.AntiStutterAnimate or 0
		if client:Crouching() then
			client.AntiStutterAnimate = client.AntiStutterAnimate + (client:GetVelocity():Length() / 5000 * frameTime)
		end
		if not client:Crouching() and not client:KeyDown(IN_WALK) then
			client.AntiStutterAnimate = client.AntiStutterAnimate + (client:GetVelocity():Length() / 12000 * frameTime)
		end
		if client:KeyDown(IN_WALK) then
			client.AntiStutterAnimate = client.AntiStutterAnimate + (client:GetVelocity():Length() / 6000 * frameTime)
		end
		client:SetCycle(client.AntiStutterAnimate)
		if client.AntiStutterAnimate > 1 then client.AntiStutterAnimate = 0 end
	end

	local intLastVelocity = Vector(0, 0, 0)
	function GM:CalcView(plyClient, vecOrigin, angAngles, fovFieldOfView)
		if not plyClient or not plyClient:IsValid() then return end
		local client = plyClient
		--This is for fixing laggy animations in multiplayer for the local player (thanks CapsAdmin :D)
		antiStutterPos = LerpVector(0.2, antiStutterPos or client:GetPos(), client:GetPos())
		client:SetPos(antiStutterPos)
		if client:IsOnGround() and not game.SinglePlayer() then GAMEMODE:StutteryFix() end
		--end of fix
		if not GAMEMODE.CameraPosition then GAMEMODE.CameraPosition = client:GetPos() end
		if not GAMEMODE.CameraAngle then GAMEMODE.CameraAngle = Angle(0, 0, 0) end
		GAMEMODE.CameraPosition = LerpVector(GAMEMODE.CameraDelta, GAMEMODE.CameraPosition, client:GetIdealCamPos())
		GAMEMODE.CameraAngle = client:GetIdealCamAngle() or angAngles
		local tblView = {}
		tblView.origin = GAMEMODE.CameraPosition
		tblView.angles = GAMEMODE.CameraAngle
		tblView.drawviewer = true
		--if IsValid(LocalPlayer()) and CurTime() > 2 then
			--tblView.fov = fovFieldOfView * math.Clamp((intLastVelocity + ((LocalPlayer():GetVelocity() - intLastVelocity) / 20)):Length() / 290, 1, 50)
			--intLastVelocity = (intLastVelocity + ((LocalPlayer():GetVelocity() - intLastVelocity) / 20))
			--print(tblView.fov)
		--end
		return tblView
	end
end
