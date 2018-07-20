local Quest = {}
Quest.Name = "quest_killcombinethumper"
Quest.PrintName = "Kill the Combine Thumpers"
Quest.Story = "Those combine thumpers are disturbing my work, and I can't carry on like this. Could you do something about it?"
Quest.Level = 15
Quest.Kill = {}
Quest.Kill["combine_thumper"] = 5
Quest.GainedExp = 50
Quest.GainedItems = {}
Quest.GainedItems["money"] = 100
Register.Quest(Quest)

local Quest = {}
Quest.Name = "quest_killcombine"
Quest.PrintName = "My poor satellite!"
Quest.Story = "Those damned Combine keep making use of my satellite array equipment as target practice! I cant work with swiss cheese! Please help me! Kill those horrible things!"
Quest.QuestNeeded = "quest_killcombinethumper"
Quest.Level = 20
Quest.Kill = {}
Quest.Kill ["combine_smg"] = 15
Quest.GainedExp = 100
Quest.GainedItems = {}
Quest.GainedItems["money"] = 160
Register.Quest(Quest)

local Quest = {}
Quest.Name = "quest_killzombine"
Quest.PrintName = "Zombie Boss"
Quest.Story = "It time to kill the Zombine, the zombie boss!"
Quest.QuestNeeded = "quest_killzombies"
Quest.Level = 20
Quest.Kill = {}
Quest.Kill ["zombine"] = 1
Quest.GainedExp = 400
Quest.GainedItems = {}
Quest.GainedItems["money"] = 860
Register.Quest(Quest)

local Quest = {}
Quest.Name = "quest_monkeybusiness"
Quest.PrintName = "Monkey Business"
Quest.Story = "Folks round here dont get much exotic fruit no more, not since the cleansing... If you can get me some ripe banana, I'd give you a hook I found in a zombie."
Quest.Level = 5
Quest.ObtainItems = {}
Quest.ObtainItems["item_bananna"] = 10
Quest.GainedExp = 65
Quest.GainedItems = {}
Quest.GainedItems["weapon_melee_meathook"] = 1
Register.Quest(Quest)

local Quest = {}
Quest.Name = "quest_toolwrench"
Quest.PrintName = "I need Tools!"
Quest.Story = "My research cannot continue without the proper equipment. I hear those wretched Combine are utilising Tool Wrenches to maintain their Thumpers. Could you collect one of these for me? It would be very much appreciated."
Quest.Level = 20
Quest.ObtainItems = {}
Quest.ObtainItems["weapon_melee_wrench"] = 1
Quest.GainedExp = 310
Quest.GainedItems = {}
Quest.GainedItems["money"] = 800
Register.Quest(Quest)
