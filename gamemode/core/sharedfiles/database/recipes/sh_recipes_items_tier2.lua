local Recipe = {}
Recipe.Name = "recipe_methanolrefinement"
Recipe.PrintName = "Methanol Refinement"
Recipe.GainExp = 5
Recipe.Ingredients = {}
Recipe.Ingredients["item_trade_methanol"] = 3
Recipe.Products = {}
Recipe.Products["item_trade_fuel"] = 1
Recipe.RequiredMasters = {}
Recipe.RequiredMasters["master_chemical"] = 2
Register.Recipe(Recipe)

local Recipe = {}
Recipe.Name = "recipe_napalm"
Recipe.PrintName = "Napalm Creation"
Recipe.GainExp = 5
Recipe.Ingredients = {}
Recipe.Ingredients["item_trade_methanol"] = 3
Recipe.Products = {}
Recipe.Products["item_trade_fuel"] = 1
Recipe.RequiredMasters = {}
Recipe.RequiredMasters["master_chemical"] = 2
Register.Recipe(Recipe)

local Recipe = {}
Recipe.Name = "recipe_homemadegrenade"
Recipe.PrintName = "Homemade Grenade"
Recipe.GainExp = 8
Recipe.Ingredients = {}
Recipe.Ingredients["item_trade_tincan"] = 1
Recipe.Ingredients["item_trade_blackpowder"] = 2
Recipe.Ingredients["item_trade_explosivespin"] = 1
Recipe.Products = {}
Recipe.Products["item_grenade"] = 1
Recipe.RequiredMasters = {}
Recipe.RequiredMasters["master_mechanical"] = 2
Recipe.RequiredMasters["master_chemical"] = 2
Register.Recipe(Recipe)

local Recipe = {}
Recipe.Name = "recipe_cook_noodles"
Recipe.PrintName = "Cooking Chinese Noodles"
Recipe.NearFire = true
Recipe.MakeTime = 20
Recipe.GainExp = 10
Recipe.Chance = 30
Recipe.Ingredients = {}
Recipe.Ingredients["item_chineese_box"] = 1
Recipe.Ingredients["item_bagofnoodles"] = 1
Recipe.Products = {}
Recipe.Products["item_cookednoodles"] = 1
Recipe.BadProducts = {}
Recipe.BadProducts["item_spoilednoodles"] = 1
Recipe.RequiredMasters = {}
Recipe.RequiredMasters["master_culinary"] = 2
Register.Recipe(Recipe)
