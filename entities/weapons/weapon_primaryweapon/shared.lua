--Dont mess with this stuff its just for compatability
SWEP.WorldModel  = "models/weapons/w_pistol.mdl"
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
------------------------------------------------------

function SWEP:Initialize()
end

function SWEP:OnRemove()
	if SERVER then
		if self.WeaponTable and self.WeaponTable.AmmoType ~= "none" then
			self.Owner:GiveAmmo(self:Clip1(), self.WeaponTable.AmmoType)
		end
	end
end

function SWEP:SetWeapon(tblWeapon)
	if tblWeapon then
		self.WeaponTable = tblWeapon
		self:SetNWString("item", self.WeaponTable.Name)
		self:SetHoldType(self.WeaponTable.HoldType)
		return true
	end
	return false
end

function SWEP:Think()
	if self.Item ~= self:GetNWString("item") then
		self.Item = self:GetNWString("item")
		self.WeaponTable = GAMEMODE.DataBase.Items[self.Item] or {}
		if self.WeaponTable.AmmoType and self.WeaponTable.AmmoType ~= "none" then
			self:SetClip1(0)
			self:Reload()
		end
	end
end

function SWEP:Reload()
	if self:GetNWBool("reloading") == true then return false end
	local strAmmoType = self.WeaponTable.AmmoType
	local intClipSize = self.WeaponTable.ClipSize
	local intCurrentAmmo = self.Owner:GetAmmoCount(strAmmoType)
	if strAmmoType ~= "none" and self:Clip1() < self.WeaponTable.ClipSize and intCurrentAmmo > 0 then
		self:SetNWBool("reloading", true)
		self:SetNextPrimaryFire(CurTime() + self.WeaponTable.ReloadTime)
		if (game.SinglePlayer() and SERVER) or (not game.SinglePlayer() and CLIENT) then
			if self.WeaponTable.ReloadSound then self:EmitSound(self.WeaponTable.ReloadSound) end
		end
		self.Owner:DoReloadEvent()
		timer.Simple(self.WeaponTable.ReloadTime, function()
			if not self or not IsValid(self.Owner) or not self.Owner:Alive() then return end
			self.Owner:RemoveAmmo(self.WeaponTable.ClipSize - self:Clip1(), self.WeaponTable.AmmoType)
			self:SetClip1(math.Clamp(self.WeaponTable.ClipSize, 0, self:Clip1() + intCurrentAmmo))
			self:SetNWBool("reloading", false)
		end)
	end
end

function SWEP:PrimaryAttack()
	if self:Clip1() ~= 0 then
		self:WeaponAttack()
	else
		self:Reload()
	end
end

function SWEP:SecondaryAttack()
	local ply = self.Owner
	self:RightCallBack(ply)
	local intFireRate = self:GetFireRate(self.WeaponTable.FireRate)
	self:SetNextSecondaryFire(CurTime() + (1 / intFireRate))
end

function SWEP:WeaponAttack()

	local isMelee = self.WeaponTable.Melee

	if isMelee then
		self.Owner:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)
	else
		self.Owner:DoAttackEvent()
	end

	if self.WeaponTable then
		local intRange = self.Owner:GetEyeTrace().HitPos:Distance(self.Owner:GetEyeTrace().StartPos)
		local intMaxRange = 4000
		if isMelee then intMaxRange = 70 end
		local tblBullet = {}
		tblBullet.Src     = self.Owner:GetShootPos()
		tblBullet.Dir     = self.Owner:GetAimVector()
		tblBullet.Force    = (self.WeaponTable.Power or 3) / 2
		tblBullet.Spread   = Vector(self.WeaponTable.Accuracy, self.WeaponTable.Accuracy, 0)
		tblBullet.Num     = self.WeaponTable.NumOfBullets
		tblBullet.Damage  = self:GetDamage(self.WeaponTable.Power or 3)
		tblBullet.TracerName = self.WeaponTable.TracerName or "Tracer"
		tblBullet.Tracer  = 2
		if isMelee then tblBullet.Tracer = 0 end
		tblBullet.AmmoType  = self.WeaponTable.AmmoType
		if isMelee then tblBullet.AmmoType = "pistol" end
		tblBullet.Callback = function(plyShooter, trcTrace, tblDamageInfo)
			--if tblDamageInfo:GetDamagePosition():Distance(self.Owner:GetPos()) > intMaxRange then tblDamageInfo:SetDamage(0) return false, false end
			self:BulletCallBack(plyShooter, trcTrace, tblDamageInfo)
		end
		if intRange <= intMaxRange then
			self.Owner:FireBullets(tblBullet)
		end
		if SERVER and not isMelee then
			self:SetClip1(self:Clip1() - 1)
		end
		local intFireRate = self:GetFireRate(self.WeaponTable.FireRate)
		if not intFireRate then return end
		
		if CLIENT and not isMelee and CurTime() >= (self.NextBulletEffect or 0) then
			self.Owner:MuzzleFlash()
			local strEffect = "ShellEject"
			if self.WeaponTable.AmmoType == "buckshot" then strEffect = "ShotgunShellEject" end
			local effectdata = EffectData()
			effectdata:SetOrigin(GAMEMODE.PaperDollEnts[self.Owner:SteamID64()]["slot_primaryweapon"]:GetPos())
			effectdata:SetAngles(GAMEMODE.PaperDollEnts[self.Owner:SteamID64()]["slot_primaryweapon"]:GetAngles() + Angle(0, 90, 0))
			effectdata:SetEntity(self)
			effectdata:SetMagnitude(1)
			effectdata:SetScale(1)
			util.Effect(strEffect, effectdata)
			self.NextBulletEffect = CurTime() + (1 / intFireRate)
		end
		if SERVER then
			self.Owner:SlowDown((1 / intFireRate))
		end
		if (game.SinglePlayer() and SERVER) or (not game.SinglePlayer() and CLIENT) and self.WeaponTable.Sound then
			self:EmitSound(self.WeaponTable.Sound)
		end
		self:SetNextPrimaryFire(CurTime() + (1 / intFireRate))
	end
end

function SWEP:BulletCallBack(plyShooter, trcTrace, tblDamageInfo)
	for strSkill, intSkillLevel in pairs(plyShooter.Data.Skills or {}) do
		local tblSkillTable = SkillTable(strSkill)
		if plyShooter:GetSkill(strSkill) > 0 and tblSkillTable.BulletCallBack then
			tblSkillTable:BulletCallBack(plyShooter, plyShooter:GetSkill(strSkill), trcTrace, tblDamageInfo)
		end
	end
end

function SWEP:RightCallBack(ply)
	for strItem, intAmount in pairs(ply.Data.Inventory or {}) do
		local tblItemTable = ItemTable(strItem)
		if ply:GetItem(strItem) > 0 and tblItemTable.SecondaryCallBack then
			local tblweapon = ItemTable(ply:GetSlot("slot_primaryweapon"))
			if tblweapon.Name == strItem then
				tblItemTable:SecondaryCallBack(ply)
			end
		end
	end
end

function SWEP:GetDamage(intDamage)
	for strStat, tblStatTable in pairs(GAMEMODE.DataBase.Stats) do
		if self.Owner:GetStat(strStat) and tblStatTable.DamageMod then
			intDamage = tblStatTable:DamageMod(self.Owner, self.Owner:GetStat(strStat), intDamage)
		end
	end
	intDamage = self.Owner:CallSkillHook("damage_mod", intDamage)
	return intDamage
end

function SWEP:GetFireRate(intFireRate)
	for strStat, tblStatTable in pairs(GAMEMODE.DataBase.Stats) do
		if self.Owner:GetStat(strStat) and tblStatTable.FireRateMod then
			intFireRate = tblStatTable:FireRateMod(self.Owner, self.Owner:GetStat(strStat), intFireRate)
		end
	end
	intFireRate = self.Owner:CallSkillHook("firerate_mod", intFireRate)
	return intFireRate
end
