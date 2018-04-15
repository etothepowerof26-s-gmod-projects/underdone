local Player = FindMetaTable("Player")
local intDefaultPlayerSpeed = 270

function Player:AddMoveSpeed(intAmount)
	self.MoveSpeed = self.MoveSpeed or intDefaultPlayerSpeed
	self:SetMoveSpeed(self.MoveSpeed + intAmount)
end
function Player:SetMoveSpeed(intAmount)
	self.MoveSpeed = self.MoveSpeed or intDefaultPlayerSpeed
	self.MoveSpeed = math.Clamp(intAmount or self.MoveSpeed, 0, 1000)
	self:SetWalkSpeed(math.Clamp(self.MoveSpeed, 0, 1000))
	self:SetRunSpeed(math.Clamp(self.MoveSpeed, 0, 1000))
end
function Player:GetMoveSpeed()
	self.MoveSpeed = self.MoveSpeed or intDefaultPlayerSpeed
	return self.MoveSpeed
end

local function CreateSlowTimer(ply, intTime, intAmount)
	timer.Simple(intTime, function()
		if ply and ply:IsValid() then
			table.remove(ply.SlowDownTimes, 1)
			if ply.SlowDownTimes[1] then
				CreateSlowTimer(ply, ply.SlowDownTimes[1], intAmount)
			else
				ply.IsSlowingDown = false
				ply:AddMoveSpeed(intAmount)
			end
		end
	end)
end
function Player:SlowDown(intTime)
	self.SlowDownTimes = self.SlowDownTimes or {}
	table.insert(self.SlowDownTimes, intTime)
	if not self.IsSlowingDown then
		self.IsSlowingDown = true
		local intAmount = math.Round(self:GetMoveSpeed() * 0.90)
		self:AddMoveSpeed(-intAmount)
		CreateSlowTimer(self, intTime, intAmount)
	end
end

hook.Add("PlayerSpawn", "PlayerSpawn_Movement", function(ply)
	ply:SetMoveSpeed()
	if ply.MoveSpeedDebt and ply.MoveSpeedDebt ~= 0 then
		ply:AddMoveSpeed(ply.MoveSpeedDebt)
	end
end)
