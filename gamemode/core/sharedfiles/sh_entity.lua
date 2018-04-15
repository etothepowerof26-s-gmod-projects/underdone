local ENT = FindMetaTable("Entity")

function ENT:IsBuilding()
	if self:GetClass() ==  "prop_physics" then return true end
	return false
end

function ENT:IsPet()
	if self:IsNPC() and self:GetOwner() and self:GetOwner():IsPlayer() then
		return true
	end
	return false
end

function ENT:Idle()
	self:SetNPCState( NPC_STATE_IDLE )
	if self:IsCurrentSchedule( SCHED_FORCED_GO ) then
		self:SetSchedule( SCHED_IDLE_STAND )
	end
	if IsValid(self:GetEnemy()) then
		self:SetEnemy( NullEntity() )
		self:SetTarget( NullEntity() )
	end
	if self:IsFollowing() then
		self.IsFollowing = false
	end
	self:StopMoving()
	self:TaskComplete()
end

function ENT:IsIdle()
	if self:GetNPCState() == NPC_STATE_IDLE and not self:GetEnemy() then
		if self:IsCurrentSchedule( SCHED_IDLE_STAND )  then
			return true
		end
	end
	return false
end

function ENT:Follow(Ent)
	self:Idle()
	self:SetLastPosition( Ent:GetPos() + Vector(math.random(10,30),math.random(10,30),0) )
	self:SetSchedule( SCHED_FORCED_GO )
	self.IsFollowing = true
end

function ENT:IsFollowing()
	if self.IsFollowing then
		return true
	end
	return false
end

function ENT:ReturnSpawn()
	self:Idle()
	if self.Position then
		self:SetLastPosition( self.Position )
		self:SetSchedule( SCHED_FORCED_GO )
	end
end

function ENT:AttackPos(VecGoto)
	if VecGoto then
		self:SetNPCState( NPC_STATE_COMBAT )
		self:SetLastPosition( VecGoto )
		self:SetSchedule( SCHED_FORCED_GO_RUN )
	end
end

function ENT:AttackEnemy(Enemy)
	self:SetEnemy( Enemy )
	self:SetNPCState( NPC_STATE_COMBAT )
	self:SetLastPosition( Enemy:GetPos() )
	self:SetSchedule( SCHED_FORCED_GO )
end

function ENT:IsBlocked()
	if IsValid(self:GetBlockingEntity()) and self:GetBlockingEntity()then
		return self:GetBlockingEntity()
	end
	return false
end

if SERVER then
	function ENT:SetServerScale(vecScale)
		for _, ply in pairs(player.GetAll()) do
			ply:ConCommand("UD_SetEtityScale " .. self:EntIndex() .. " " .. StringatizeVector(vecScale))
		end
	end
end
if CLIENT then
	concommand.Add("UD_SetEtityScale", function(ply, command, args)
		local entEtity = ents.GetByIndex(args[1])
		local vecScale = VectortizeString(args[2])
		if IsValid(entEtity) and vecScale then
			entEtity:SetModelScale(vecScale)
		end
	end)
end
