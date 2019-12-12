
FHH_AllFamilies =  { 
	FHH_BAT,
	FHH_BEAR,
	FHH_BOAR,
	FHH_CARRION_BIRD,
	FHH_CAT,
	FHH_CRAB,
	FHH_CROCOLISK,
	FHH_GORILLA,
	FHH_HYENA,
	FHH_OWL,
	FHH_RAPTOR,
	FHH_SCORPID,
	FHH_SPIDER,
	FHH_TALLSTRIDER,
	FHH_TURTLE,
	FHH_WIND_SERPENT,
	FHH_WOLF,
	FHH_DRAGONHAWK,
	FHH_RAVAGER,
	FHH_SPOREBAT,
	FHH_NETHER_RAY,
	FHH_WARP_STALKER,
	FHH_SERPENT,
};
table.sort(FHH_AllFamilies);

FHH_PetIcons =  { 
	[FHH_BAT] = "Ability_Hunter_Pet_Bat",
	[FHH_BEAR] = "Ability_Hunter_Pet_Bear",
	[FHH_BOAR] = "Ability_Hunter_Pet_Boar",
	[FHH_CARRION_BIRD] = "Ability_Hunter_Pet_Vulture",
	[FHH_CAT] = "Ability_Hunter_Pet_Cat",
	[FHH_CRAB] = "Ability_Hunter_Pet_Crab",
	[FHH_CROCOLISK] = "Ability_Hunter_Pet_Crocolisk",
	[FHH_GORILLA] = "Ability_Hunter_Pet_Gorilla",
	[FHH_HYENA] = "Ability_Hunter_Pet_Hyena",
	[FHH_OWL] = "Ability_Hunter_Pet_Owl",
	[FHH_RAPTOR] = "Ability_Hunter_Pet_Raptor",
	[FHH_SCORPID] = "Ability_Hunter_Pet_Scorpid",
	[FHH_SPIDER] = "Ability_Hunter_Pet_Spider",
	[FHH_TALLSTRIDER] = "Ability_Hunter_Pet_TallStrider",
	[FHH_TURTLE] = "Ability_Hunter_Pet_Turtle",
	[FHH_WIND_SERPENT] = "Ability_Hunter_Pet_WindSerpent",
	[FHH_WOLF] = "Ability_Hunter_Pet_Wolf",
	[FHH_DRAGONHAWK] = "Ability_Hunter_Pet_DragonHawk",
	[FHH_RAVAGER] = "Ability_Hunter_Pet_Ravager",
	[FHH_SPOREBAT] = "Ability_Hunter_Pet_Sporebat",
	[FHH_NETHER_RAY] = "Ability_Hunter_Pet_NetherRay",
	[FHH_WARP_STALKER] = "Ability_Hunter_Pet_WarpStalker",
	[FHH_SERPENT] = "Spell_Nature_GuardianWard",
};

FHH_LearnableBy = {
	["growl"] = FHH_ALL_FAMILIES,
	["armor"] = FHH_ALL_FAMILIES,
	["stamina"] = FHH_ALL_FAMILIES, 
	["resist_arcane"] = FHH_ALL_FAMILIES,
	["resist_fire"] = FHH_ALL_FAMILIES,
	["resist_frost"] = FHH_ALL_FAMILIES,
	["resist_nature"] = FHH_ALL_FAMILIES,
	["resist_shadow"] = FHH_ALL_FAMILIES,
	["cower"] = FHH_ALL_FAMILIES,
	["reflexes"] = FHH_ALL_FAMILIES,
	["avoidance"] = FHH_ALL_FAMILIES,
	["bite"] = { FHH_BAT, FHH_BEAR, FHH_BOAR, FHH_CARRION_BIRD, FHH_CAT, FHH_CROCOLISK, FHH_GORILLA, FHH_HYENA, FHH_RAPTOR, FHH_SPIDER, FHH_TALLSTRIDER, FHH_TURTLE, FHH_WIND_SERPENT, FHH_WOLF, FHH_DRAGONHAWK, FHH_RAVAGER, FHH_NETHER_RAY, FHH_WARP_STALKER, FHH_SERPENT },
	["claw"] = { FHH_BEAR, FHH_CARRION_BIRD, FHH_CAT, FHH_CRAB, FHH_OWL, FHH_RAPTOR, FHH_SCORPID, FHH_WARP_STALKER },
	["dash"] = { FHH_BOAR, FHH_CAT, FHH_HYENA, FHH_TALLSTRIDER, FHH_WOLF, FHH_RAPTOR, FHH_RAVAGER },
	["dive"] = { FHH_BAT, FHH_CARRION_BIRD, FHH_OWL, FHH_WIND_SERPENT, FHH_DRAGONHAWK, FHH_NETHER_RAY },
	["prowl"] = { FHH_CAT },
	["screech"] = { FHH_BAT, FHH_CARRION_BIRD, FHH_OWL },
	["poison"] = { FHH_SCORPID },
	["howl"] = { FHH_WOLF },
	["lightning"] = { FHH_WIND_SERPENT },
	["charge"] = { FHH_BOAR },
	["shell"] = { FHH_TURTLE },
	["thunderstomp"] = { FHH_GORILLA },
	["firebreath"] = { FHH_DRAGONHAWK },
	["gore"] = { FHH_RAVAGER, FHH_BOAR },
	["warp"] = { FHH_WARP_STALKER },
	["spit"] = { FHH_SERPENT },
};

FHH_RequiredLevel = {
	["growl"] = { 1, 10, 20, 30, 40, 50, 60, 70 },
	["bite"] = { 1, 8, 16, 24, 32, 40, 48, 56, 64 },
	["claw"] = { 1, 8, 16, 24, 32, 40, 48, 56, 64 },
	["cower"] = { 5, 15, 25, 35, 45, 55, 65 },
	["dash"] = { 30, 40, 50, },
	["dive"] = { 30, 40, 50, },
	["prowl"] = { 30, 40, 50, },
	["screech"] = { 8, 24, 48, 56, 64 },
	["poison"] = { 8, 15, 40, 56, 64 },
	["howl"] = { 10, 24, 40, 56 },
	["stamina"] = { 10, 12, 18, 24, 30, 36, 42, 48, 54, 60, 70 },
	["armor"] = { 10, 12, 18, 24, 30, 36, 42, 48, 54, 60, 70 },
	["resist_arcane"] = { 20, 30, 40, 50, 60 },
	["resist_fire"] = { 20, 30, 40, 50, 60 },
	["resist_frost"] = { 20, 30, 40, 50, 60 },
	["resist_nature"] = { 20, 30, 40, 50, 60 },
	["resist_shadow"] = { 20, 30, 40, 50, 60 },
	["lightning"] = { 1, 12, 24, 36, 48, 60 },
	["charge"] = { 1, 12, 24, 36, 48, 60 },
	["shell"] = { 20 },
	["thunderstomp"] = { 30, 40, 50 },
	["firebreath"] = { 1, 60 },
	["gore"] = { 1, 8, 16, 24, 32, 40, 48, 56, 63 },
	["warp"] = { 60 },
	["spit"] = { 15, 45, 60 },
	["reflexes"] = 30,
	["avoidance"] = { 30, 60 },
};

FHH_SpellIDsToTokens = {
	[2649]	= "growl",		-- 1
	[14916]	= "growl",		-- 2
	[14917]	= "growl",		-- 3
	[14918]	= "growl",		-- 4
	[14919]	= "growl",		-- 5
	[14920]	= "growl",		-- 6
	[14921]	= "growl",		-- 7
	[27047]	= "growl",		-- 8
	
	[17253]	= "bite",		-- 1
	[17255]	= "bite",		-- 2
	[17256]	= "bite",		-- 3
	[17257]	= "bite",		-- 4
	[17258]	= "bite",		-- 5
	[17259]	= "bite",		-- 6
	[17260]	= "bite",		-- 7
	[17261]	= "bite",		-- 8
	[27050]	= "bite",		-- 9
	
	[16827]	= "claw",		-- 1
	[16828]	= "claw",		-- 2
	[16829]	= "claw",		-- 3
	[16830]	= "claw",		-- 4
	[16831]	= "claw",		-- 5
	[16832]	= "claw",		-- 6
	[3010]	= "claw",		-- 7
	[3009]	= "claw",		-- 8
	[27049]	= "claw",		-- 9
	
	[1742]	= "cower",		-- 1
	[1753]	= "cower",		-- 2
	[1754]	= "cower",		-- 3
	[1755]	= "cower",		-- 4
	[1756]	= "cower",		-- 5
	[16697]	= "cower",		-- 6
	[27048]	= "cower",		-- 7
	
	[23099]	= "dash",		-- 1
	[23109]	= "dash",		-- 2
	[23110]	= "dash",		-- 3
	[23145]	= "dive",		-- 1
	[23147]	= "dive",		-- 2
	[23148]	= "dive",		-- 3
	
	[7371]	= "charge",		-- 1
	[26177]	= "charge",		-- 2
	[26178]	= "charge",		-- 3
	[26179]	= "charge",		-- 4
	[26201]	= "charge",		-- 5
	[27685]	= "charge",		-- 6
	
	[34889]	= "firebreath",		-- 1
	[35323]	= "firebreath",		-- 2
	
	[35290]	= "gore",		-- 1
	[35291]	= "gore",		-- 2
	[35292]	= "gore",		-- 3
	[35293]	= "gore",		-- 4
	[35294]	= "gore",		-- 5
	[35295]	= "gore",		-- 6
	[35296]	= "gore",		-- 7
	[35297]	= "gore",		-- 8
	[35298]	= "gore",		-- 9
	
	[24604]	= "howl",		-- 1
	[24605]	= "howl",		-- 2
	[24603]	= "howl",		-- 3
	[24597]	= "howl",		-- 4

	[24844]	= "lightning",		-- 1
	[25008]	= "lightning",		-- 2
	[25009]	= "lightning",		-- 3
	[25010]	= "lightning",		-- 4
	[25011]	= "lightning",		-- 5
	[25012]	= "lightning",		-- 6

	[24640]	= "poison",		-- 1
	[24583]	= "poison",		-- 2
	[24586]	= "poison",		-- 3
	[24587]	= "poison",		-- 4
	[27060]	= "poison",		-- 5

	[24450]	= "prowl",		-- 1
	[24452]	= "prowl",		-- 2
	[24453]	= "prowl",		-- 3

	[24423]	= "screech",		-- 1
	[24577]	= "screech",		-- 2
	[24578]	= "screech",		-- 3
	[24579]	= "screech",		-- 4
	[27051]	= "screech",		-- 5

	[26064]	= "shell",		-- 1

	[35387]	= "spit",		-- 1
	[35389]	= "spit",		-- 2
	[35392]	= "spit",		-- 3

	[26090]	= "thunderstomp",		-- 1
	[26187]	= "thunderstomp",		-- 2
	[26188]	= "thunderstomp",		-- 3
	[27063]	= "thunderstomp",		-- 4

	[35346]	= "warp",

	[24545]	= "armor",		-- 1
	[24549]	= "armor",		-- 2
	[24550]	= "armor",		-- 3
	[24551]	= "armor",		-- 4
	[24552]	= "armor",		-- 5
	[24553]	= "armor",		-- 6
	[24554]	= "armor",		-- 7
	[24555]	= "armor",		-- 8
	[24629]	= "armor",		-- 9
	[24630]	= "armor",		-- 10
	[27061]	= "armor",		-- 11

	[35694]	= "avoidance",		-- 1
	[35698]	= "avoidance",		-- 2

	[25076]	= "reflexes",

	[24493]	= "resist_arcane",		-- 1
	[24497]	= "resist_arcane",		-- 2
	[24500]	= "resist_arcane",		-- 3
	[24501]	= "resist_arcane",		-- 4
	[27052]	= "resist_arcane",		-- 5
	[23992]	= "resist_fire",		-- 1
	[24439]	= "resist_fire",		-- 2
	[24444]	= "resist_fire",		-- 3
	[24445]	= "resist_fire",		-- 4
	[27053]	= "resist_fire",		-- 5
	[24446]	= "resist_frost",		-- 1
	[24447]	= "resist_frost",		-- 2
	[24448]	= "resist_frost",		-- 3
	[24449]	= "resist_frost",		-- 4
	[27054]	= "resist_frost",		-- 5
	[24492]	= "resist_nature",		-- 1
	[24502]	= "resist_nature",		-- 2
	[24503]	= "resist_nature",		-- 3
	[24504]	= "resist_nature",		-- 4
	[27055]	= "resist_nature",		-- 5
	[24488]	= "resist_shadow",		-- 1
	[24505]	= "resist_shadow",		-- 2
	[24506]	= "resist_shadow",		-- 3
	[24507]	= "resist_shadow",		-- 4
	[27056]	= "resist_shadow",		-- 5

	[4187]	= "stamina",		-- 1
	[4188]	= "stamina",		-- 2
	[4189]	= "stamina",		-- 3
	[4190]	= "stamina",		-- 4
	[4191]	= "stamina",		-- 5
	[4192]	= "stamina",		-- 6
	[4193]	= "stamina",		-- 7
	[4194]	= "stamina",		-- 8
	[5041]	= "stamina",		-- 9
	[5042]	= "stamina",		-- 10
	[27062]	= "stamina",		-- 11
};

FHH_TrainerSpells = {
	["growl"] = 1, -- ranks 1-2 are innate; this is special-cased in HuntersHelper.lua
	["stamina"] = 1,
	["armor"] = 1, 
	["resist_arcane"] = 1,
	["resist_fire"] = 1,
	["resist_frost"] = 1,
	["resist_nature"] = 1,
	["resist_shadow"] = 1,
	["reflexes"] = 1,
	["avoidance"] = 1,
};

FHH_PassiveSpells = {
	["stamina"] = 1,
	["armor"] = 1, 
	["resist_arcane"] = 1,
	["resist_fire"] = 1,
	["resist_frost"] = 1,
	["resist_nature"] = 1,
	["resist_shadow"] = 1,
	["reflexes"] = 1,
	["avoidance"] = 1,
};

FHH_PetDiets = {
	[FHH_BAT]			= { FHH_DIET_FRUIT, FHH_DIET_FUNGUS },
	[FHH_BEAR]			= { FHH_DIET_BREAD, FHH_DIET_CHEESE, FHH_DIET_FISH, FHH_DIET_FRUIT, FHH_DIET_FUNGUS, FHH_DIET_MEAT },
	[FHH_BOAR]			= { FHH_DIET_BREAD, FHH_DIET_CHEESE, FHH_DIET_FISH, FHH_DIET_FRUIT, FHH_DIET_FUNGUS, FHH_DIET_MEAT },
	[FHH_CARRION_BIRD]	= { FHH_DIET_FISH, FHH_DIET_MEAT },
	[FHH_CAT]			= { FHH_DIET_FISH, FHH_DIET_MEAT },
	[FHH_CRAB]			= { FHH_DIET_BREAD, FHH_DIET_FISH, FHH_DIET_FRUIT, FHH_DIET_FUNGUS },
	[FHH_CROCOLISK]		= { FHH_DIET_FISH, FHH_DIET_MEAT },
	[FHH_DRAGONHAWK]	= { FHH_DIET_FISH, FHH_DIET_FISH_RAW, FHH_DIET_FRUIT, FHH_DIET_MEAT, FHH_DIET_MEAT_RAW },
	[FHH_GORILLA]		= { FHH_DIET_FRUIT, FHH_DIET_FUNGUS },
	[FHH_HYENA]			= { FHH_DIET_FRUIT, FHH_DIET_MEAT },
	[FHH_NETHER_RAY]	= { FHH_DIET_MEAT, FHH_DIET_MEAT_RAW },
	[FHH_OWL]			= { FHH_DIET_MEAT },
	[FHH_RAPTOR]		= { FHH_DIET_MEAT },
	[FHH_RAVAGER]		= { FHH_DIET_MEAT, FHH_DIET_MEAT_RAW },
	[FHH_SCORPID]		= { FHH_DIET_MEAT },
	[FHH_SERPENT]		= { FHH_DIET_FISH, FHH_DIET_FISH_RAW, FHH_DIET_MEAT, FHH_DIET_MEAT_RAW },
	[FHH_SPIDER]		= { FHH_DIET_MEAT },
	[FHH_SPOREBAT]		= { FHH_DIET_BREAD, FHH_DIET_CHEESE, FHH_DIET_FRUIT, FHH_DIET_FUNGUS },
	[FHH_TALLSTRIDER]	= { FHH_DIET_CHEESE, FHH_DIET_FRUIT, FHH_DIET_FUNGUS },
	[FHH_TURTLE]		= { FHH_DIET_FISH, FHH_DIET_FISH_RAW, FHH_DIET_FRUIT, FHH_DIET_FUNGUS },
	[FHH_WARP_STALKER]	= { FHH_DIET_FISH, FHH_DIET_FISH_RAW, FHH_DIET_FRUIT },
	[FHH_WIND_SERPENT]	= { FHH_DIET_BREAD, FHH_DIET_CHEESE, FHH_DIET_FISH },
	[FHH_WOLF]			= { FHH_DIET_MEAT },
};
