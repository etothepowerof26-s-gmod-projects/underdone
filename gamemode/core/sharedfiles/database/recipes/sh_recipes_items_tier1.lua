local Recipe = {}
Recipe.Name = "recipe_wooddistillation"
Recipe.PrintName = "Wood Distillation"
Recipe.NearFire = true
Recipe.MakeTime = 10
Recipe.GainExp = 5
Recipe.Chance = 90
Recipe.Ingredients = {}
Recipe.Ingredients["wood"] = 5
Recipe.Products = {}
Recipe.Products["item_trade_methanol"] = 1
Recipe.Products["item_trade_charcoal"] = 1
Recipe.BadProducts = {}
Recipe.BadProducts["item_trade_charcoal"] = 1
Recipe.RequiredMasters = {}
Recipe.RequiredMasters["master_chemical"] = 1
Register.Recipe(Recipe)

local Recipe = {}
Recipe.Name = "recipe_canofmeat"
Recipe.PrintName = "Cook Meat"
Recipe.NearFire = true
Recipe.MakeTime = 5
Recipe.GainExp = 3
Recipe.Chance = 40
Recipe.Ingredients = {}
Recipe.Ingredients["item_canmeat"] = 1
Recipe.Products = {}
Recipe.Products["item_cancookedmeat"] = 1
Recipe.BadProducts = {}
Recipe.BadProducts["item_canspoilingmeat"] = 1
Recipe.RequiredMasters = {}
Recipe.RequiredMasters["master_culinary"] = 1
Register.Recipe(Recipe)

local Recipe = {}
Recipe.Name = "recipe_package_chinesebox"
Recipe.PrintName = "Chinese Box"
Recipe.NearFire = false
Recipe.MakeTime = 5
Recipe.GainExp = 3
Recipe.Chance = 100
Recipe.Ingredients = {}
Recipe.Ingredients["item_cardboard"] = 2
Recipe.Products = {}
Recipe.Products["item_chinese_box"] = 1
Recipe.RequiredMasters = {}
Recipe.RequiredMasters["master_crafting"] = 1
Register.Recipe(Recipe)


