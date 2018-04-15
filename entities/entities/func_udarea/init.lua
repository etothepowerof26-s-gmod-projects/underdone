ENT.Base = "base_brush"
ENT.Type = "brush"

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
end

/*---------------------------------------------------------
   Name: KeyValue
   Desc: Called when a keyvalue is added to us
---------------------------------------------------------*/
function ENT:KeyValue(Key, Value)
  if Key == "pvp" then
    self.pvp = false
    if Value == "true" then
      self.pvp = true
    end
    if Value == "false" then
      self.pvp = false
    end
  end
  if Key == "areasound" then
    self.Areasound = Value
  end
end


/*---------------------------------------------------------
   Name: StartTouch
---------------------------------------------------------*/
function ENT:StartTouch(Ent)
  if (IsValid(Ent)) and (Ent:IsPlayer()) then
    if self.Areasound then
      Ent:SendLua("RunConsoleCommand('stopsound')")
      timer.Simple(0.1, function()
        Ent:ConCommand("UD_PlaySound " .. self.Areasound)
      end)
    end
  end
end

/*---------------------------------------------------------
   Name: EndTouch
---------------------------------------------------------*/
function ENT:EndTouch(Ent)
  if (IsValid(Ent)) and (Ent:IsPlayer()) then
    Ent.Pvp = false
    Ent:SendLua("RunConsoleCommand('stopsound')")
  end
end

/*---------------------------------------------------------
   Name: Touch
---------------------------------------------------------*/
function ENT:Touch(Ent)
  if (IsValid(Ent)) and (Ent:IsPlayer()) then
    Ent.Pvp = self.pvp or false
  end
end

/*---------------------------------------------------------
   Name: PassesTriggerFilters
   Desc: Return true if this object should trigger us
---------------------------------------------------------*/
function ENT:PassesTriggerFilters(Ent)
  return true
end

/*---------------------------------------------------------
   Name: Think
   Desc: Entity's think function. 
---------------------------------------------------------*/
function ENT:Think()
end

