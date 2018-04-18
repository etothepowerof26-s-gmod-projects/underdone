local Event = {}
Event.Name = "event_defend_whiteforestcombine"
Event.PrintName = "Combine White Forest Attack"
Event.Duration = "09"
Event.NPCAttack = {}
Event.NPCAttack[1] = {Class = "combine_smg" ,Amount = 20, Spawntime = 20, Spawnpos = Vector(-3918, -884, 881), Attackpos = Vector(-3557, -2452, 883)}
Event.NPCAttack[2] = {Class = "combine_smg" ,Amount = 20, Spawntime = 20, Spawnpos = Vector(-4396, -1007, 881), Attackpos = Vector(-3277,-2428, 894)}
Event.NPCAttack[3] = {Class = "combine_smg" ,Amount = 20, Spawntime = 20, Spawnpos = Vector(-3349, -794, 884), Attackpos = Vector(-3267, -2035, 891)}
Event.NPCAttack[4] = {Class = "combine_smg" ,Amount = 20, Spawntime = 20, Spawnpos = Vector(-3180, -1127, 885), Attackpos = Vector(-3652, -2005, 887)}
Event.NPCAttack[5] = {Class = "combine_Elite" ,Amount = 1, Spawntime = 420, Spawnpos = Vector(-3180, -1127, 885), Attackpos = Vector(-3652, -2005, 887), Level = 50}
Event.Time = { w = "3", H = "22", Start = "21"}
Register.Event(Event)

local Event = {}
Event.Name = "event_antlion_spawning"
Event.PrintName = "Antlion Mating Season"
Event.Duration = "10"
Event.NPCAttack = {}
Event.NPCAttack[1] = {Class = "antlion" ,Amount = 20, Spawntime = 20, Spawnpos = Vector(-3918, -884, 881)}
Event.NPCAttack[2] = {Class = "antlion" ,Amount = 20, Spawntime = 20, Spawnpos = Vector(-4396, -1007, 882)}
Event.Time = { w = "3", H = "14", Start = "15"}
Register.Event(Event)
