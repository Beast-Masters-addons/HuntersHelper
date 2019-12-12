------------------------------------------------------
-- GFWZones.lua
-- Utilities for working with geographic data 
------------------------------------------------------

GFWZONES_THIS_VERSION = 7;

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
	aZone = G.UnlocalizedZone(aZone);
	
	local zoneConnections = { };
	local _, myFaction = UnitFactionGroup("player");
	
	if not (G.AdjacentZones[aZone] or G.FlightZones[myFaction][aZone]) then return nil; end
	
	-- find zones one step away (adjacent to this zone or one flight/boat/zeppelin away)
	zoneConnections[1] = GFWTable.Merge(G.AdjacentZones[aZone], G.FlightZones[myFaction][aZone]);
	zoneConnections[1] = GFWTable.Subtract(zoneConnections[1], {aZone});
	
	-- then iterate to find zones more than one step away
	numSteps = 2;
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
	["Silithus"] = {"Un'goro Crater", "Gates of Ahn'Qiraj"},
	["Silverpine Forest"] = {"Tirisfal Glades", "Hillsbrad Foothills", "Alterac Mountains", "Shadowfang Keep"},
	["Stonetalon Mountains"] = {"Ashenvale", "The Barrens", "Desolace"},
	["Stormwind City"] = {"Elwynn Forest", "The Stockade"},
	["Stranglethorn Vale"] = {"Duskwood", "The Barrens", "Tirisfal Glades", "Durotar", "Zul'Gurub"}, -- boat, zeppelin
	["Swamp of Sorrows"] = {"Deadwind Pass", "Blasted Lands", "The Temple of Atal'Hakkar"},
	["Tanaris"] = {"Thousand Needles", "Un'Goro Crater", "Zul'Farrak", "Old Hillsbrad Foothills", "The Black Morass", "Hyjal Summit"},
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
	if (GFWZones.Localized == nil) then
		GFWZones.Localized = {};
	end
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
	G.LocalizedZone = GFWZones_temp_LocalizedZone;
	G.UnlocalizedZone = GFWZones_temp_UnlocalizedZone;
	G.ConnectionsForZone = GFWZones_temp_ConnectionsForZone;
	
	-- Set version number
	G.Version = GFWZONES_THIS_VERSION;
end

------------------------------------------------------
-- localized zone names (only those that differ from the enUS version should be present)
------------------------------------------------------

if ( GetLocale() == "deDE" ) then
	GFWZones.Localized["Alterac Mountains"] = "Das Alteracgebirge";
	GFWZones.Localized["Alterac Valley"] = "Alteractal";
	GFWZones.Localized["Arathi Basin"] = "Arathibecken";
	GFWZones.Localized["Arathi Highlands"] = "Das Arathihochland";
	GFWZones.Localized["Badlands"] = "Das Ödland";
	GFWZones.Localized["Blackfathom Deeps"] = "Blackfathom-Tiefe";
	GFWZones.Localized["Blackrock Depths"] = "Blackrocktiefen";
	GFWZones.Localized["Blackrock Mountain"] = "Der Blackrock";
	GFWZones.Localized["Blackrock Spire"] = "Blackrockspitze";
	GFWZones.Localized["Blasted Lands"] = "Die verwüsteten Lande";
	GFWZones.Localized["Burning Steppes"] = "Die brennende Steppe";
	GFWZones.Localized["Deeprun Tram"] = "Die Tiefenbahn";
	GFWZones.Localized["Dire Maul"] = "Düsterbruch";
	GFWZones.Localized["Dustwallow Marsh"] = "Die Marschen von Dustwallow";
	GFWZones.Localized["Eastern Plaguelands"] = "Die östlichen Pestländer";
	GFWZones.Localized["Elwynn Forest"] = "Der Wald von Elwynn";
	GFWZones.Localized["Hillsbrad Foothills"] = "Die Vorgebirge von Hillsbrad";
	GFWZones.Localized["Molten Core"] = "Geschmolzener Kern";
	GFWZones.Localized["Onyxia's Lair"] = "Onyxias Hort";
	GFWZones.Localized["Ragefire Chasm"] = "Ragefireabgrund";
	GFWZones.Localized["Razorfen Downs"] = "Die Hügel von Razorfen";
	GFWZones.Localized["Redridge Mountains"] = "Das Redridgegebirge";
	GFWZones.Localized["Scarlet Monastery"] = "Das scharlachrote Kloster";
	GFWZones.Localized["Searing Gorge"] = "Die Sengende Schlucht";
	GFWZones.Localized["Shadowfang Keep"] = "Burg Shadowfang";
	GFWZones.Localized["Silverpine Forest"] = "Der Silberwald";
	GFWZones.Localized["Stonetalon Mountains"] = "Das Steinkrallengebirge";
	GFWZones.Localized["Stormwind City"] = "Stormwind";
	GFWZones.Localized["Stranglethorn Vale"] = "Stranglethorn";
	GFWZones.Localized["Swamp of Sorrows"] = "Die Sümpfe des Elends";
	GFWZones.Localized["The Barrens"] = "Das Brachland";
	GFWZones.Localized["The Deadmines"] = "Die Todesminen";
	GFWZones.Localized["The Hinterlands"] = "Das Hinterland";
	GFWZones.Localized["The Stockade"] = "Die Palisade";
	GFWZones.Localized["Tirisfal Glades"] = "Tirisfal";
	GFWZones.Localized["Un'Goro Crater"] = "Der Un'Goro Krater";
	GFWZones.Localized["Wailing Caverns"] = "Die Höhlen des Wehklagens";
	GFWZones.Localized["Warsong Gulch"] = "Warsongschlucht";
	GFWZones.Localized["Western Plaguelands"] = "Die westlichen Pestländer";
	GFWZones.Localized["Wetlands"] = "Das Sumpfland";
end

if ( GetLocale() == "frFR" ) then
	GFWZones.Localized["Alterac Mountains"] = "Montagnes d'Alterac";
	GFWZones.Localized["Alterac Valley"] = "Vallée d'Alterac";
	GFWZones.Localized["Blackfathom Deeps"] = "Profondeurs de Blackfathom";
	GFWZones.Localized["Blackrock Depths"] = "Profondeurs de Blackrock";
	GFWZones.Localized["Blackrock Mountain"] = "Montagnes Blackrock";
	GFWZones.Localized["Blackrock Spire"] = "Pic de Blackrock";
	GFWZones.Localized["Burning Steppes"] = "Steppes Ardentes";
	GFWZones.Localized["Deeprun Tram"] = "Tramway des abysses";
	GFWZones.Localized["Dun Morogh"] = "Dun Modr";
	GFWZones.Localized["Dustwallow Marsh"] = "Marais de Dustwallow";
	GFWZones.Localized["Eastern Plaguelands"] = "Plaguelands de l'est";
	GFWZones.Localized["Elwynn Forest"] = "Forêt d'Elwynn";
	GFWZones.Localized["Hillsbrad Foothills"] = "Collines de Hillsbrad";
	GFWZones.Localized["Molten Core"] = "Noyau fondu";
	GFWZones.Localized["Onyxia's Lair"] = "Repère d'Onyxia";
	GFWZones.Localized["Ragefire Chasm"] = "Gouffre de Ragefire";
	GFWZones.Localized["Razorfen Downs"] = "Dunes de Razorfen";
	GFWZones.Localized["Redridge Mountains"] = "Montagnes de Redridge";
	GFWZones.Localized["Scarlet Monastery"] = "Monastère de la Phalange";
	GFWZones.Localized["Searing Gorge"] = "Gorge de Searing";
	GFWZones.Localized["Shadowfang Keep"] = "Donjon de Shadowfang";
	GFWZones.Localized["Silverpine Forest"] = "Forêt de Silverpine";
	GFWZones.Localized["Stonetalon Mountains"] = "Monts Stonetalon";
	GFWZones.Localized["Stormwind City"] = "Cité de Stormwind";
	GFWZones.Localized["Stranglethorn Vale"] = "Vallée de Stranglethorn";
	GFWZones.Localized["Swamp of Sorrows"] = "Marais des lamentations";
	GFWZones.Localized["The Barrens"] = "Les Barrens";
	GFWZones.Localized["The Deadmines"] = "Les Deadmines";
	GFWZones.Localized["The Hinterlands"] = "Les Hinterlands";
	GFWZones.Localized["The Stockade"] = "La Prison";
	GFWZones.Localized["Thousand Needles"] = "Mille pointes";
	GFWZones.Localized["Tirisfal Glades"] = "Prairies de Tirisfal";
	GFWZones.Localized["Un'Goro Crater"] = "Cratère d'Un'Goro";
	GFWZones.Localized["Wailing Caverns"] = "Cavernes des lamentations";
	GFWZones.Localized["Western Plaguelands"] = "Plaguelands de l'ouest";
end

if ( GetLocale() == "koKR" ) then
	GFWZones.Localized["Alterac Mountains"] = "알터랙 산맥";
	GFWZones.Localized["Arathi Highlands"] = "아라시 고원";
	GFWZones.Localized["Ashenvale"] = "잿빛 골짜기";
	GFWZones.Localized["Azshara"] = "아즈샤라";
	GFWZones.Localized["Badlands"] = "황야의 땅";
	GFWZones.Localized["Blackrock Depths"] = "검은바위 나락";
	GFWZones.Localized["Blasted Lands"] = "저주받은 땅";
	GFWZones.Localized["Burning Steppes"] = "이글거리는 협곡";
	GFWZones.Localized["Darkshore"] = "어둠의 해안";
	GFWZones.Localized["Darnassus"] = "다르나서스";
	GFWZones.Localized["Desolace"] = "잊혀진 땅";
	GFWZones.Localized["Dire Maul"] = "혈투의 전장";
	GFWZones.Localized["Dun Morogh"] = "던 모로";
	GFWZones.Localized["Durotar"] = "듀로타";
	GFWZones.Localized["Duskwood"] = "그늘숲";
	GFWZones.Localized["Eastern Plaguelands"] = "동부 역병지대";
	GFWZones.Localized["Elwynn Forest"] = "엘윈숲";
	GFWZones.Localized["Felwood"] = "악령의 숲";
	GFWZones.Localized["Feralas"] = "페랄라스";
	GFWZones.Localized["Gnomeregan"] = "놈리건";
	GFWZones.Localized["Hillsbrad Foothills"] = "힐스브래드 구릉지";
	GFWZones.Localized["Ironforge"] = "아이언포지";
	GFWZones.Localized["Loch Modan"] = "모단 호수";
	GFWZones.Localized["Moonglade"] = "달의 숲";
	GFWZones.Localized["Mulgore"] = "멀고어";
	GFWZones.Localized["Orgrimmar"] = "오그리마";
	GFWZones.Localized["Redridge Mountains"] = "붉은마루 산맥";
	GFWZones.Localized["Silithus"] = "실리더스";
	GFWZones.Localized["Silverpine Forest"] = "은빛 소나무숲";
	GFWZones.Localized["Stonetalon Mountains"] = "돌발톱 산맥";
	GFWZones.Localized["Stormwind City"] = "스톰윈드";
	GFWZones.Localized["Stranglethorn Vale"] = "가시덤불 골짜기";
	GFWZones.Localized["Swamp of Sorrows"] = "슬픔의 늪";
	GFWZones.Localized["Tanaris"] = "타나리스";
	GFWZones.Localized["Teldrassil"] = "텔드랏실";
	GFWZones.Localized["The Barrens"] = "불모의 땅";
	GFWZones.Localized["The Hinterlands"] = "동부 내륙지";
	GFWZones.Localized["Thousand Needles"] = "버섯구름 봉우리";
	GFWZones.Localized["Thunder Bluff"] = "썬더 블러프";
	GFWZones.Localized["Tirisfal Glades"] = "티리스팔 숲";
	GFWZones.Localized["Un'Goro Crater"] = "운고로 분화구";
	GFWZones.Localized["Undercity"] = "언더시티";
	GFWZones.Localized["Wailing Caverns"] = "통곡의 동굴";
	GFWZones.Localized["Western Plaguelands"] = "서부 역병지대";
	GFWZones.Localized["Westfall"] = "서부 몰락지대";
	GFWZones.Localized["Wetlands"] = "저습지";
end

if ( GetLocale() == "zhCN" ) then
	GFWZones.Localized["Alterac Mountains"] = "奥特兰克山脉";
	GFWZones.Localized["Arathi Highlands"] = "阿拉希高地";
	GFWZones.Localized["Ashenvale"] = "灰谷";
	GFWZones.Localized["Azshara"] = "艾萨拉";
	GFWZones.Localized["Badlands"] = "荒芜之地";
	GFWZones.Localized["Blackrock Depths"] = "黑石深渊";
	GFWZones.Localized["Blasted Lands"] = "诅咒之地";
	GFWZones.Localized["Burning Steppes"] = "燃烧平原";
	GFWZones.Localized["Darkshore"] = "黑海岸";
	GFWZones.Localized["Darnassus"] = "达纳苏斯";
	GFWZones.Localized["Desolace"] = "凄凉之地";
	GFWZones.Localized["Dire Maul"] = "厄运之槌";
	GFWZones.Localized["Dun Morogh"] = "丹莫罗";
	GFWZones.Localized["Durotar"] = "杜隆塔尔";
	GFWZones.Localized["Duskwood"] = " 	暮色森林";
	GFWZones.Localized["Eastern Plaguelands"] = "东瘟疫之地";
	GFWZones.Localized["Elwynn Forest"] = "艾尔文森林";
	GFWZones.Localized["Felwood"] = "费伍德森林";
	GFWZones.Localized["Feralas"] = "菲拉斯";
	GFWZones.Localized["Gnomeregan"] = "诺莫瑞根";
	GFWZones.Localized["Hillsbrad Foothills"] = "希尔斯布莱德丘陵";
	GFWZones.Localized["Ironforge"] = "铁炉堡";
	GFWZones.Localized["Loch Modan"] = "洛克莫丹";
	GFWZones.Localized["Moonglade"] = "月光林地";
	GFWZones.Localized["Mulgore"] = "莫高雷";
	GFWZones.Localized["Orgrimmar"] = "奥格瑞玛";
	GFWZones.Localized["Redridge Mountains"] = "赤脊山";
	GFWZones.Localized["Silithus"] = "希利苏斯";
	GFWZones.Localized["Silverpine Forest"] = "银松森林";
	GFWZones.Localized["Stonetalon Mountains"] = "石爪山脉";
	GFWZones.Localized["Stormwind City"] = "暴风城";
	GFWZones.Localized["Stranglethorn Vale"] = "荆棘谷";
	GFWZones.Localized["Swamp of Sorrows"] = "悲伤沼泽";
	GFWZones.Localized["Tanaris"] = "塔纳利斯";
	GFWZones.Localized["Teldrassil"] = "泰达希尔";
	GFWZones.Localized["The Barrens"] = "贫瘠之地";
	GFWZones.Localized["The Hinterlands"] = "辛特兰";
	GFWZones.Localized["Thousand Needles"] = "千针石林";
	GFWZones.Localized["Thunder Bluff"] = "雷霆崖";
	GFWZones.Localized["Tirisfal Glades"] = "提瑞斯法林地";
	GFWZones.Localized["Un'Goro Crater"] = "安戈洛环形山";
	GFWZones.Localized["Undercity"] = "幽暗城";
	GFWZones.Localized["Wailing Caverns"] = "哀嚎洞穴";
	GFWZones.Localized["Western Plaguelands"] = "西瘟疫之地";
	GFWZones.Localized["Westfall"] = "西部荒野";
	GFWZones.Localized["Wetlands"] = "湿地";
end

if ( GetLocale() == "zhTW" ) then
    	GFWZones.Localized["Ahn'Qiraj"] = "安其拉";
    	GFWZones.Localized["Alterac Mountains"] = "奧特蘭克山脈";
	GFWZones.Localized["Alterac Valley"] = "奧特蘭克山谷";
	GFWZones.Localized["Arathi Basin"] = "阿拉希盆地";
	GFWZones.Localized["Arathi Highlands"] = "阿拉希高地";
	GFWZones.Localized["Ashenvale"] = "梣谷";
	GFWZones.Localized["Azshara"] = "艾薩拉";
	GFWZones.Localized["Badlands"] = "荒蕪之地";
	GFWZones.Localized["Blackfathom Deeps"] = "黑暗深淵";
	GFWZones.Localized["Blackrock Depths"] = "黑石深淵";
	GFWZones.Localized["Blackrock Mountain"] = "黑石山";
	GFWZones.Localized["Blackrock Spire"] = "黑石塔";
	GFWZones.Localized["Blasted Lands"] = "詛咒之地";
	GFWZones.Localized["Burning Steppes"] = "燃燒平原";
    	GFWZones.Localized["Caverns of Time"] = "時光之穴";
    	GFWZones.Localized["Champions' Hall"] = "勇士大廳";
	GFWZones.Localized["Darkshore"] = "黑海岸";
	GFWZones.Localized["Darnassus"] = "達納蘇斯";
	GFWZones.Localized["Deadwind Pass"] = "逆風小徑";
	GFWZones.Localized["Deeprun Tram"] = "礦道地鐵";
	GFWZones.Localized["Desolace"] = "淒涼之地";
	GFWZones.Localized["Dire Maul"] = "厄運之槌";
	GFWZones.Localized["Dustwallow Marsh"] = "塵泥沼澤";
	GFWZones.Localized["Dun Morogh"] = "丹莫洛";
    	GFWZones.Localized["Durotar"] = "杜洛塔";
    	GFWZones.Localized["Duskwood"] = "暮色森林";
	GFWZones.Localized["Eastern Plaguelands"] = "東瘟疫之地";
	GFWZones.Localized["Elwynn Forest"] = "艾爾文森林";
    	GFWZones.Localized["Felwood"] = "費伍德森林";
    	GFWZones.Localized["Feralas"] = "菲拉斯";
    	GFWZones.Localized["Gates of Ahn'Qiraj"] = "安其拉之門";
    	GFWZones.Localized["Gnomeregan"] = "諾姆瑞根";
	GFWZones.Localized["Hillsbrad Foothills"] = "希爾斯布萊德丘陵";
    	GFWZones.Localized["Hall of Legends"] = "傳說大廳";
	GFWZones.Localized["Ironforge"] = "鐵爐堡";
    	GFWZones.Localized["Loch Modan"] = "洛克莫丹";
    	GFWZones.Localized["Maraudon"] = " 瑪拉頓";
	GFWZones.Localized["Molten Core"] = "熔火之心";
    	GFWZones.Localized["Moonglade"] = "月光林地";
    	GFWZones.Localized["Mulgore"] = "莫高雷";
    	GFWZones.Localized["Naxxramas"] = "納克薩瑪斯";
    	GFWZones.Localized["Orgrimmar"] = "奧格瑪";
	GFWZones.Localized["Onyxia's Lair"] = "奧妮克希亞的巢穴";
	GFWZones.Localized["Ragefire Chasm"] = "暗影裂口";
	GFWZones.Localized["Razorfen Downs"] = "剃刀高地";
	GFWZones.Localized["Redridge Mountains"] = "赤脊山";
    	GFWZones.Localized["Razorfen Kraul"] = "剃刀沼澤";
    	GFWZones.Localized["Ruins of Ahn'Qiraj"] = "安其拉廢墟";
	GFWZones.Localized["Scarlet Monastery"] = "血色修道院";
    	GFWZones.Localized["Scholomance"] = "通靈學院";
	GFWZones.Localized["Searing Gorge"] = "灼熱峽谷";
	GFWZones.Localized["Shadowfang Keep"] = "影牙城堡";
    	GFWZones.Localized["Stratholme"] = "斯坦索姆";
    	GFWZones.Localized["Silithus"] = "希利蘇斯";
	GFWZones.Localized["Silverpine Forest"] = "銀松森林";
	GFWZones.Localized["Stonetalon Mountains"] = "石爪山脈";
	GFWZones.Localized["Stormwind City"] = "暴風城";
	GFWZones.Localized["Stranglethorn Vale"] = "荊棘谷";
	GFWZones.Localized["Swamp of Sorrows"] = "悲傷沼澤";
    	GFWZones.Localized["Tanaris"] = "塔納利斯";
    	GFWZones.Localized["Teldrassil"] ="泰達希爾";
	GFWZones.Localized["The Barrens"] = "貧瘠之地";
	GFWZones.Localized["The Deadmines"] = "死亡礦坑";
	GFWZones.Localized["The Hinterlands"] = "辛特蘭";
	GFWZones.Localized["The Stockade"] = "監獄";
    	GFWZones.Localized["The Temple of Atal'Hakkar"] ="阿塔哈卡神廟";
    	GFWZones.Localized["Thousand Needles"] = "千針石林";
    	GFWZones.Localized["Thunder Bluff"] = "雷霆崖";
	GFWZones.Localized["Tirisfal Glades"] = "提里斯法林地";
	GFWZones.Localized["Un'Goro Crater"] = "安戈洛環形山";
    	GFWZones.Localized["Undercity"] = "幽暗城";
    	GFWZones.Localized["Uldaman"] = "奧達曼";
	GFWZones.Localized["Wailing Caverns"] = "哀嚎洞穴";
	GFWZones.Localized["Warsong Gulch"] = "戰歌峽谷";
    	GFWZones.Localized["Westfall"] = "西部荒野";
	GFWZones.Localized["Western Plaguelands"] = "西瘟疫之地";
	GFWZones.Localized["Wetlands"] = "濕地";
    	GFWZones.Localized["Winterspring"] = "冬泉谷";
    	GFWZones.Localized["Zul'Farrak"] = "祖爾法拉克";
    	GFWZones.Localized["Zul'Gurub"] = "祖爾格拉布";

	-- Burning Crusade Azeroth content
    	GFWZones.Localized["Ghostlands"] = "鬼魂之地";
    	GFWZones.Localized["Silvermoon City"] = "銀月城";
    	GFWZones.Localized["Eversong Woods"] = "永歌森林";
    	GFWZones.Localized["Azuremyst Isle"] = "藍謎島";
    	GFWZones.Localized["Bloodmyst Isle"] = "血謎島";
    	GFWZones.Localized["The Exodar"] = "艾克索達";

	-- Burning Crusade Outland content
    	GFWZones.Localized["Hellfire Peninsula"] = "地獄火半島";
    	GFWZones.Localized["Zangarmarsh"] = "贊格沼澤";
    	GFWZones.Localized["Nagrand"] = "納葛蘭";
    	GFWZones.Localized["Terokkar Forest"] = "泰洛卡森林";
    	GFWZones.Localized["Shattrath City"] = "撒塔斯城";
    	GFWZones.Localized["Shadowmoon Valley"] = "影月谷";
    	GFWZones.Localized["Blade's Edge Mountains"] = "劍刃山脈";
    	GFWZones.Localized["Netherstorm"] = "虛空風暴";

	-- Burning Crusade instances
    	GFWZones.Localized["Hellfire Ramparts"] = "地獄火壁壘";
    	GFWZones.Localized["The Blood Furnace"] = "血熔爐";
    	GFWZones.Localized["The Shattered Halls"] = "破碎大廳";
    	GFWZones.Localized["Magtheridon's Lair"] = "麥格賽立頓的巢穴";
    	GFWZones.Localized["The Underbog"] = "毒牙沼澤";
    	GFWZones.Localized["The Slave Pens"] = "奴隸監獄";
    	GFWZones.Localized["The Steamvault"] = "蒸汽洞窟";
    	GFWZones.Localized["Serpentshrine Cavern"] = "毒蛇神殿洞穴";
    	GFWZones.Localized["Auchenai Crypts"] = "奧奇奈地穴";
    	GFWZones.Localized["Mana Tombs"] = "法力墓地";
    	GFWZones.Localized["Sethekk Halls"] = "塞司克大廳";
    	GFWZones.Localized["Shadow Labyrinth"] = "暗影迷宮";

    	GFWZones.Localized["The Mechanar"] = "麥克那爾";
    	GFWZones.Localized["The Botanica"] = "波塔尼卡";
    	GFWZones.Localized["The Arcatraz"] = "亞克崔茲";
    	GFWZones.Localized["Tempest Keep"] = "風暴要塞";

    	GFWZones.Localized["Gruul's Lair"] = "戈魯爾之巢";
	
    	GFWZones.Localized["Old Hillsbrad Foothills"] = "老希爾斯布萊德丘陵";
    	GFWZones.Localized["The Black Morass"] = "黑色沼澤";
	
    	GFWZones.Localized["Karazhan"] = "卡拉贊";

end

