local Player = FindMetaTable("Player")
local DefaultPlayerSpeed = 270

function Player:AddMoveSpeed(Amount)
	self.MoveSpeed = self.MoveSpeed or DefaultPlayerSpeed
	self:SetMoveSpeed(self.MoveSpeed + Amount)
end
function Player:SetMoveSpeed(Amount)
	self.MoveSpeed = self.MoveSpeed or DefaultPlayerSpeed
	self.MoveSpeed = math.Clamp(Amount or self.MoveSpeed, 0, 1000)
	self:SetWalkSpeed(math.Clamp(self.MoveSpeed, 0, 1000))
	self:SetRunSpeed(math.Clamp(self.MoveSpeed, 0, 1000))
end
function Player:GetMoveSpeed()
	self.MoveSpeed = self.MoveSpeed or DefaultPlayerSpeed
	return self.MoveSpeed
end

local function CreateSlowTimer(ply, Time, Amount)
	timer.Simple(Time, function()
		if ply and ply:IsValid() then
			table.remove(ply.SlowDownTimes, 1)
			if ply.SlowDownTimes[1] then
				CreateSlowTimer(ply, ply.SlowDownTimes[1], Amount)
			else
				ply.IsSlowingDown = false
				ply:AddMoveSpeed(Amount)
			end
		end
	end)
end
function Player:SlowDown(Time)
	self.SlowDownTimes = self.SlowDownTimes or {}
	table.insert(self.SlowDownTimes, Time)
	if not self.IsSlowingDown then
		self.IsSlowingDown = true
		local Amount = math.Round(self:GetMoveSpeed() * 0.90)
		self:AddMoveSpeed(-Amount)
		CreateSlowTimer(self, Time, Amount)
	end
end

hook.Add("PlayerSpawn", "PlayerSpawn_Movement", function(ply)
	ply:SetMoveSpeed()
	if ply.MoveSpeedDebt and ply.MoveSpeedDebt ~= 0 then
		ply:AddMoveSpeed(ply.MoveSpeedDebt)
	end
end)
