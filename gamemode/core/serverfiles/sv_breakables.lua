local Breakables = {}
local function AddItem(Model, Item, Chance, Min, Max)
	Breakables[Model] = Breakables[Model] or {}
	table.insert(Breakables[Model], {Item = Item, Chance = Chance or 100, Min = Min or 1, Max = Max or Min or 1})
end
AddItem("models/props_junk/wood_crate001a.mdl", "wood", 80, 1, 3)
AddItem("models/props_junk/wood_crate002a.mdl", "wood", 80, 1, 3)
AddItem("models/props_junk/wood_crate002a.mdl", "item_smallammo_small", 10)
AddItem("models/props_junk/wood_crate002a.mdl", "item_rifleammo_small", 10)
AddItem("models/props_junk/wood_crate002a.mdl", "item_buckshotammo_small", 10)
AddItem("models/props_junk/wood_crate002a.mdl", "item_canmeat", 30)

local function PropAdjustDamage(entVictim, DamageInfo)
	if IsValid(entVictim) and entVictim:GetClass() == "prop_physics" then
		local BreakTable = Breakables[entVictim:GetModel()]

		if BreakTable and DamageInfo:GetAttacker():IsPlayer() then
			DamageInfo:ScaleDamage(2)

			return
		end

		DamageInfo:SetDamage(0)
	end
end
hook.Add("EntityTakeDamage", "UD_PropAdjustDamage", PropAdjustDamage)

local function OnPropBreak(Breaker, Prop)
	if Breaker:IsValid() and Breaker:IsPlayer() and Prop:IsValid() then
		local BreakTable = Breakables[Prop:GetModel()]
		if BreakTable then
			for _, BreakItem in pairs(BreakTable) do
				if math.random(1, 100 / BreakItem.Chance) == 1 then
					local Item = BreakItem.Item
					local MaxAmount = BreakItem.Max
					Item, MaxAmount = Breaker:CallSkillHook("resouce_mod", Item, MaxAmount)
					for i = 1, math.random(BreakItem.Min, MaxAmount) do
						local Loot = CreateWorldItem(Item)
						Loot:SetPos(Prop:GetPos())
						Loot:SetOwner(Breaker)
						Loot:GetPhysicsObject():ApplyForceCenter(Vector(math.random(-100, 100), math.random(-100, 100), math.random(350, 400)))
					end
				end
			end
		end
		if Prop.ObjectKey and GAMEMODE.MapEntities.WorldProps[Prop.ObjectKey] then
			local WorldObject = GAMEMODE.MapEntities.WorldProps[Prop.ObjectKey]
			timer.Simple(math.random(45, 75), function() WorldObject.SpawnProp() end)
		end
	end
end
hook.Add("PropBreak", "UD_OnPropBreak", OnPropBreak)
