local compat = _G['FHH_compat']

FHH_BeastInfo = compat:BuildBeastInfo()

local names = {["Bat"] = FHH_BAT,
			   ["Bear"] = FHH_BEAR,
			   ["Boar"] = FHH_BOAR,
			   ["Carrion Bird"] = FHH_CARRION_BIRD,
			   ["Cat"] = FHH_CAT,
			   ["Crab"] = FHH_CRAB,
			   ["Crocolisk"] = FHH_CROCOLISK,
			   ["Gorilla"] = FHH_GORILLA,
			   ["Hyena"] = FHH_HYENA,
			   ["Owl"] = FHH_OWL,
			   ["Raptor"] = FHH_RAPTOR,
			   ["Scorpid"] = FHH_SCORPID,
			   ["Spider"] = FHH_SPIDER,
			   ["Tallstrider"] = FHH_TALLSTRIDER,
			   ["Turtle"] = FHH_TURTLE,
			   ["Wind Serpent"] = FHH_WIND_SERPENT,
			   ["Wolf"] = FHH_WOLF,
			   ["Dragonhawk"] = FHH_DRAGONHAWK,
			   ["Ravager"] = FHH_RAVAGER,
			   ["Sporebat"] = FHH_SPOREBAT,
			   ["Nether Ray"] = FHH_NETHER_RAY,
			   ["Warp Stalker"] = FHH_WARP_STALKER,
			   ["Serpent"] = FHH_SERPENT}

function FHH_Localize_Family(name)
	return names[name]
end