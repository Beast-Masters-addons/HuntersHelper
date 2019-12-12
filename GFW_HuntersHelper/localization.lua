------------------------------------------------------
-- localization.lua
-- for Hunter's Helper
-- English strings by default localizations override with their own.
------------------------------------------------------

-- Beast family names
FHH_BAT = "Bat"
FHH_BEAR = "Bear"
FHH_BOAR = "Boar"
FHH_CARRION_BIRD = "Carrion Bird"
FHH_CAT = "Cat"
FHH_CRAB = "Crab"
FHH_CROCOLISK = "Crocolisk"
FHH_GORILLA = "Gorilla"
FHH_HYENA = "Hyena"
FHH_OWL = "Owl"
FHH_RAPTOR = "Raptor"
FHH_SCORPID = "Scorpid"
FHH_SPIDER = "Spider"
FHH_TALLSTRIDER = "Tallstrider"
FHH_TURTLE = "Turtle"
FHH_WIND_SERPENT = "Wind Serpent"
FHH_WOLF = "Wolf"
FHH_DRAGONHAWK = "Dragonhawk"
FHH_RAVAGER = "Ravager"
FHH_SPOREBAT = "Sporebat"
FHH_NETHER_RAY = "Nether Ray"
FHH_WARP_STALKER = "Warp Stalker"
FHH_SERPENT = "Serpent"

-- Diet names used for the tooltip when mousing over a creature as a handy reminder of what food to bring when you go tame it.
-- These should match the eight possible returns from GetPetFoodTypes(). 
FHH_DIET_MEAT		= "Meat"
FHH_DIET_FISH		= "Fish"
FHH_DIET_MEAT_RAW	= "Raw Meat"
FHH_DIET_FISH_RAW	= "Raw Fish"
FHH_DIET_BREAD		= "Bread"
FHH_DIET_CHEESE 	= "Cheese"
FHH_DIET_FRUIT		= "Fruit"
FHH_DIET_FUNGUS 	= "Fungus"

-- Other strings used in tables
FHH_ALL_FAMILIES = "all beast families"

-- slash command text
FHH_HELP_SHOWUI = "Show the Hunter's Helper window."
FHH_HELP_HELP = "Print this helplist."
FHH_HELP_TOOLTIP = "Turn display of beast abilities in tooltips on or off, or make them only appear if you're playing a hunter."
FHH_HELP_MINIMAP = "Toggle display of the minimap button."
FHH_HELP_RESET = "Reset to default options and clear all saved data."
FHH_HELP_STATUS = "Check current settings."
FHH_HELP_FIND = "List where beasts with a given ability (e.g. Bite 6) can be found."

FHH_STATUS_ONLYHUNTER = "Hunter's Helper additions to beast tooltips are enabled, but only when playing a hunter character.";
FHH_STATUS_ON = "Hunter's Helper additions to beast tooltips are enabled."
FHH_STATUS_OFF = "Hunter's Helper additions to beast tooltips are disabled."
FHH_STATUS_RESET = "Hunter's Helper has been reset to default options and all stored data cleared."

FHH_FIND_SPELL_UNKNOWN = "%s is not a known beast ability."
FHH_FIND_MISSING_INFO = "No info available for %s."
FHH_FIND_RANK_UNKNOWN = "%s is not known to have a rank %s."
FHH_FIND_REQUIRES_LVL = "%s requires pet level %s."
FHH_FIND_REQUIRES_LVL_ASSUMED = "%s requires at least pet level %s. (Assumed because it was found on a beast of this level that you tamed. Open your Beast Training window and Hunter's Helper can collect more accurate information.)"
FHH_FIND_RANKS_LISTED = "Hunter's Helper has info on the following ranks of %s:"
FHH_FIND_NEED_RANK = "Type "..GFWUtils.Hilite("/hh find %s").." and a number to get info about that rank."
FHH_FIND_LEARNABLE_BY = "%s is learnable by %s."
FHH_FIND_GROWL_INNATE = "You should already know %s if you've learned Beast Training."
FHH_FIND_PET_TRAINER = "%s is learned from Pet Trainers (found in most major cities and some towns)"
FHH_FIND_LEARNED_FROM = "%s can be learned from:"

FHH_ERROR_MISSING_LVL = GFWUtils.Red("Hunter's Helper %s error:").." missing level info for %s. Please report to gazmik@fizzwidget.com"
FHH_ERROR_NO_BEASTS = "Hunter's Helper %s: can't find any creatures with %s."

-- UI text
FHH_NUM_BEASTS_IN_ZONE = "%d beasts with learnable abilities in this zone"
FHH_NEED_SPELL_INFO = "Hunter's Helper needs to collect info about what pet abilities you already know. Please type /hh or open your Beast Training window. (Info on future abilities will be collected as they are learned.)"

FHH_UI_RARE_MOB				= "Rare"
FHH_UI_RARE_ELITE_MOB		= "Rare Elite"

FHH_OPTIONS_SUBTEXT = "To show the Hunter's Helper panel, type /huntershelper (or /hh), cast Beast Training (from your spellbook, an action bar, a macro, etc), or enable the minimap button below."
FHH_OPTIONS_BEAST_TOOLTIP = "Show tamed abilities in beast tooltips"
FHH_OPTIONS_HUNTER_ONLY = "Only when playing a hunter"
FHH_OPTIONS_MINIMAP = "Show minimap button"
FHH_OPTIONS_MINIMAP_POSITION = "Minimap button position"
FHH_OPTIONS_PANEL_HEADER = "In Hunter's Helper panel:"
FHH_OPTIONS_SHOW_ALREADY_KNOWN = "Always show beast list for abilities you already know"
FHH_OPTIONS_UI_TOOLTIP = "Show tooltips detailing ability/rank availability"

if ( GetLocale() == "deDE" ) then
	
	-- Beast family names
	FHH_BAT = "Fledermaus"
	FHH_BEAR = "Bär"
	FHH_BOAR = "Eber"
	FHH_CARRION_BIRD = "Aasvogel"
	FHH_CAT = "Katze"
	FHH_CRAB = "Krebs"
	FHH_CROCOLISK = "Krokilisk"
--	FHH_GORILLA = "Gorilla"			-- same as enUS, so it doesn't need to be repeated
	FHH_HYENA = "Hyäne"
	FHH_OWL = "Eule"
--	FHH_RAPTOR = "Raptor"			-- same as enUS, so it doesn't need to be repeated
	FHH_SCORPID = "Skorpid"
	FHH_SPIDER = "Spinne"
	FHH_TALLSTRIDER = "Weitschreiter"
	FHH_TURTLE = "Schildkröte"
	FHH_WIND_SERPENT = "Windnatter"
--	FHH_WOLF = "Wolf"				-- same as enUS, so it doesn't need to be repeated
	FHH_DRAGONHAWK = "Drachenfalke"
	FHH_RAVAGER = "Verheerer"
	FHH_SPOREBAT = "Sporensegler"
	FHH_NETHER_RAY = "Netherrochen"
	FHH_WARP_STALKER = "Sphärenjäger"
	FHH_SERPENT = "Schlange"
	
end

if ( GetLocale() == "frFR" ) then

	 -- Beast family names
	FHH_BAT = "Chauve-souris"
	FHH_BEAR = "Ours"
	FHH_BOAR = "Sanglier"
	FHH_CARRION_BIRD = "Charognard"
	FHH_CAT = "Félin"
	FHH_CRAB = "Crabe"
	FHH_CROCOLISK = "Crocilisque"
	FHH_GORILLA = "Gorille"
	FHH_HYENA = "Hyène"
	FHH_OWL = "Chouette"
--	FHH_RAPTOR = "Raptor"			-- same as enUS, so it doesn't need to be repeated
	FHH_SCORPID = "Scorpide"
	FHH_SPIDER = "Araignée"
	FHH_TALLSTRIDER = "Haut-trotteur"
	FHH_TURTLE = "Tortue"
	FHH_WIND_SERPENT = "Serpent des vents"
	FHH_WOLF = "Loup"
	FHH_DRAGONHAWK = "Faucon-dragon"
	FHH_RAVAGER = "Ravageur"
	FHH_SPOREBAT = "Sporoptère"
	FHH_NETHER_RAY = "Raie du néant"
	FHH_WARP_STALKER = "Traqueur dimensionnel"
--	FHH_SERPENT = "Serpent"			-- same as enUS, so it doesn't need to be repeated

	-- Other strings used in tables
	FHH_ALL_FAMILIES = "Toutes les familles animales"

	-- UI text
	FHH_NUM_BEASTS_IN_ZONE = "%d bêtes avec des compétence apprenables dans cette zone."
	FHH_NEED_SPELL_INFO = "Hunter's Helper a besoin de collecter les infos à propos des compétences de familiers que vous connaissez. Veuillez taper /hh ou ouvrir la fenêtre de dressage des bêtes. (Les infos sur les compétences futures seront collectées lorsque vous les apprendrez.)"

--	FHH_UI_RARE_MOB = "Rare"
--	FHH_UI_RARE_ELITE_MOB = "Rare Elite"

	FHH_OPTIONS_SUBTEXT = "Pour afficher le panneau de Hunter's Helper, tapez /huntershelper (ou /hh), lancez la fenêtre de dressage des bêtes, ou activez ci-dessous le bouton de la minicarte."
	FHH_OPTIONS_BEAST_TOOLTIP = "Afficher les compétences apprenables dans les infobulles"
	FHH_OPTIONS_HUNTER_ONLY = "Seulement quand on joue un chasseur"
	FHH_OPTIONS_MINIMAP = "Afficher le bouton sur la minicarte"
	FHH_OPTIONS_MINIMAP_POSITION = "Position du bouton"
	FHH_OPTIONS_PANEL_HEADER = "Dans le panneau de Hunter's Helper :"
	FHH_OPTIONS_SHOW_ALREADY_KNOWN = "Afficher la liste des bêtes pour les compétences connues"
	FHH_OPTIONS_UI_TOOLTIP = "Afficher les infobulles de détails"

end

if ( GetLocale() == "koKR" ) then

	-- Beast family names
	FHH_BAT = "박쥐"
	FHH_BEAR = "곰"
	FHH_BOAR = "맷돼지"
	FHH_CARRION_BIRD = "독수리"
	FHH_CAT = "살쾡이"
	FHH_CRAB = "게"
	FHH_CROCOLISK = "악어"
	FHH_GORILLA = "고릴라"
	FHH_HYENA = "하이에나"
	FHH_OWL = "올빼미"
	FHH_RAPTOR = "랩터"
	FHH_SCORPID = "전갈"
	FHH_SPIDER = "거미"
	FHH_TALLSTRIDER = "타조"
	FHH_TURTLE = "거북"
	FHH_WIND_SERPENT = "천둥매"
	FHH_WOLF = "늑대"

	-- Other strings used in tables
	FHH_ALL_FAMILIES = "모든 야수들"
	FHH_PET_TRAINER = "야수 조련사 (대도시와 몇몇 마을에 있습니다)"

end

if ( GetLocale() == "zhCN" ) then
	
	-- Beast family names
	FHH_BAT = "蝙蝠"
	FHH_BEAR = "熊"
	FHH_BOAR = "野猪"
	FHH_CARRION_BIRD = "食腐鸟"
	FHH_CAT = "猫"
	FHH_CRAB = "螃蟹"
	FHH_CROCOLISK = "鳄鱼"
	FHH_GORILLA = "猩猩"
	FHH_HYENA = "土狼"
	FHH_OWL = "猫头鹰"
	FHH_RAPTOR = "迅猛龙"
	FHH_SCORPID = "蝎"
	FHH_SPIDER = "蜘蛛"
	FHH_TALLSTRIDER = "陆行鸟"
	FHH_TURTLE = "海龟"
	FHH_WIND_SERPENT = "风蛇"
	FHH_WOLF = "狼"
	
	-- Other strings used in tables
	FHH_ALL_FAMILIES = "全部野兽"
	FHH_PET_TRAINER = "宠物训练师(位于各大主城和某些城镇)"

end

if ( GetLocale() == "zhTW" ) then
    
    -- Beast family names
    FHH_BAT = "蝙蝠"
    FHH_BEAR = "熊"
    FHH_BOAR = "野豬"
    FHH_CARRION_BIRD = "食腐鳥"
    FHH_CAT = "貓"
    FHH_CRAB = "螃蟹"
    FHH_CROCOLISK = "鱷魚"
    FHH_GORILLA = "猩猩"
    FHH_HYENA = "土狼"
    FHH_OWL = "貓頭鷹"
    FHH_RAPTOR = "迅猛龍"
    FHH_SCORPID = "蝎子"
    FHH_SPIDER = "蜘蛛"
    FHH_TALLSTRIDER = "陸行鳥"
    FHH_TURTLE = "海龜"
    FHH_WIND_SERPENT = "風蛇"
    FHH_WOLF = "狼"
    FHH_DRAGONHAWK = "龍鷹"
    FHH_RAVAGER = "破壞者"
    FHH_SPOREBAT = "孢子蝙蝠"
    FHH_NETHER_RAY = "虛空鰭刺"
    FHH_WARP_STALKER = "扭曲行者"
    FHH_SERPENT = "毒蛇"
    
    -- Other strings used in tables
    FHH_ALL_FAMILIES = "所有的野獸種類"
    FHH_PET_TRAINER = "寵物訓練師 (可以在主城或城鎮找到)"
end

if ( GetLocale() == "esES" or GetLocale() == "esMX") then

	-- Beast family names
	FHH_BAT				= "Murciélago"
	FHH_BEAR			= "Oso"
	FHH_BOAR			= "Jabalí"
	FHH_CARRION_BIRD	= "Carroñero"
	FHH_CAT				= "Felino"
	FHH_CRAB			= "Cangrejo"
	FHH_CROCOLISK		= "Crocolisco"
	FHH_GORILLA			= "Gorila"
	FHH_HYENA			= "Hiena"
	FHH_OWL				= "Búho"
--	FHH_RAPTOR			= "Raptor"			-- same as enUS, so it doesn't need to be repeated
	FHH_SCORPID			= "Escórpido"
	FHH_SPIDER			= "Araña"
	FHH_TALLSTRIDER		= "Zancaalta"
	FHH_TURTLE			= "Tortuga"
	FHH_WIND_SERPENT	= "Serpiente alada"
	FHH_WOLF			= "Lobo"
	FHH_DRAGONHAWK		= "Dracohalcón"
	FHH_RAVAGER			= "Devastador"
	FHH_SPOREBAT		= "Esporiélago"
	FHH_NETHER_RAY		= "Raya abisal"
	FHH_WARP_STALKER	= "Acechador deformado"
	FHH_SERPENT			= "Serpiente"
	
end