function DeriveTable(WantedTable)
	local NewTable = {}
	for k, v in pairs(WantedTable) do
		if type(v) ~= "table" then
			NewTable[k] = v
		else
			NewTable[k] = table.Copy(v)
		end
	end
	return NewTable
end
function QuickCreateItemTable(DeriveTable, Name, PrintName, strDesc, strIcon)
	local NewItem = DeriveTable(DeriveTable)
	NewItem.Name = Name
	NewItem.PrintName = PrintName
	NewItem.Desc = strDesc
	NewItem.Icon = strIcon
	NewItem.Dropable = true
	NewItem.Giveable = true
	return NewItem
end

BaseItem = {}
BaseItem.Name = "default"
BaseItem.PrintName = "No Name"
BaseItem.Desc = "No Description"
BaseItem.Icon = "icons/junk_metalcan1"
BaseItem.Model = "models/props_junk/garbage_metalcan001a.mdl"
BaseItem.Stackable = false
BaseItem.Dropable = false
BaseItem.Giveable = false
BaseItem.SellPrice = 0
BaseItem.Weight = 0

BaseFood = DeriveTable(BaseItem)
BaseFood.AddedHealth = 25
BaseFood.AddTime = 10
function BaseFood:Use(usr, itemtable)
	if not IsValid(usr) or usr:Health() >= usr:GetStat("stat_maxhealth") or usr:Health() <= 0 then return end
	local HealthToAdd = itemtable.AddedHealth
	HealthToAdd = usr:CallSkillHook("food_mod",HealthToAdd) 
	if itemtable.Message then usr:CreateNotification(itemtable.Message) end
	if itemtable.UseSound then
		usr:ConCommand("UD_PlaySound " .. itemtable.UseSound  )
		if itemtable.AltUseSound then
			usr:ConCommand("UD_PlaySound " .. itemtable.UseSound .. " " .. itemtable.AltUseSound  )
		end
	end
	local HealthGiven = 0
	local function AddHealth()
		if not usr or not usr:IsValid() or usr:Health() >= usr:GetStat("stat_maxhealth") or usr:Health() <= 0 or HealthGiven >= HealthToAdd then return end
		usr:SetHealth(math.Clamp(usr:Health() + 1, 0, usr:GetStat("stat_maxhealth")))
		HealthGiven = HealthGiven + 1
		timer.Simple(itemtable.AddTime / HealthToAdd, AddHealth)
	end
	timer.Simple(itemtable.AddTime / HealthToAdd, AddHealth)
	usr:AddItem(itemtable.Name, -1)
end

BaseAmmo = DeriveTable(BaseItem)
BaseAmmo.AmmoType = "pistol"
BaseAmmo.AmmoAmount = 20
function BaseAmmo:Use(usr, itemtable)
	if not IsValid(usr) or usr:Health() <= 0 then return false end
	usr:GiveAmmo(itemtable.AmmoAmount, itemtable.AmmoType)
	usr:AddItem(itemtable.Name, -1)
end

BaseEquipment = DeriveTable(BaseItem)
BaseEquipment.Slot = "slot_primaryweapon"
BaseEquipment.Level = 1
BaseEquipment.Buffs = {}
function BaseEquipment:Use(usr, ItemTable)
	if not IsValid(usr) or usr:Health() <= 0 or usr:GetLevel() < ItemTable.Level then return false end
	if usr.Loaded and (usr.NextSwitch or 0) > CurTime() then return false end
	usr:SetPaperDoll(ItemTable.Slot, ItemTable.Name)
	usr.NextSwitch = CurTime() + 1
	return true
end

BaseArmor = DeriveTable(BaseEquipment)
BaseArmor.Armor = 0

BaseWeapon = DeriveTable(BaseEquipment)
BaseWeapon.HoldType = "pistol"
BaseWeapon.AmmoType = "none"
BaseWeapon.NumOfBullets = 1
BaseWeapon.Power = 1
BaseWeapon.Accuracy = 0.01
BaseWeapon.FireRate = 3
BaseWeapon.ClipSize = -1
BaseWeapon.ReloadTime = 1.5
BaseWeapon.Sound = "weapons/pistol/pistol_fire2.wav"
BaseWeapon.ReloadSound = nil
function BaseWeapon:Use(usr, itemtable)
	if not itemtable then return false end
	if not BaseEquipment:Use(usr, itemtable) then return false end
	usr:StripWeapons()
	if usr.Data.Paperdoll[itemtable.Slot] == itemtable.Name then
		usr:Give("weapon_primaryweapon")
		usr:GetWeapon("weapon_primaryweapon"):SetWeapon(itemtable)
	end
end







