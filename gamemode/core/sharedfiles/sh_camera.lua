GM.ConVarCameraDistance = CreateClientConVar("ud_cameradistance", 100, true, false)
GM.AdditiveCameraDistance = 0
GM.CameraDelta = 0.4
GM.LastLookPos = nil

local Player = FindMetaTable("Player")
function Player:GetIdealCamPos()
	local Position = self:EyePos()
	local Distance = math.Clamp(GAMEMODE.ConVarCameraDistance:GetInt(), 50, 200) + GAMEMODE.AdditiveCameraDistance
	local EditorRadiants = GAMEMODE.PaperDollEditor.CurrentCamRotation
	local EditorDistance = GAMEMODE.PaperDollEditor.CurrentCamDistance
	if EditorRadiants or EditorDistance then
		Distance = Distance + (EditorDistance or 0)
		local AddedHeight = 5
		Position.x = Position.x + (math.cos(math.rad(EditorRadiants or 0)) * Distance)
		Position.y = Position.y + (math.sin(math.rad(EditorRadiants or 0)) * Distance)
		Position.z = Position.z + AddedHeight
	else
		local tracedata = {}
		tracedata.start = Position + Vector(0, 0, 25)
		tracedata.endpos = Position + (self:EyeAngles():Forward() * -Distance) + Vector(0, 0, 25)
		tracedata.filter = self.Owner
		local trace = util.TraceLine(tracedata)
		Distance = trace.HitPos:Distance(tracedata.start) - 10
		Position = Position + (self:EyeAngles():Forward() * -Distance) + Vector(0, 0,  25)
	end
	return Position
end
function Player:GetIdealCamAngle()
	local EditorRadiants = GAMEMODE.PaperDollEditor.CurrentCamRotation
	local EditorDistance = GAMEMODE.PaperDollEditor.CurrentCamDistance
	if EditorRadiants or EditorDistance then
		local OldPosition = GAMEMODE.LastLookPos or LocalPlayer():GetEyeTraceNoCursor().HitPos
		local LookPos = LerpVector(GAMEMODE.CameraDelta * 2, OldPosition, LocalPlayer():GetEyeTraceNoCursor().HitPos)
		LookPos = LocalPlayer():GetPos() + Vector(0, 0, 55)
		local LookAng = (LookPos - LocalPlayer():GetIdealCamPos()):Angle()
		GAMEMODE.LastLookPos = LookPos
		return LookAng
	end
	return nil
end

if SERVER then
	local function PlayerSpawnHook(ply)
		local ViewEntity = ents.Create("prop_dynamic")
		ViewEntity:SetModel("models/error.mdl")
		ViewEntity:Spawn()
		ViewEntity:SetMoveType(MOVETYPE_NONE)
		ViewEntity:SetParent(ply)
		ViewEntity:SetPos(ply:GetPos())
		ViewEntity:SetRenderMode(RENDERMODE_NONE)
		ViewEntity:SetSolid(SOLID_NONE)
		ViewEntity:SetNoDraw(true)
		ply:SetViewEntity(ViewEntity)
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

	local LastVelocity = Vector(0, 0, 0)
	function GM:CalcView(ply, Origin, Angles, FieldOfView)
		if not ply or not ply:IsValid() then return end
		local client = ply
		--This is for fixing laggy animations in multiplayer for the local player (thanks CapsAdmin :D)
		antiStutterPos = LerpVector(0.2, antiStutterPos or client:GetPos(), client:GetPos())
		client:SetPos(antiStutterPos)
		if client:IsOnGround() and not game.SinglePlayer() then GAMEMODE:StutteryFix() end
		--end of fix
		if not GAMEMODE.CameraPosition then GAMEMODE.CameraPosition = client:GetPos() end
		if not GAMEMODE.CameraAngle then GAMEMODE.CameraAngle = Angle(0, 0, 0) end
		GAMEMODE.CameraPosition = LerpVector(GAMEMODE.CameraDelta, GAMEMODE.CameraPosition, client:GetIdealCamPos())
		GAMEMODE.CameraAngle = client:GetIdealCamAngle() or Angles
		local View = {}
		View.origin = GAMEMODE.CameraPosition
		View.angles = GAMEMODE.CameraAngle
		View.drawviewer = true

		return View
	end
end
