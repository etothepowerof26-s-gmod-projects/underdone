

EFFECT.Mat = Material( "effects/select_ring" )

/*---------------------------------------------------------
	 Initializes the effect. The data is a table of data 
	 which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )
	
	local size = 8
	self:SetCollisionBounds( Vector( -size,-size,-size ), Vector( size,size,size ) )
	
	local Pos = data:GetOrigin() + data:GetNormal() * 2
		
	self:SetPos( Pos )
	
	// This 0.01 is a hack.. to prevent the angle being weird and messing up when we change it back to a normal
	self:SetAngles( data:GetNormal():Angle() + Angle( 0.01, 0.01, 0.01 ) )
	
	self:SetParentPhysNum( data:GetAttachment() )
	
	if (data:GetEntity():IsValid()) then
		self:SetParent( data:GetEntity() )
		self.Entity = data:GetEntity()
	end
	
	self.Pos = data:GetOrigin()
	self.Normal = data:GetNormal()
	self.Scale = data:GetScale()
	
	self.Size = 4
	
end


/*---------------------------------------------------------
	 THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	
	self.Size = math.cos(CurTime() * 5)* 10 + 40
	
	return true
	
end

/*---------------------------------------------------------
	 Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()

	if not self then return end
	if not IsValid(self.Entity) then return end
	if not self.Scale then return end
	
	
	render.SetMaterial( self.Mat )
	render.DrawQuadEasy( self:GetPos(), self:GetAngles():Forward(), self.Size, self.Size, clrOrange)
	
end
