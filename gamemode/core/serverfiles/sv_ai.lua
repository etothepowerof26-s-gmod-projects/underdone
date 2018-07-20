local function TickDistanceRetreat()
	for _, npc in pairs(ents.FindByClass("npc_*")) do
		if IsValid(npc) and not npc.DontReturn  then
			local NPCTable = NPCTable(npc:GetNWString("npc"))
			if NPCTable and NPCTable.DistanceRetreat then
				if npc:GetPos():Distance(npc.Position) > NPCTable.DistanceRetreat then
					if not npc.HasTask then
						npc:ReturnSpawn()
						npc.HasTask = true
						timer.Simple(20, function()
							if IsValid(npc) and npc.HasTask then
								npc:Idle()
								npc.HasTask = false
							end
						end)
					end
				end
				if npc:GetPos():Distance(npc.Position) > (NPCTable.DistanceRetreat * 2) then
					npc:SetPos(npc.Position)
				end
				if npc.HasTask then
					if npc:GetPos():Distance(npc.Position) < (NPCTable.DistanceRetreat * 0.1) then
						npc:Idle()
						npc.HasTask = false
					end
					if npc:IsBlocked() then
						npc:SetPos(npc.Position)
						npc.HasTask = false
					end
				end
				if npc:IsNPC() and not npc:GetEnemy() then
					for _,ply in pairs(player.GetAll()) do
						if ply:GetPos():Distance(npc:GetPos()) < 200 then
							npc:AttackEnemy(ply)
						end
					end
				end
			end
		end
	end
end
hook.Add("Tick", "TickDistanceRetreat", TickDistanceRetreat)

function GM:OnNPCKilled(Target, Killer, weapon)
	if Target:GetClass() == "npc_zombie" then GAMEMODE:RemoveAll("npc_headcrab") end
	if not Killer:IsPlayer() and Target.LastPlayerAttacker then Killer = Target.LastPlayerAttacker end
	if Killer.EntityDamageData then
		if Killer.EntityDamageData[Target] then
			for _, ply in pairs(player.GetAll()) do
				if ply.EntityDamageData then
					if ply.EntityDamageData[Target] then
						if ply.EntityDamageData[Target] > Killer.EntityDamageData[Target] then
							Killer = ply
						end
					end
				end
			end
		end
	end
	for _, ply in pairs(player.GetAll()) do
		if ply.EntityDamageData then
			if ply.EntityDamageData[Target] then
				ply.EntityDamageData[Target] = nil
			end
		end
	end
	if Target:GetNWInt("level") > 0 and Killer and Killer:IsValid() and Killer:IsPlayer() then
		local NPCTable = NPCTable(Target:GetNWString("npc"))
		if #(Killer.Squad or {}) > 1 then
			local TotalExp = math.Round((Target:GetMaxHealth() * (Target:GetLevel() / Killer:GetAverageSquadLevel())) / (#(Killer.Squad or {}) + 7))
			local PerPlayer = math.Round(TotalExp / #Killer.Squad)
			for _, ply in pairs(Killer.Squad) do
				if IsValid(ply) then
					ply:GiveExp(PerPlayer, true)
				end
			end
		else
			Killer:GiveExp(math.Round((Target:GetMaxHealth() * (Target:GetLevel() / Killer:GetLevel())) / 6), true)
		end
		for Item, Info in pairs(NPCTable.Drops or {}) do
			local ItemTable = ItemTable(Item)
			--Check Level of player and of npc
			if Target:GetLevel() >= (Info.MinLevel or 0) then
				if not ItemTable.QuestItem or (Killer:GetQuest(ItemTable.QuestItem) and not Killer:HasCompletedQuest(ItemTable.QuestItem)) then
					Item, Info = Killer:CallSkillHook("drop_mod", Item, Info)
					local Chance = (Info.Chance or 0) * (1 + (Killer:GetStat("stat_luck") / 45))
					local ItemChance = 100 / math.Clamp(Chance, 0, 100)
					if math.random(1, (ItemChance or 100)) == 1 then
						local Amount = math.random(Info.Min or 1, Info.Max or Info.Min or 1)
						local Loot = CreateWorldItem(Item, Amount, Target:GetPos() + Vector(0, 0, 30))
						Loot:SetOwner(Killer)
						local LootPhys = Loot:GetPhysicsObject()
						if not IsValid(LootPhys) and IsValid(Loot.Grip) then LootPhys = Loot.Grip:GetPhysicsObject() end
						LootPhys:Wake()
						LootPhys:ApplyForceCenter(Vector(math.random(-100, 100), math.random(-100, 100), math.random(350, 400)))
					end
				end
			end
		end
	end
end

local function NPCAdjustDamage(Victim, DamageInfo)
	local Attacker = DamageInfo:GetAttacker()
	if not IsValid(Victim) or not IsValid(Attacker) or not NPCTable(Victim:GetNWString("npc")) then return end
	if Attacker.OverrideDamge then DamageInfo:SetDamage(Attacker.OverrideDamge) end
	if not Attacker:IsPlayer() and Attacker:GetOwner():IsPlayer() then
		Attacker = Attacker:GetOwner()
	end
	local NPCTable = NPCTable(Victim:GetNWString("npc"))
	local Invincible = NPCTable.Invincible or Attacker.Race == NPCTable.Race
	if Attacker:IsPlayer() and not Invincible then
		local DisplayColor = "white"
		DamageInfo:SetDamage(math.Round(DamageInfo:GetDamage() * (1 / Victim:GetNWInt("level"))))
		if math.random(1, math.Round(20 / (1 + (Attacker:GetStat("stat_luck") / 50)))) == 1 then
			DamageInfo:SetDamage(math.Round(DamageInfo:GetDamage() * 2))
			Attacker:CreateIndicator("Crit!", DamageInfo:GetDamagePosition(), "blue", true)
			DisplayColor = "blue"
		end
		if Victim:IsNPC() then
			if not Victim:GetEnemy() then
				Victim:AttackEnemy(Attacker)
			end
			Victim:AddEntityRelationship(Attacker, GAMEMODE.RelationHate, 99)
		end
		if Victim:Health() < 2 and Victim:IsBuilding() then
			local NPCTable = NPCTable(Victim:GetNWString("npc"))
			if not NPCTable then return end
			Attacker:AddQuestKill(Victim:GetNWString("npc"))
		end
		DamageInfo:SetDamage(math.Round(DamageInfo:GetDamage() + math.random(-1, math.Round(1 * (1 + (Attacker:GetStat("stat_luck") / 55))))))
		DamageInfo:SetDamage(math.Clamp(DamageInfo:GetDamage(), 0, DamageInfo:GetDamage()))
		if not Attacker.EntityDamageData then
			Attacker.EntityDamageData = {}
		end
		Attacker.EntityDamageData[Victim] = (Attacker.EntityDamageData[Victim] or 0) + math.Clamp(DamageInfo:GetDamage(),0,Victim:Health())
		Attacker:CreateIndicator(DamageInfo:GetDamage(), DamageInfo:GetDamagePosition(), DisplayColor, true)
		if Victim:Health() <= DamageInfo:GetDamage() then
			Victim:Remove()
		end
		Victim.FirstPlayerAttacker = Victim.FirstPlayerAttacker or Attacker
		Victim.LastPlayerAttacker = Attacker
		Victim:SetHealth(Victim:Health() - DamageInfo:GetDamage())
		Victim:SetNWInt("Health", Victim:Health())
		DamageInfo:SetDamage(0)
	end
	if Invincible then DamageInfo:SetDamage(0) end
end
hook.Add("EntityTakeDamage", "UD_NPCAdjustDamage", NPCAdjustDamage)

function GM:ScaleNPCDamage(Victim, strHitGroup, DamageInfo)
	DamageInfo:ScaleDamage(1)
	local NPCTable = NPCTable(Victim:GetNWString("npc"))
	if not NPCTable then return end
	if NPCTable.Invincible or DamageInfo:GetAttacker().Race == NPCTable.Race then
		DamageInfo:ScaleDamage(0)
	end
end
