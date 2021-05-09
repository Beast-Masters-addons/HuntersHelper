------------------------------------------------------
-- GFWZones.lua
-- Utilities for working with geographic data 
------------------------------------------------------

GFWZONES_THIS_VERSION = 8

------------------------------------------------------

if (GFWZones == nil) then
	GFWZones = {};
end

function GFWZones_temp_LocalizedZone(aZone)
	local localized = GFWZones.Localized[aZone];
	if (localized) then
		return localized;
	else
		return aZone;
	end	
end

function GFWZones_temp_UnlocalizedZone(aZone)
	local key = GFWTable.KeyOf(GFWZones.Localized, aZone);
	if (key) then
		return key;	
	else
		return aZone;
	end
end

function GFWZones_temp_ConnectionsForZone(aZone)

	local G = GFWZones;
	
	local zoneConnections = { };
	local _, myFaction = UnitFactionGroup("player");
	
	if not (G.AdjacentZones[aZone] or G.FlightZones[myFaction][aZone]) then return nil; end
	
	-- find zones one step away (adjacent to this zone or one flight/boat/zeppelin away)
	zoneConnections[1] = GFWTable.Merge(G.AdjacentZones[aZone], G.FlightZones[myFaction][aZone]);
	zoneConnections[1] = GFWTable.Subtract(zoneConnections[1], {aZone});
	
	-- then iterate to find zones more than one step away
	local numSteps = 2;
	repeat	
		zoneConnections[numSteps] = { };
		for i=1, table.getn(zoneConnections[numSteps-1]) do
			zoneConnections[numSteps] = GFWTable.Merge(zoneConnections[numSteps], G.FlightZones[myFaction][zoneConnections[numSteps-1][i]]);
			zoneConnections[numSteps] = GFWTable.Merge(zoneConnections[numSteps], G.AdjacentZones[zoneConnections[numSteps-1][i]]);
		end
		for i=numSteps-1, 1, -1 do
			zoneConnections[numSteps] = GFWTable.Subtract(zoneConnections[numSteps], zoneConnections[i]);
		end
		zoneConnections[numSteps] = GFWTable.Subtract(zoneConnections[numSteps], {aZone});
		numSteps = numSteps + 1;
	until (table.getn(zoneConnections[numSteps-1]) == 0 or numSteps == 50); -- don't want to go forever, seems like a reasonable cutoff

	return zoneConnections;

end


------------------------------------------------------
-- Zone Connection Data
------------------------------------------------------

local tempAdjacentZones = {
	["Alterac Mountains"] = {"Silverpine Forest", "Hillsbrad Foothills", "Alterac Valley"},
	["Arathi Highlands"] = {"Wetlands", "Hillsbrad Foothills"},
	["Ashenvale"] = {"The Barrens", "Azshara", "Darkshore", "Felwood", "Stonetalon Mountains", "Blackfathom Deeps", "Warsong Gulch"},
	["Azshara"] = {"Ashenvale"},
	["Badlands"] = {"Loch Modan", "Searing Gorge", "Uldaman"},
	["Blackrock Mountain"] = {"Searing Gorge", "Burning Steppes", "Blackrock Depths", "Blackrock Spire", "Molten Core"},
	["Blasted Lands"] = {"Swamp of Sorrows"},
	["Burning Steppes"] = {"Blackrock Mountain", "Redridge Mountains"},
	["Ironforge"] = {"Dun Morogh"},
	["Darkshore"] = {"Ashenvale", "Teldrassil", "Wetlands"}, -- boat
	["Darnassus"] = {"Teldrassil"},
	["Deadwind Pass"] = {"Duskwood", "Swamp of Sorrows"},
	["Desolace"] = {"Stonetalon Mountains", "Feralas", "Desolace", "Maraudon"},
	["Dun Morogh"] = {"Ironforge", "Loch Modan", "Gnomeregan"},
	["Durotar"] = {"Orgrimmar", "The Barrens", "Stranglethorn Vale", "Tirisfal Glades"}, -- zeppelin
	["Duskwood"] = {"Elwynn Forest", "Westfall", "Deadwind Pass", "Stranglethorn Vale"},
	["Dustwallow Marsh"] = {"The Barrens", "Wetlands"}, -- boat
	["Eastern Plaguelands"] = {"Western Plaguelands", "Stratholme", "Naxxramas" },
	["Elwynn Forest"] = {"Stormwind City", "Westfall", "Duskwood", "Redridge Mountains"},
	["Felwood"] = {"Ashenvale", "Moonglade", "Winterspring"},
	["Feralas"] = {"Desolace", "Thousand Needles", "Dire Maul"},
	["Hillsbrad Foothills"] = {"Silverpine Forest", "Alterac Mountains", "Arathi Highlands", "The Hinterlands"},
	["Loch Modan"] = {"Dun Morogh", "Wetlands", "Badlands"},
	["Moonglade"] = {"Felwood", "Winterspring"},
	["Mulgore"] = {"Thunder Bluff", "The Barrens"},
	["Naxxramas"] = { "Eastern Plaguelands" },
	["Orgrimmar"] = {"The Barrens", "Durotar", "Ragefire Chasm"},
	["Redridge Mountains"] = {"Elwynn Forest", "Duskwood", "Burning Steppes"},
	["Searing Gorge"] = {"Badlands", "Blackrock Mountain"},
	["Silithus"] = {"Un'Goro Crater", "Ruins of Ahn'Qiraj"},
	["Silverpine Forest"] = {"Tirisfal Glades", "Hillsbrad Foothills", "Alterac Mountains", "Shadowfang Keep"},
	["Stonetalon Mountains"] = {"Ashenvale", "The Barrens", "Desolace"},
	["Stormwind City"] = {"Elwynn Forest", "The Stockade"},
	["Stranglethorn Vale"] = {"Duskwood", "The Barrens", "Tirisfal Glades", "Durotar", "Zul'Gurub"}, -- boat, zeppelin
	["Swamp of Sorrows"] = {"Deadwind Pass", "Blasted Lands", "The Temple of Atal'Hakkar"},
	["Tanaris"] = {"Thousand Needles", "Un'Goro Crater", "Zul'Farrak"},
	["Teldrassil"] = {"Darnassus", "Darkshore"}, -- boat
	["The Barrens"] = {"Durotar", "Mulgore", "Ashenvale", "Stonetalon Mountains", "Dustwallow Marsh", "Thousand Needles", "Stranglethorn Vale", "Wailing Caverns", "Razorfen Kraul", "Razorfen Downs", "Warsong Gulch"}, -- boat
	["The Hinterlands"] = {"Hillsbrad Foothills", "Western Plaguelands"},
	["Undercity"] = {"Tirisfal Glades"},
	["Thousand Needles"] = {"The Barrens", "Feralas", "Tanaris"},
	["Thunder Bluff"] = {"Mulgore"},
	["Tirisfal Glades"] = {"Silverpine Forest", "Undercity", "Western Plaguelands", "Stranglethorn Vale", "Durotar", "Scarlet Monastery"}, -- zeppelin
	["Un'Goro Crater"] = {"Tanaris", "Silithus"},
	["Western Plaguelands"] = {"Tirisfal Glades", "Alterac Mountains", "The Hinterlands", "Eastern Plaguelands", "Scholomance"},
	["Westfall"] = {"Elwynn Forest", "Duskwood", "The Deadmines"},
	["Wetlands"] = {"Arathi Highlands", "Loch Modan", "Dustwallow Marsh"}, -- boat
	["Winterspring"] = {"Moonglade", "Felwood"},

-- Instances / Battlegrounds / etc.
	["Ruins of Ahn'Qiraj"] = {"Gates of Ahn'Qiraj"},
	["Ahn'Qiraj"] = {"Gates of Ahn'Qiraj"},
	["Gates of Ahn'Qiraj"] = {"Silithus", "Ruins of Ahn'Qiraj", "Ahn'Qiraj"},
	["Arathi Basin"] = {"Arathi Highlands"},
	["Alterac Valley"] = {"Alterac Mountains"},
	["Blackfathom Deeps"] = {"Ashenvale"},
	["Blackrock Depths"] = {"Blackrock Mountain", "Molten Core"},
	["Blackrock Spire"] = {"Blackrock Mountain"},
	["Caverns of Time"] = {"Tanaris"},
	["Champions' Hall"] = {"Stormwind City"},
	["Dire Maul"] = {"Feralas"},
	["Gnomeregan"] = {"Dun Morogh"},
	["Hall of Legends"] = {"Orgrimmar"},
	["Maraudon"] = {"Desolace"},
	["Onyxia's Lair"] = {"Dustwallow Marsh"},
	["Ragefire Chasm"] = {"Orgrimmar"},
	["Razorfen Downs"] = {"The Barrens", "Thousand Needles"},
	["Razorfen Kraul"] = {"The Barrens"},
	["Scarlet Monastery"] = {"Tirisfal Glades"},
	["Scholomance"] = {"Western Plaguelands"},
	["Shadowfang Keep"] = {"Silverpine Forest"},
	["Stratholme"] = {"Eastern Plaguelands"},
	["The Deadmines"] = {"Westfall"},
	["Molten Core"] = {"Blackrock Depths", "Blackrock Mountain"},
	["The Stockade"] = {"Stormwind City"},
	["The Temple of Atal'Hakkar"] = {"Swamp of Sorrows"},
	["Wailing Caverns"] = {"The Barrens"},
	["Uldaman"] = {"Badlands"},
	["Warsong Gulch"] = {"The Barrens", "Ashenvale"},
	["Zul'Farrak"] = {"Tanaris"},
	["Zul'Gurub"] = {"Stranglethorn Vale"},
	
	-- Burning Crusade Azeroth content
	["Ghostlands"] = {"Eastern Plaguelands", "Eversong Woods", "Zul'Aman" },
	["Silvermoon City"] = { "Eversong Woods" },
	["Eversong Woods"] = { "Ghostlands", "Silvermoon City" },
	["Isle of Quel'Danas"] = { "Sunwell Plateau", "Magisters' Terrace"},

	["Azuremyst Isle"] = { "Darkshore", "Bloodmyst Isle", "The Exodar" };
	["Bloodmyst Isle"] = { "Azuremyst Isle" };
	["The Exodar"] = { "Azuremyst Isle" };

	-- Burning Crusade Outland content
	["Hellfire Peninsula"] = { "Zangarmarsh", "Terokkar Forest", 
		"Hellfire Ramparts", "The Blood Furnace", "The Shattered Halls", "Magtheridon's Lair" },
	["Zangarmarsh"] = { "Hellfire Peninsula", "Terokkar Forest", "Nagrand", "Blade's Edge Mountains",
	 	"The Slave Pens", "The Underbog", "The Steamvault", "Serpentshrine Cavern" },
	["Nagrand"] = { "Zangarmarsh", "Terokkar Forest", "Shattrath City" },
	["Terokkar Forest"] = { "Zangarmarsh", "Hellfire Peninsula", "Shadowmoon Valley", "Shattrath City",
	 	"Auchenai Crypts", "Mana Tombs", "Sethekk Halls", "Shadow Labyrinth" },
	["Shattrath City"] = { "Terokkar Forest", "Nagrand" },
	["Shadowmoon Valley"] = { "Terokkar Forest", "Black Temple" },
	["Blade's Edge Mountains"] = { "Zangarmarsh", "Netherstorm", "Gruul's Lair" },
	["Netherstorm"] = { "Blade's Edge Mountains",
	 	"The Mechanar", "The Botanica", "The Arcatraz", "Tempest Keep" },
	
	-- Burning Crusade instances
	["Hellfire Ramparts"] = { "Hellfire Peninsula" },
	["The Blood Furnace"] = { "Hellfire Peninsula" },
	["The Shattered Halls"] = { "Hellfire Peninsula" },
	["Magtheridon's Lair"] = { "Hellfire Peninsula" },

	["The Underbog"] = { "Zangarmarsh" },
	["The Slave Pens"] = { "Zangarmarsh" },
	["The Steamvault"] = { "Zangarmarsh" },
	["Serpentshrine Cavern"] = { "Zangarmarsh" },

	["Auchenai Crypts"] = { "Terokkar Forest" },
	["Mana-Tombs"] = { "Mana Tombs" },			-- the area outside Tombs doesn't have a hyphen
	["Mana Tombs"] = { "Mana-Tombs" },			-- but the instance itself does
	["Mana Tombs"] = { "Terokkar Forest" },
	["Sethekk Halls"] = { "Terokkar Forest" },
	["Shadow Labyrinth"] = { "Terokkar Forest" },

	["The Mechanar"] = { "Netherstorm" },
	["The Botanica"] = { "Netherstorm" },
	["The Arcatraz"] = { "Netherstorm" },
	["Tempest Keep"] = { "Netherstorm" },

	["Gruul's Lair"] = { "Blade's Edge Mountains" },
	
	["Old Hillsbrad Foothills"] = { "Tanaris" },
	["The Black Morass"] = { "Tanaris" },
	["Hyjal Summit"] = { "Tanaris" },
	
	["Karazhan"] = {"Deadwind Pass"},

	["Black Temple"] = {"Shadowmoon Valley"},
	
	["Zul'Aman"] = { "Ghostlands" },
	
	["Magisters' Terrace"] = {"Isle of Quel'Danas"},
	["Sunwell Plateau"] = {"Isle of Quel'Danas"},
};

FHH_SHATTRATH_PORTALS = "FHH_SHATT"; -- non-displayed, non-localized token used below

local tempFlightZones = {
	[FACTION_ALLIANCE] = {
		-- Deeprun Tram is in here even though it's not a "flight" per se because Horde can't easily travel through it. 
		["Arathi Highlands"] = {"Hillsbrad Foothills", "Ironforge", "The Hinterlands", "Loch Modan", "Wetlands", "Arathi Basin"},
		["Ashenvale"] = {"Darkshore"},
		["Azshara"] = {"Felwood", "Darkshore"},
		["Blasted Lands"] = {"Duskwood", "Burning Steppes", "Stormwind City"},
		["Burning Steppes"] = {"Blasted Lands", "Searing Gorge"},
		["Ironforge"] = {"Arathi Highlands", "Wetlands", "Hillsbrad Foothills", "Stormwind City", "Loch Modan", "The Hinterlands", "Searing Gorge", "Deeprun Tram"},
		["Darkshore"] = {"Teldrassil", "Ashenvale", "Moonglade", "Azshara", "Felwood", "Dustwallow Marsh", "Desolace", "Feralas"},
		["Deeprun Tram"] = {"Ironforge", "Stormwind City"},
		["Desolace"] = {"Darkshore", "Dustwallow Marsh", "Feralas"},
		["Duskwood"] = {"Blasted Lands", "Redridge Mountains", "Westfall", "Stormwind City", "Stranglethorn Vale"},
		["Dustwallow Marsh"] = {"Desolace", "Tanaris", "Darkshore", "Feralas"},
		["Eastern Plaguelands"] = {"The Hinterlands"},
		["Felwood"] = {"Winterspring", "Azshara", "Darkshore"},
		["Feralas"] = {"Darkshore", "Desolace", "Tanaris", "Dustwallow Marsh"},
		["Hillsbrad Foothills"] = {"Ironforge", "Wetlands", "Western Plaguelands", "The Hinterlands", "Arathi Highlands"},
		["Loch Modan"] = {"Wetlands", "Ironforge", "Arathi Highlands"},
		["Moonglade"] = {"Darkshore", "Winterspring"},
		["Redridge Mountains"] = {"Duskwood", "Westfall", "Stormwind City"},
		["Searing Gorge"] = {"Ironforge", "Burning Steppes"},
		["Silithus"] = {"Tanaris"},
		["Stonetalon Mountains"] = {"Darkshore"},
		["Stormwind City"] = {"Stranglethorn Vale", "Westfall", "Ironforge", "Duskwood", "Redridge Mountains", "Blasted Lands", "Deeprun Tram"},
		["Stranglethorn Vale"] = {"Duskwood", "Westfall", "Stormwind City"},
		["Tanaris"] = {"Dustwallow Marsh", "Silithus", "Feralas"},
		["Teldrassil"] = {"Darkshore"},
		["The Hinterlands"] = {"Hillsbrad Foothills", "Ironforge", "Eastern Plaguelands", "Arathi Highlands"},
		["Western Plaguelands"] = {"Hillsbrad Foothills"},
		["Westfall"] = {"Stranglethorn Vale", "Duskwood", "Redridge Mountains", "Stormwind City"},
		["Wetlands"] = {"Loch Modan", "Hillsbrad Foothills", "Arathi Highlands", "Ironforge"},
		["Winterspring"] = {"Moonglade", "Felwood"},

		-- Count home cities as an extra step away so zone listings make more sense
		["Shattrath City"] = { FHH_SHATTRATH_PORTALS };
		[FHH_SHATTRATH_PORTALS] = { "Stormwind", "Ironforge", "Darnassus", "The Exodar", "Isle of Quel'Danas" };
	},
	[FACTION_HORDE] = {
		["Arathi Highlands"] = {"Hillsbrad Foothills", "Undercity", "Badlands"},
		["Ashenvale"] = {"Orgrimmar", "The Barrens"},
		["Azshara"] = {"Orgrimmar", "The Barrens", "Felwood"},
		["Badlands"] = {"Stranglethorn Vale", "Arathi Highlands", "Swamp of Sorrows", "Undercity", "Searing Gorge"},
		["Burning Steppes"] = {"Searing Gorge"},
		["Desolace"] = {"Stonetalon Mountains", "Thunder Bluff", "Feralas"},
		["Dustwallow Marsh"] = {"Orgrimmar", "The Barrens", "Tanaris", "Mulgore"},
		["Eastern Plaguelands"] = {"Undercity"},
		["Felwood"] = {"Moonglade", "Orgrimmar", "Winterspring"},
		["Feralas"] = {"The Barrens", "Thunder Bluff", "Tanaris", "Desolace"},
		["Hillsbrad Foothills"] = {"The Hinterlands", "Undercity", "Arathi Highlands"},
		["Moonglade"] = {"Felwood", "Winterspring"},
		["Orgrimmar"] = {"Ashenvale", "Azshara", "Dustwallow Marsh", "Felwood", "Thunder Bluff", "The Barrens", "Winterspring", "Tanaris"},
		["Searing Gorge"] = {"Badlands", "Burning Steppes"},
		["Silithus"] = {"Tanaris"},
		["Silverpine Forest"] = {"Undercity"},
		["Stonetalon Mountains"] = {"Thunder Bluff", "The Barrens", "Desolace"},
		["Stranglethorn Vale"] = {"Badlands", "Swamp of Sorrows"},
		["Swamp of Sorrows"] = {"Stranglethorn Vale", "Badlands"},
		["Tanaris"] = {"The Barrens", "Orgrimmar", "Thunder Bluff", "Feralas", "Dustwallow Marsh", "Silithus"},
		["The Barrens"] = {"Orgrimmar", "Thunder Bluff", "Azshara", "Thousand Needles", "Tanaris", "Stonetalon Mountains", "Ashenvale", "Dustwallow Marsh", "Feralas"},
		["The Hinterlands"] = {"Undercity", "Hillsbrad Foothills"},
		["Undercity"] = {"The Hinterlands", "Badlands", "Silverpine Forest", "Hillsbrad Foothills", "Eastern Plaguelands", "Arathi Highlands"},
		["Thousand Needles"] = {"The Barrens", "Thunder Bluff"},
		["Thunder Bluff"] = {"Thousand Needles", "The Barrens", "Tanaris", "Stonetalon Mountains", "Orgrimmar", "Feralas", "Desolace", "Dustwallow Marsh"},
		["Winterspring"] = {"Moonglade", "Orgrimmar", "Felwood"},
		
		["Silvermoon City"] = { "Undercity", "Isle of Quel'Danas" };

		-- Count home cities as an extra step away so zone listings make more sense
		["Shattrath City"] = { FHH_SHATTRATH_PORTALS };
		[FHH_SHATTRATH_PORTALS] = { "Undercity", "Orgrimmar", "Thunder Bluff", "Silvermoon City", "Isle of Quel'Danas" };
	},
};

-- bridging to Burning Crusade content
if (GetAccountExpansionLevel() > 0) then

	table.insert(tempAdjacentZones["Eastern Plaguelands"], "Ghostlands");
	table.insert(tempFlightZones[FACTION_HORDE]["Undercity"], "Silvermoon City");

	tempFlightZones[FACTION_ALLIANCE]["Isle of Quel'Danas"] = {"Ironforge"};
	tempFlightZones[FACTION_HORDE]["Isle of Quel'Danas"] = {"Silvermoon City"};

	table.insert(tempAdjacentZones["Darkshore"], "Azuremyst Isle");

	table.insert(tempAdjacentZones["Blasted Lands"], "Hellfire Peninsula");

	table.insert(tempAdjacentZones["Tanaris"], "Old Hillsbrad Foothills");
	table.insert(tempAdjacentZones["Tanaris"], "The Black Morass");
	table.insert(tempAdjacentZones["Tanaris"], "Hyjal Summit");

	table.insert(tempAdjacentZones["Deadwind Pass"], "Karazhan");

end

------------------------------------------------------
-- load only if not already loaded
------------------------------------------------------

if (GFWZones == nil) then
	GFWZones = {};
end
local G = GFWZones;
if (G.Version == nil or (tonumber(G.Version) ~= nil and G.Version < GFWZONES_THIS_VERSION)) then

	-- load zone data
	if (G.AdjacentZones == nil) then
		G.AdjacentZones = {};
	end
	for aZone, adjacentZones in pairs(tempAdjacentZones) do
		if (G.AdjacentZones[aZone] == nil) then
			G.AdjacentZones[aZone] = {};
		end
		G.AdjacentZones[aZone] = GFWTable.Merge(G.AdjacentZones[aZone], adjacentZones);
	end
	if (G.FlightZones == nil) then
		G.FlightZones = {};
	end
	for _, faction in pairs({FACTION_ALLIANCE, FACTION_HORDE}) do
		if (G.FlightZones[faction] == nil) then
			G.FlightZones[faction] = {};
		end
		for aZone, flightZones in pairs(tempFlightZones[faction]) do
			if (G.FlightZones[faction][aZone] == nil) then
				G.FlightZones[faction][aZone] = {};
			end
			G.FlightZones[faction][aZone] = GFWTable.Merge(G.FlightZones[faction][aZone], flightZones);
		end
	end

	-- Functions
	G.ConnectionsForZone = GFWZones_temp_ConnectionsForZone;
	
	-- Set version number
	G.Version = GFWZONES_THIS_VERSION;
end
