local Player = FindMetaTable("Player")

function Player:IsMelee()
	if ItemTable(self:GetSlot("slot_primaryweapon")) then
		return ItemTable(self:GetSlot("slot_primaryweapon")).Melee
	end
	return
end

function Player:GetActiveAmmoType()
	if ItemTable(self:GetSlot("slot_primaryweapon")) and ItemTable(self:GetSlot("slot_primaryweapon")).AmmoType then
		return ItemTable(self:GetSlot("slot_primaryweapon")).AmmoType
	end
	return
end

function Player:IsDonator()
	if self:IsUserGroup("donator") then
		return true
	else
		return false
	end
end

function Player:GetMaximumHealth()
	return self:GetStat("stat_maxhealth")
end

function Player:GetMaxWeight()
	return self:GetStat("stat_maxweight")
end

function Player:GetArmorRating()
	local intTotalArmor = 1
	if not self.Data then return end
	for strSlot, strItem in pairs(self.Data.Paperdoll or {}) do
		local tblItemTable = ItemTable(strItem)
		if tblItemTable and tblItemTable.Armor then
			intTotalArmor = intTotalArmor + tblItemTable.Armor
		end
	end
	return intTotalArmor
end

if CLIENT then
	function Player:FollowPlayer(args)
		if not args then return end
		if not args[1] then return end
		LocalPlayer().SFollowing = false
		local function Follow()
			local OtherPlayer = ents.GetByIndex(args[1])
			if IsValid(OtherPlayer) then
				if LocalPlayer():GetPos():Distance(OtherPlayer:GetPos()) > 80 then
					local AimVec = OtherPlayer:GetPos() - LocalPlayer():GetPos()
					LocalPlayer():SetEyeAngles(AimVec:Angle())
					RunConsoleCommand("+forward")
				elseif LocalPlayer():GetPos():Distance(OtherPlayer:GetPos()) < 80 then
					RunConsoleCommand("-forward")
				end
				if LocalPlayer():KeyPressed( IN_FORWARD ) or LocalPlayer():KeyPressed( IN_MOVELEFT ) or LocalPlayer():KeyPressed( IN_MOVERIGHT ) or LocalPlayer():KeyPressed( IN_BACK ) then
					LocalPlayer():StopFollowing()
				end
				LocalPlayer().IsFollowingPlayer = true
				if LocalPlayer().SFollowing then return end
				timer.Simple(0.1, Follow, args[1])
			end
		end
		Follow()
	end
	concommand.Add("UD_FollowPlayer", function(ply, command, args) ply:FollowPlayer(args) end)

	function Player:StopFollowing()
		if LocalPlayer().IsFollowingPlayer then
			LocalPlayer().SFollowing = true
			RunConsoleCommand("-forward")
			LocalPlayer().IsFollowingPlayer = false
		end
	end
	concommand.Add("UD_StopFollowingPlayer", function(ply, command, args) ply:StopFollowing() end)
end

if SERVER then

	function Player:SkillReset()
		if self:HasItem("money", 500) then
			for skill,lvl in pairs(self.Data.Skills or {}) do
				if lvl > 0 then
					self:SetSkill(skill, 0)
				end
			end
			self:RemoveItem("money", 500)
			self:SetNWInt("SkillPoints", self:GetDeservedSkillPoints())
			self:SaveGame()
		end
	end
	concommand.Add("UD_ResetSkills", function(ply, command, args) ply:SkillReset() end)

	function Player:SearchQuestProp(Ent, strModel, strItem, strAmount)
		if not IsValid(Ent) then return end
		if Ent:GetModel() == strModel then
			if self:QuestItem(strItem) then
				local tblItemTable = ItemTable(strItem)
				self:CreateNotification("Searching")
				self:Freeze( true )
				timer.Simple(5, function()
					self:CreateNotification("Found " .. tblItemTable.PrintName)
					self:AddItem(strItem, strAmount)
					self:Freeze( false )
				end)
			end
		end
	end

	function Player:SearchWorldProp(Ent, strModel, strItem, strAmount, strModelChanging)
		if not IsValid(Ent) then return end
		if Ent:GetModel() == strModel then
			if not Ent.IsBeingSearched then
				self:CreateNotification("Searching")
				Ent.IsBeingSearched = true
				self:Freeze( true )
				timer.Simple(3, function()
					if math.random(1, 10) == 1 then
						local FoundItem = table.Random(strItem)
						local tblItemTable = ItemTable(FoundItem)
						if FoundItem == "money" then strAmount = math.random(1,20) end
						self:CreateNotification("Found x" .. strAmount .. " " .. tblItemTable.PrintName)
						self:AddItem(FoundItem, strAmount)
					else
						self:CreateNotification("Nothing is in here!")
					end
					if strModelChanging then
						Ent:EmitSound( Sound("items/ammocrate_open.wav") )
						Ent:SetModel(strModelChanging)
					else
						self:Freeze( false )
						Ent.IsBeingSearched = false
					end
				end)
				timer.Simple(8, function()
					if IsValid(self) then
						self:Freeze( false )
						Ent.IsBeingSearched = false
						if strModelChanging then
							Ent:EmitSound( Sound("items/ammocrate_close.wav") )
							Ent:SetModel(strModel)
						end
					end
				end)
			end
		end
	end

	local Complements = {}
	--TODO: table.insert or stay same?
	Complements[#Complements + 1] = "Holy_Shit_Your_Cool"
	Complements[#Complements + 1] = "Nice_Man!"
	Complements[#Complements + 1] = "You_Are_Epic!"
	Complements[#Complements + 1] = "I_Wish_I_Was_As_Cool_As_You!"
	Complements[#Complements + 1] = "I_Jizzed!"
	Complements[#Complements + 1] = "Gratz!"
	Complements[#Complements + 1] = "I_Just_Shat_My_Pants!"
	Complements[#Complements + 1] = "Call_Me!"
	Complements[#Complements + 1] = "You_Should_Model!"
	Complements[#Complements + 1] = "God_Damn_I_Love_You!"
	Complements[#Complements + 1] = "You_Make_Me_Hot"
	Complements[#Complements + 1] = "I_Wish_I_Could_Touch_You"
	Complements[#Complements + 1] = "You_Now_With_10%_More_Cowbell"
	Complements[#Complements + 1] = "My_Girlfriend_Left_Me_For_You"
	Complements[#Complements + 1] = "Lets_Make_Party"
	local Colors = {}
	Colors[1] = "purple"
	Colors[2] = "blue"
	Colors[3] = "orange"
	Colors[4] = "red"
	Colors[5] = "green"
	Colors[6] = "white"
	function Player:GiveExp(intAmount, boolShowExp)
		local PlayerExp = tonumber(self:GetNWInt("exp")) or 0
		local intCurrentExp = PlayerExp
		local intPreExpLevel = self:GetLevel()
		local intAmount = tonumber(intAmount)
		if intCurrentExp + intAmount >= 0 then
			local intTotal = math.Clamp(intCurrentExp + intAmount, toExp(intPreExpLevel), intCurrentExp + intAmount)
			self:SetNWInt("exp", tonumber(intTotal))
			if boolShowExp then
				self:CreateIndicator("+_" .. intAmount .. "_Exp", self:GetPos() + Vector(0, 0, 70), "green")
			end
			local intPostExpLevel = self:GetLevel()
			if intPreExpLevel < intPostExpLevel then
				hook.Call("UD_Hook_PlayerLevelUp", GAMEMODE, self, intPostExpLevel - intPreExpLevel)
				self:SetHealth(self:GetMaximumHealth())
				self:CreateIndicator("+1_Level", self:GetPos() + Vector(0, 0, 70), "green", true)
				for i = 1, self:GetLevel() do
					self:CreateIndicator(Complements[math.random(1, #Complements)], self:GetPos() + Vector(0, 0, 70), Colors[math.random(1, #Colors)], true)
				end
			end
		end
	end

	function GM:PlayerDeath(victim, weapon, killer)
		victim:Freeze(true)
		timer.Simple(10, function()
			if IsValid(victim) then
				victim:Freeze(false)
				victim:ConCommand("+attack")
				timer.Simple(0.1, function() if IsValid(victim) then victim:ConCommand("-attack") end end)
			end
		end)
		if killer:IsNPC() and victim:IsPlayer() then
			if killer.Race == victim.Race then
				killer:AddEntityRelationship(victim, GAMEMODE.RelationLike, 99)
			end
		end
	end

	local function PlayerAdjustDamage(entVictim, dmg) --entInflictor, entAttacker, intAmount, tblDamageInfo)
		if not entVictim:IsPlayer() then return end
		local entAttacker = dmg:GetAttacker()
		if not entAttacker:IsPlayer() and entAttacker:GetOwner():IsPlayer() then
			entAttacker = entAttacker:GetOwner()
		end
		local clrDisplayColor = "red"
		local tblNPCTable = NPCTable(entAttacker:GetNWString("npc"))
		if entAttacker:IsPlayer() then
			dmg:SetDamage(0)
		end
		if tblNPCTable then
			for strNPC,_ in pairs(GAMEMODE.DataBase.NPCs or {}) do
				local tblNPCTable = NPCTable(strNPC)
				if tblNPCTable.DamageCallBack and entVictim and entAttacker.Name and entAttacker.Name ==  tblNPCTable.Name then
					tblNPCTable:DamageCallBack(entAttacker, entVictim)
				end
			end
			dmg:SetDamage((tblNPCTable.DamagePerLevel or 0) * entAttacker:GetNWInt("level"))
			dmg:SetDamage(dmg:GetDamage() * (1 / (((entVictim:GetArmorRating() - 1) / 10) + 1)))
			dmg:SetDamage(math.Clamp(math.Round(dmg:GetDamage() + math.random(-1, 1)), 0, 9999))
			if tblNPCTable.Race == "human" then dmg:SetDamage(0) end
			if dmg:GetDamage() > 0 then
				entVictim:CreateIndicator(dmg:GetDamage(), dmg:GetDamagePosition(), clrDisplayColor)
			else
				entVictim:CreateIndicator("Miss!", dmg:GetDamagePosition(), "orange")
			end
		end
	end
	hook.Add("EntityTakeDamage", "PlayerAdjustDamage", PlayerAdjustDamage)
end
