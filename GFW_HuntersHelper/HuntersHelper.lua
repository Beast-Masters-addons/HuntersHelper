------------------------------------------------------
-- HuntersHelper.lua
------------------------------------------------------
local ADDON_NAME = "GFW_HuntersHelper"

-- Saved configuration & info
FHH_KnownSpells = {};

FHH_Options = {};
FHH_Defaults = {
	NoBeastTooltip = false,
	BeastTooltipOnlyHunter = false,
	ShowMinimap = false,
	MinimapPosition = 260,
	ShowAlreadyKnownBeasts = false,
	NoUITooltip = false,
};

-- Runtime state
FHH_State = { };
FHH_State.TamingCritter = nil;
FHH_State.TamingType = nil;
FHH_UISpellCraftIndices = {};

-- Constants
MAX_REPORTED_ZONES = 4;
FHH_NonSpellKeys = {
	t=1,
	f=1,
	z=1,
	min=1,
	max=1,
};

function CraftIsPetTraining()
	if GetCraftButtonToken() == 'TRAIN' then
		return true
	else
		return false
	end
end

function FHH_OnLoad(self)
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("ADDON_LOADED");
    self:RegisterEvent("UPDATE_MOUSEOVER_UNIT");

	-- Register Slash Commands
	SLASH_FHH1 = "/huntershelper";
	SLASH_FHH2 = "/hh";
	SlashCmdList["FHH"] = function(msg)
		FHH_ChatCommandHandler(msg);
	end
	
end

function FHH_OnEvent(self, event, ...)
	local arg1 = ...
	--DevTools_Dump({event=event, arg1=arg1, arg2=arg2, arg3=arg3, arg4=arg4, arg5=arg5, arg6=arg6, arg7=arg7, arg8=arg8, arg9=arg9});

	if ( event == "PLAYER_ENTERING_WORLD" or (event == "ADDON_LOADED" and arg1 == ADDON_NAME)) then
		
		FHH_GenerateSpellNamesToTokens();

		_, realClass = UnitClass("player");
		if (realClass == "HUNTER") then
			-- only do stuff related to taming and checking hunter spells if you're a hunter.
			self:RegisterEvent("UNIT_AURA");
			self:RegisterEvent("UNIT_NAME_UPDATE");
			self:RegisterEvent("CRAFT_SHOW");
			self:RegisterEvent("CRAFT_UPDATE");
			self:RegisterEvent("CRAFT_CLOSE");
			self:RegisterEvent("CHAT_MSG_SYSTEM");

			if (FHH_KnownSpells == nil or GFWTable.Count(FHH_KnownSpells) == 0) then
				if (loadable and realClass == "HUNTER" and UnitLevel("player") >= 10) then
					-- find Beast Training 
					local _, _, startIndex, endIndex = GetSpellTabInfo(1);
					-- it's always on the General tab
					for spellIndex = startIndex + 1, endIndex do
						-- and it has the same icon in all locales
						if (GetSpellTexture(spellIndex, BOOKTYPE_SPELL) == "Interface\\Icons\\Ability_Hunter_BeastCall02") then
							GFWUtils.Print(FHH_NEED_SPELL_INFO);
							break;
						end
					end
				end
			end
			FHH_MinimapButtonCheck();
		end
		self:UnregisterEvent("ADDON_LOADED");
		
	elseif ( event == "UPDATE_MOUSEOVER_UNIT" ) then
	
		if ( UnitExists("mouseover") and not UnitPlayerControlled("mouseover") and not FHH_Options.NoBeastTooltip ) then

			local _, myClass = UnitClass("player");
			if (FHH_Options.BeastTooltipOnlyHunter and myClass ~= "HUNTER") then return; end
			
			FHH_ModifyTooltip("mouseover");

		end
		
	elseif ( event == "UNIT_AURA" ) then
	
		if ( arg1 == "player" and FHH_HasTameEffect("player") ) then
			FHH_State.TamingCritter = UnitName("target");
			local unlocalizedCreepName = GFWTable.KeyOf(FHH_Localized, FHH_State.TamingCritter);
			if (unlocalizedCreepName) then
				FHH_State.TamingCritter = unlocalizedCreepName;
			end
			FHH_State.TamingType = UnitClassification("target");
		end
			
	elseif ( event == "UNIT_NAME_UPDATE" ) then
	
		if ( arg1 == "pet" and FHH_State.TamingCritter ) then
			local loyaltyDescription = GetPetLoyalty();
			if (loyaltyDescription) then
				local _, _, loyaltyLevel = string.find(loyaltyDescription, "(%d+)");
				if (tonumber(loyaltyLevel) and tonumber(loyaltyLevel) > 1) then
					GFWUtils.Print("Got "..event.." but pet's loyalty > 1; ignoring.");
					FHH_State.TamingCritter = nil;
					FHH_State.TamingType = nil;
					return;
				end		
			end
			if (UnitName("pet") ~= UnitCreatureFamily("pet")) then
				GFWUtils.Print("Got "..event.." but pet's UnitName() ~= UnitCreatureFamily(); ignoring.");
				FHH_State.TamingCritter = nil;
				FHH_State.TamingType = nil;
				return;
			end
			--GFWUtils.Print(event..": checking newly tamed pet");
			FHH_CheckPetSpells();
			FHH_State.TamingCritter = nil;
			FHH_State.TamingType = nil;
		end

	elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
		
		FHH_MinimapUpdateCount(true);
		
	elseif ( event == "CRAFT_SHOW" and not BT_Version) then

		local _, _, _, _, loadable, _, _ = GetAddOnInfo("GFW_HuntersHelperUI");
		if (loadable and CraftIsPetTraining()) then
			if (not IsAddOnLoaded("GFW_HuntersHelperUI")) then
				UIParentLoadAddOn("GFW_HuntersHelperUI");
			end
			FHH_HideCraftFrame(self);
			FHH_ScanCraftFrame();
			ShowUIPanel(FHH_UI);
			FHH_ReplacingCraftFrame = true;
		else
			FHH_RestoreCraftFrame();
			FHH_ReplacingCraftFrame = nil;
		end

	elseif ( event == "CRAFT_UPDATE" ) then

		if (CraftIsPetTraining()) then
			FHH_ScanCraftFrame();
		end

	elseif ( event == "CRAFT_CLOSE" and FHH_ReplacingCraftFrame) then
		
		if (IsAddOnLoaded("GFW_HuntersHelperUI")) then
			HideUIPanel(FHH_UI);
		end
		
	elseif ( event == "CHAT_MSG_SYSTEM" ) then

		local pattern = GFWUtils.FormatToPattern(ERR_LEARN_SPELL_S); -- "You have learned a new spell: %s."
		local _, _, compositeSpellName = string.find(arg1, pattern);
		if (compositeSpellName == nil) then return; end
		
		local _, _, spellName, rankNum = string.find(compositeSpellName, "(.+) %(.+ (%d+)%)");
		if (spellName and rankNum and spellName ~= "" and rankNum ~= "" ) then
			spellName = string.gsub(spellName, "^%s+", ""); -- strip leading spaces
			spellName = string.gsub(spellName, "%s+$", ""); -- and trailing spaces
			rankNum = tonumber(rankNum);
			local token = FHH_SpellTokenforName(spellName);
			if (FHH_NewInfo and FHH_NewInfo.SpellTokenAliases and FHH_NewInfo.SpellTokenAliases[token]) then
				token = FHH_NewInfo.SpellTokenAliases[token];
			end
			if (token and (FHH_RequiredLevel[token] or (FHH_NewInfo and FHH_NewInfo.RequiredLevel and FHH_NewInfo.RequiredLevel[token]))) then
				-- only track spells we know are hunter pet spells
				if (FHH_KnownSpells == nil) then
					FHH_KnownSpells = {};
				end
				if (FHH_KnownSpells[token] == nil) then
					FHH_KnownSpells[token] = {};
				end			
				if (rankNum and not FHH_KnownSpells[token][rankNum]) then
					FHH_KnownSpells[token][rankNum] = 1;
				end
			end
		end
		
	end

end

function FHH_ChatCommandHandler(msg)

	if (msg == "") then
		if (not FHH_ShowUI()) then
			FHH_ChatCommandHandler("help");
		end
		return;
	end
	
	if ( msg == "help" ) then
		local title = GetAddOnMetadata(ADDON_NAME, "Title");
		local version = GetAddOnMetadata(ADDON_NAME, "Version");
		GFWUtils.Print(title.." "..version..":");
		
		GFWUtils.Print(GFWUtils.Hilite(GFWUtils.Hilite(SLASH_FHH1).." | "..GFWUtils.Hilite(SLASH_FHH2)).." - "..FHH_HELP_SHOWUI);
		GFWUtils.Print(GFWUtils.Hilite(GFWUtils.Hilite(SLASH_FHH1).." | "..GFWUtils.Hilite(SLASH_FHH2)).." <command> ");
		GFWUtils.Print("/huntershelper /hh <command>");
		GFWUtils.Print("- "..GFWUtils.Hilite("help").." - "..FHH_HELP_HELP);
		GFWUtils.Print("- "..GFWUtils.Hilite("on").." | "..GFWUtils.Hilite("off").." | "..GFWUtils.Hilite("onlyhunter").." - "..FHH_HELP_TOOLTIP);
		GFWUtils.Print("- "..GFWUtils.Hilite("button").." | "..GFWUtils.Hilite("minimap").." - "..FHH_HELP_MINIMAP);
		GFWUtils.Print("- "..GFWUtils.Hilite("reset").." - "..FHH_HELP_RESET);
		GFWUtils.Print("- "..GFWUtils.Hilite("status").." - "..FHH_HELP_STATUS);
		GFWUtils.Print("- "..GFWUtils.Hilite("find <ability> <rank>").." - "..FHH_HELP_FIND);
		return;
	end

	if (msg == "version") then
		local title = GetAddOnMetadata(ADDON_NAME, "Title");
		local version = GetAddOnMetadata(ADDON_NAME, "Version");
		GFWUtils.Print(title.." "..version);
		return;
	end
		
	if (msg == "onlyhunter") then
		FHH_Options.NoBeastTooltip = nil;
		FHH_Options.BeastTooltipOnlyHunter = true;
		GFWUtils.Print(FHH_STATUS_ONLYHUNTER);
		return;
	end
	if (msg == "on") then
		FHH_Options.NoBeastTooltip = nil;
		FHH_Options.BeastTooltipOnlyHunter = nil;
		GFWUtils.Print(FHH_STATUS_ON);
		return;
	end
	if (msg == "off") then
		FHH_Options.NoBeastTooltip = true;
		GFWUtils.Print(FHH_STATUS_OFF);
		return;
	end

	if (msg == "button" or msg == "minimap") then
		FHH_Options.ShowMinimap = not FHH_Options.ShowMinimap;
		FHH_MinimapButtonCheck();
		return;
	end

	if ( msg == "status" ) then
		if ( not FHH_Options.NoBeastTooltip and FHH_Options.BeastTooltipOnlyHunter ) then
			GFWUtils.Print(FHH_STATUS_ONLYHUNTER);
		elseif ( FHH_Options.NoBeastTooltip ) then
			GFWUtils.Print(FHH_STATUS_OFF);
		else
			GFWUtils.Print(FHH_STATUS_ON);
		end
		return;
	end
	
	if (msg == "reset") then
		FHH_NewInfo = nil;	
		FHH_KnownSpells = {};
		GFW_HuntersHelper.db:ResetProfile();
		
		GFWUtils.Print(FHH_STATUS_RESET);
	
		if (CraftIsPetTraining()) then
			FHH_ScanCraftFrame();
		else
			GFWUtils.Print(FHH_NEED_SPELL_INFO);
		end
		
		return;
	end
				
	if (msg == "dynamic") then
		FHH_SpellNamesToTokens = {};
		FHH_LearnableBy = {};
		FHH_RequiredLevel = {};
		FHH_BeastInfo = {};
		GFWUtils.Print("Hunter's Helper: only consulting dynamic tables until next reload.");
		return;
	end
		
	local _, _, cmd, spellQuery, rankNum = string.find(msg, "(find%w*) ([^%d]+) *(%d*)");
	if (cmd == "find" or cmd == "findall") then
		if (spellQuery == nil or spellQuery == "") then
			GFWUtils.Print("Usage: "..GFWUtils.Hilite("/hh find <ability> <rank>"));
			return;
		end
		
		spellQuery = string.gsub(spellQuery, "^%s+", ""); -- strip leading spaces
		spellQuery = string.gsub(spellQuery, "%s+$", ""); -- and trailing spaces
		spellQuery = string.lower(spellQuery);
		local spellToken;
		-- first, look up the input against our spell ID keys
		if (FHH_RequiredLevel[spellQuery]) then
			spellToken = spellQuery;
		end
		if (spellToken == nil and FHH_NewInfo and FHH_NewInfo.SpellTokensToNames and FHH_NewInfo.SpellTokensToNames[spellQuery]) then
			spellToken = spellQuery;
		end

		-- failing that, try looking it up as a proper name, case insensitively
		if (spellToken == nil) then
			for properName in pairs(FHH_SpellNamesToTokens) do
				if (string.lower(properName) == spellQuery) then
					spellToken = FHH_SpellNamesToTokens[properName];
				end
			end
			if (spellToken == nil and FHH_NewInfo and FHH_NewInfo.SpellNamesToTokens) then
				for properName in pairs(FHH_NewInfo.SpellNamesToTokens) do
					if (string.lower(properName) == spellQuery) then
						spellToken = FHH_NewInfo.SpellNamesToTokens[properName];
					end
				end
			end
		end
		
		if (spellToken == nil) then
			GFWUtils.Print(format(FHH_FIND_SPELL_UNKNOWN, GFWUtils.Hilite(spellQuery)));
			return;
		end
		FHH_Find(spellToken, rankNum);
		return;
	end
	
	-- if we got all the way to here, we got invalid input.
	FHH_ChatCommandHandler("help");
	
end

function FHH_ShowUI()
	local _, _, _, _, loadable, _, _ = GetAddOnInfo("GFW_HuntersHelperUI");

	if (not BT_Version ) then
		-- don't replace the training window if Awbee's BeastTraining mod already is
		
		_, realClass = UnitClass("player");
		if (loadable and realClass == "HUNTER" and UnitLevel("player") >= 10) then
			-- find Beast Training and cast it if we can
			-- this shows our UI and lets it get info from Craft APIs / substitute for the Training window
			local _, _, startIndex, endIndex = GetSpellTabInfo(1);
			-- it's always on the General tab
			for spellIndex = startIndex + 1, endIndex do
				-- and it has the same icon in all locales
				if (GetSpellTexture(spellIndex, BOOKTYPE_SPELL) == "Interface\\Icons\\Ability_Hunter_BeastCall02") then
					CastSpell(spellIndex, BOOKTYPE_SPELL);	
					-- this API isn't protected for "casting" the "spell" that opens a craft/tradeskills window
					return true;
				end
			end
		end
	end

	-- if we can't do that, just show the UI and it'll be in "dumb" (not hooked up to Craft API) mode
	if (loadable and not IsAddOnLoaded("GFW_HuntersHelperUI")) then
		UIParentLoadAddOn("GFW_HuntersHelperUI");
	end
	if (IsAddOnLoaded("GFW_HuntersHelperUI")) then
		-- without the CraftFrame around, we should set things up so our layout gets handled right
		FHH_UI:SetAttribute("UIPanelLayout-defined", true)
		FHH_UI:SetAttribute("UIPanelLayout-enabled", true)
		FHH_UI:SetAttribute("UIPanelLayout-area", "left")
		FHH_UI:SetAttribute("UIPanelLayout-pushable", 7)
		FHH_UI:SetAttribute("UIPanelLayout-whileDead", true)
		
		ShowUIPanel(FHH_UI);
		FHH_ReplacingCraftFrame = nil;
		return true;
	end
	
end

function FHH_MinimapButtonCheck()
	if (FHH_MinimapFrame) then
		if (FHH_Options.ShowMinimap) then
			FHH_MinimapFrame:Show();
			FHH_MoveMinimapButton();
			FHH_MinimapUpdateCount();
			FHH_MinimapFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
		else
			FHH_MinimapFrame:Hide();
			FHH_MinimapFrame:UnregisterEvent("ZONE_CHANGED_NEW_AREA");
		end
	end
end

function FHH_MinimapUpdateCount(shouldShine)
	local zoneCritters = FHH_CurrentZoneLearnableBeasts();
	if (#zoneCritters > 0) then
		FHH_MinimapCount:SetText(#zoneCritters);
		FHH_MinimapFrame_Icon:SetVertexColor(0.5,0.5,0.5);
		FHH_MinimapCount:Show();
		if (shouldShine) then
			FHH_MinimapShineFadeIn();
		end
	else
		FHH_MinimapFrame_Icon:SetVertexColor(1,1,1);
		FHH_MinimapCount:Hide();
	end
end

function FHH_MinimapButtonTooltip()

	local title = GetAddOnMetadata(ADDON_NAME, "Title");
	local version = GetAddOnMetadata(ADDON_NAME, "Version");
	GameTooltip:SetText(title .. " " .. version);
	
	local zoneCritters = FHH_CurrentZoneLearnableBeasts();
	local color;
	if (#zoneCritters > 0) then
		color = HIGHLIGHT_FONT_COLOR;
		GameTooltip:AddLine(format(FHH_NUM_BEASTS_IN_ZONE, #zoneCritters), color.r, color.g, color.b);
		
		for _, beastName in pairs(zoneCritters) do
			local beastString = (FHH_Localized[beastName] or beastName).." (";
			local info = FHH_BeastInfo[beastName];
			if (info.min > UnitLevel("player")) then
				beastString = beastString..RED_FONT_COLOR_CODE..info.min..FONT_COLOR_CODE_CLOSE;
			else
				beastString = beastString..info.min;
			end
			if (info.max) then
				if (info.max > UnitLevel("player")) then
					beastString = beastString.."-"..RED_FONT_COLOR_CODE..info.max..FONT_COLOR_CODE_CLOSE;
				else
					beastString = beastString.."-"..info.max;
				end
			end
			if (info.t == nil) then
				beastString = beastString..")";
			elseif (info.t == 1) then	-- Elite
				beastString = beastString.." "..ELITE..")";
			elseif (info.t == 2) then	-- Rare
				beastString = beastString.." "..FHH_UI_RARE_MOB..")";
			elseif (info.t == 3) then	-- Rare Elite
				beastString = beastString.." "..FHH_UI_RARE_ELITE_MOB..")";
			end
			
			for spellToken, rank in GFWTable.PairsByKeys(info) do
				if (not FHH_NonSpellKeys[spellToken]) then
					local spellColor;
					if (FHH_KnownSpells[spellToken] and (rank == nil or FHH_KnownSpells[spellToken][rank])) then
						spellColor = GRAY_FONT_COLOR;
					else
						spellColor = GREEN_FONT_COLOR;
					end
					GameTooltip:AddDoubleLine(beastString, FHH_SpellDescription(spellToken, rank, true),
						color.r, color.g, color.b, spellColor.r, spellColor.g, spellColor.b);
					beastString = " ";
				end
			end
		end
	else
		color = GRAY_FONT_COLOR;
		GameTooltip:AddLine(format(FHH_NUM_BEASTS_IN_ZONE, 0), color.r, color.g, color.b);
	end
	GameTooltip:Show();
	
end

function FHH_ModifyTooltip(unit)
	local creepName = UnitName(unit);
	local creepLevel = UnitLevel(unit);
	local creepFamily = UnitCreatureFamily(unit);
	local creepType = UnitClassification(unit);
	local abilitiesLine;

	local unlocalizedCreepName = GFWTable.KeyOf(FHH_Localized, creepName);
	if (unlocalizedCreepName) then
		creepName = unlocalizedCreepName;
	end
	
	-- if this beast is in our database, make sure we have the right level range & type info
	FHH_CheckBeastLevel(creepName, creepLevel, creepType);

	-- if this is a Beast Lore tooltip, parse out and use its tamed abilities info
	if (FHH_TAMED_ABILS_PATTERN == nil) then
		FHH_TAMED_ABILS_PATTERN = GFWUtils.FormatToPattern(PET_SPELLS_TEMPLATE);
	end
	for lineNum = 1, GameTooltip:NumLines() do
		local lineText = getglobal("GameTooltipTextLeft"..lineNum):GetText();
		if (lineText) then 
			if (string.find(lineText, LIGHTYELLOW_FONT_COLOR_CODE)) then
				return; -- if we've already added a line to this tooltip, we should stop.
			end
			local _, _, beastLoreInfo = string.find(lineText, FHH_TAMED_ABILS_PATTERN);
			if (beastLoreInfo) then
				abilitiesLine = lineNum;
				local beastLoreList = {strsplit(",", beastLoreInfo)};
				local beastSpellTable = {};
				for _, niceSpellName in pairs(beastLoreList) do
					if (niceSpellName ~= "") then
						local _, _, spellName, rankNum = string.find(niceSpellName, "^(.+) %(.+ (%d+)%)$");
						if (spellName == nil or spellName == "" or tonumber(rankNum) == nil) then
							local critter = '' --TODO: Check this message
							GFWUtils.PrintOnce(GFWUtils.Red("Hunter's Helper Error: ").."Can't parse spell "..GFWUtils.Hilite(niceSpellName).." from "..GFWUtils.Hilite(critter)..".");
						else
							spellName = string.gsub(spellName, "^%s+", ""); -- strip leading spaces
							spellName = string.gsub(spellName, "%s+$", ""); -- and trailing spaces
							local spellToken = FHH_SpellTokenforName(spellName);
							if (FHH_NewInfo and FHH_NewInfo.SpellTokenAliases and FHH_NewInfo.SpellTokenAliases[spellToken]) then
								spellToken = FHH_NewInfo.SpellTokenAliases[spellToken];
							end
							if (spellToken == nil) then
								spellToken = FHH_RecordNewSpellToken(spellName, true);
							end
							if (not FHH_TrainerSpells[spellToken]) then
								beastSpellTable[spellToken] = tonumber(rankNum);
							end
						end
					end
				end
				FHH_CheckSpellTables(creepName, beastSpellTable, creepLevel, creepFamily);
			end
		end
	end

	-- look up the list of abilities we think this critter has
	local abilitiesList;
	if (FHH_NewInfo and FHH_NewInfo.BeastInfo and FHH_NewInfo.BeastInfo[creepName]) then
		abilitiesList = FHH_NewInfo.BeastInfo[creepName];
	elseif (FHH_BeastInfo[creepName]) then
		abilitiesList = FHH_BeastInfo[creepName];
		if (FHH_NewInfo and FHH_NewInfo.BadBeastInfo and FHH_NewInfo.BadBeastInfo[creepName]) then
			local newAbilitiesList = {};
			for spellToken, rankNum in pairs(abilitiesList) do
				if (FHH_NewInfo.BadBeastInfo[creepName][spellToken] ~= rankNum) then
					newAbilitiesList[spellToken] = rankNum;
				end
			end
			abilitiesList = newAbilitiesList;
		end
	end
			
	if (abilitiesList and GFWTable.Count(abilitiesList) > 0) then
	
		-- build textual description from that list (with color coding if you're a hunter)
		local coloredList = {};
		local _, myClass = UnitClass("player");
		for spellName, rankNum in pairs(abilitiesList) do
			-- this table also has k/v pairs for zone, level, and type now, let's not print those
			if (not FHH_NonSpellKeys[spellName]) then
				if (myClass == "HUNTER" and FHH_KnownSpells and GFWTable.Count(FHH_KnownSpells) > 0) then
					if (FHH_KnownSpells[spellName] and FHH_KnownSpells[spellName][rankNum]) then
						table.insert(coloredList, GRAY_FONT_COLOR_CODE..FHH_SpellDescription(spellName, rankNum)..FONT_COLOR_CODE_CLOSE);
					else
						table.insert(coloredList, GREEN_FONT_COLOR_CODE..FHH_SpellDescription(spellName, rankNum)..FONT_COLOR_CODE_CLOSE);
					end
				else
					table.insert(coloredList, FHH_SpellDescription(spellName, rankNum));
				end
			end
		end
		local abilitiesText = table.concat(coloredList, ", ");
		abilitiesText = string.gsub(abilitiesText, "( %d+)", " ("..RANK.."%1)");
	
		-- add it to the tooltip (or, if Beast Lore, replace its line with our color-coded one)
		if (abilitiesLine) then
			local lineText = getglobal("GameTooltipTextLeft"..abilitiesLine);
			lineText:SetText(GFWUtils.LtY(string.format(PET_SPELLS_TEMPLATE, abilitiesText)));
		else
			GameTooltip:AddLine(GFWUtils.LtY(string.format(PET_SPELLS_TEMPLATE, abilitiesText)), 1.0, 1.0, 1.0);
			GameTooltip:SetHeight(GameTooltip:GetHeight() + 14);
			local width = 20 + getglobal(GameTooltip:GetName().."TextLeft"..GameTooltip:NumLines()):GetWidth();
			if ( GameTooltip:GetWidth() < width ) then
				GameTooltip:SetWidth(width);
			end
		end
	end

end

function FHH_ScanCraftFrame()

	if (not CraftFrame or not CraftFrame:IsVisible()) then return; end
	local numCrafts = GetNumCrafts();

	FHH_KnownSpells = {};
	FHH_UISpellCraftIndices = {};
	FHH_PetKnownSpellRanks = {};
	
	for craftIndex = 1, numCrafts do
		local craftName, craftSubSpellName, craftType, _, _, _, requiredLevel = GetCraftInfo(craftIndex);
		if not craftSubSpellName then
			return
		end
		local _, _, rankNum = string.find(craftSubSpellName, "(%d+)");
		if (rankNum and tonumber(rankNum)) then
			rankNum = tonumber(rankNum);
		end
		local craftIconId = GetCraftIcon(craftIndex);
		local spellToken = FHH_SpellTokenForIcon(craftIconId, craftName);
		local nameSpellToken = FHH_SpellTokenforName(craftName);
		if (spellToken and nameSpellToken and spellToken ~= nameSpellToken) then
			if (FHH_NewInfo == nil) then
				FHH_NewInfo = {};
			end
			if (FHH_NewInfo.SpellTokenAliases == nil) then
				FHH_NewInfo.SpellTokenAliases = {};
			end
			FHH_NewInfo.SpellTokenAliases[nameSpellToken] = spellToken;
		end

		if (FHH_KnownSpells[spellToken] == nil) then
			FHH_KnownSpells[spellToken] = {};
		end
		if (craftType == "used") then
			FHH_PetKnownSpellRanks[spellToken] = 0;
		end
		
		if (rankNum) then
			if (FHH_UISpellCraftIndices[spellToken] == nil) then
				FHH_UISpellCraftIndices[spellToken] = {};
			end
			FHH_KnownSpells[spellToken][rankNum] = 1;
			FHH_UISpellCraftIndices[spellToken][rankNum] = craftIndex;
			if (craftType == "used") then
				FHH_PetKnownSpellRanks[spellToken] = math.max(FHH_PetKnownSpellRanks[spellToken], rankNum);
			end
		else
			FHH_UISpellCraftIndices[spellToken] = craftIndex;
		end
		if ( requiredLevel and requiredLevel > 0 ) then
			FHH_RecordNewRequiredLevel(spellToken, tonumber(rankNum), requiredLevel, true);
		end
	end
	FHH_ProcessAliases();
	FHH_MinimapUpdateCount();
	if (FHH_UI and FHH_UI:IsVisible()) then
		FHH_UIUpdateList();
		FHH_UIUpdateDisplayList();
		FHH_UISetSelection(FHH_UIListSelectionIndex, FHH_UISelectedRank);
		FHH_UIUpdate();
	end
end

------------------------------------------------------
-- CraftFrame replacement

-- If we try to hide the CraftFrame, its OnHide handler will call CloseCraft(),
-- which causes the Craft APIs to stop providing the hooks we need into Beast Training.
-- Since our frame is the same size and shape as the CraftFrame, we just
-- make the CraftFrame transparent, bury it at a strata below our frame, and
-- attach our frame to it.

FHH_CraftFrameSettings = {};

function FHH_HideCraftFrame(self)
	if not FHH_UI then
		return
	end
	if (not FHH_CraftFrameSettings.hidden) then
		FHH_CraftFrameSettings.hidden = true;
	    FHH_CraftFrameSettings.strata = CraftFrame:GetFrameStrata();
	    FHH_CraftFrameSettings.alpha  = CraftFrame:GetAlpha();
	
	    CraftFrame:SetAlpha(0);
	    CraftFrame:SetFrameStrata("BACKGROUND");
		FHH_UI:SetPoint("TOPLEFT", CraftFrame, "TOPLEFT", 0, 0);
		if (not GFWTable.KeyOf(UISpecialFrames, "FHH_UI")) then
			-- with our position tied to the CraftFrame's, we just need to make sure we're closable with esc
			table.insert(UISpecialFrames, self:GetName());
		end
	end
end

function FHH_RestoreCraftFrame()
	FHH_CraftFrameSettings.hidden = false;
    if FHH_CraftFrameSettings.alpha then
        CraftFrame:SetAlpha(FHH_CraftFrameSettings.alpha)
    end
    if FHH_CraftFrameSettings.strata then
        CraftFrame:SetFrameStrata(FHH_CraftFrameSettings.strata)
    end
	if (FHH_UI) then
		FHH_UI:Hide();
	end
end

------------------------------------------------------

function FHH_Find(spellToken, rankNum)
	local niceSpellName = FHH_NameForSpellToken(spellToken);
	if (niceSpellName == nil and FHH_NewInfo and FHH_NewInfo.SpellTokensToNames and FHH_NewInfo.SpellTokensToNames[spellToken]) then
		niceSpellName = FHH_NewInfo.SpellTokensToNames[spellToken];
	end
	
	local rankTable = FHH_RequiredLevel[spellToken];
	local newRankTable;
	if (FHH_NewInfo and FHH_NewInfo.RequiredLevel) then
		newRankTable = FHH_NewInfo.RequiredLevel[spellToken];
	end
	if (rankTable == nil or (type(rankTable) == "table" and GFWTable.Count(rankTable) == 0)) then
		if (newRankTable == nil or (type(rankTable) == "table" and GFWTable.Count(newRankTable) == 0) == 0) then
			GFWUtils.Print(format(FHH_FIND_MISSING_INFO, GFWUtils.Hilite(niceSpellName)));
			return;
		else
			rankTable = newRankTable;
		end
	end
	
	rankNum = tonumber(rankNum);
	if (rankNum) then
		if (not rankTable[rankNum]) then
			GFWUtils.Print(format(FHH_FIND_RANK_UNKNOWN, GFWUtils.Hilite(niceSpellName), GFWUtils.Hilite(rankNum)));
			return;
		end
		
		-- report minimum pet level for ability
		local minLevel = rankTable[rankNum];
		local petLevel = MAX_PLAYER_LEVEL;
		if (UnitExists("pet")) then
			petLevel = tonumber(UnitLevel("pet"));
		end
		if (minLevel == nil) then
			minLevel = newRankTable[rankNum];
		end
		if (minLevel == nil) then
			local version = GetAddOnMetadata(ADDON_NAME, "Version");
			GFWUtils.Print(format(FHH_ERROR_MISSING_LVL, version, GFWUtils.Hilite(niceSpellName.." "..rankNum)));
		else
			if (type(minLevel) == "string") then
				GFWUtils.Print(format(FHH_FIND_REQUIRES_LVL_ASSUMED, GFWUtils.Hilite(niceSpellName.." "..rankNum), GFWUtils.Hilite(minLevel)));
			elseif (petLevel >= minLevel) then
				GFWUtils.Print(format(FHH_FIND_REQUIRES_LVL, GFWUtils.Hilite(niceSpellName.." "..rankNum), GFWUtils.Hilite(minLevel)));
			else
				GFWUtils.Print(format(FHH_FIND_REQUIRES_LVL, GFWUtils.Hilite(niceSpellName.." "..rankNum), GFWUtils.Red(minLevel)));
			end
		end
	elseif (type(rankTable) == "number") then
		-- we have a spell with only one rank (that's not named "Rank 1")
		-- report minimum pet level for ability
		local minLevel = rankTable;
		local petLevel = MAX_PLAYER_LEVEL;
		if (UnitExists("pet")) then
			petLevel = tonumber(UnitLevel("pet"));
		end
		if (minLevel == nil) then
			local version = GetAddOnMetadata(ADDON_NAME, "Version");
			GFWUtils.Print(format(FHH_ERROR_MISSING_LVL, version, GFWUtils.Hilite(niceSpellName)));
		else
			if (type(minLevel) == "string") then
				GFWUtils.Print(format(FHH_FIND_REQUIRES_LVL_ASSUMED, GFWUtils.Hilite(niceSpellName.." "..rankNum), GFWUtils.Hilite(minLevel)));
			elseif (petLevel >= minLevel) then
				GFWUtils.Print(format(FHH_FIND_REQUIRES_LVL, GFWUtils.Hilite(niceSpellName.." "..rankNum), GFWUtils.Hilite(minLevel)));
			else
				GFWUtils.Print(format(FHH_FIND_REQUIRES_LVL, GFWUtils.Hilite(niceSpellName.." "..rankNum), GFWUtils.Red(minLevel)));
			end
		end
	else
		local knownRanks = {};
		for rankTableNum in pairs(rankTable) do
			table.insert(knownRanks, rankTableNum);
		end
		local newRanks = {};
		for rankTableNum in pairs(newRankTable or {}) do
			table.insert(newRanks, rankTableNum);
		end
		local allRanks = GFWTable.Merge(knownRanks, newRanks);
		GFWUtils.Print(format(FHH_FIND_RANKS_LISTED, GFWUtils.Hilite(niceSpellName))..table.concat(allRanks, " "));
		if (not FHH_TrainerSpells[spellToken]) then
			GFWUtils.Print(format(FHH_FIND_NEED_RANK, spellToken));
		end
	end

	-- report available creature families
	local families = FHH_LearnableBy[spellToken];
	if (type(families) == "table" and FHH_NewInfo and FHH_NewInfo.LearnableBy and FHH_NewInfo.LearnableBy[spellToken]) then
		families = GFWTable.Merge(families, FHH_NewInfo.LearnableBy[spellToken]);
		if (#(GFWTable.Diff(families, FHH_AllFamilies)) == 0 ) then
			families = FHH_ALL_FAMILIES;
		end
	end
	if (families or (type(families) == "table" and #families == 0)) then
		if (type(families) == "string") then
			GFWUtils.Print(format(FHH_FIND_LEARNABLE_BY, GFWUtils.Hilite(niceSpellName), GFWUtils.Hilite(families)));
		else
			local listText = table.concat(families, ", ");
			GFWUtils.Print(format(FHH_FIND_LEARNABLE_BY, GFWUtils.Hilite(niceSpellName), GFWUtils.Hilite(listText)));
		end
	end

	-- case 1: first levels of Growl are innate
	if (spellToken == "growl" and rankNum and rankNum <= 2) then
		GFWUtils.Print(format(FHH_FIND_GROWL_INNATE, GFWUtils.Hilite(niceSpellName.." "..rankNum)));
		return;
	end
	
	-- case 2: spells taught by trainers, for which rank doesn't matter
	if (FHH_TrainerSpells[spellToken]) then
		local spellSummary = niceSpellName;
		if (rankNum) then
			spellSummary = spellSummary.." "..rankNum;
		end
		GFWUtils.Print(format(FHH_FIND_PET_TRAINER, GFWUtils.Hilite(spellSummary)));
		return;
	end
	
	if (rankNum == nil and type(rankTable) == "table") then return; end
	
	--case 3: lookup by spell and rank, report by zone (sanity check first)
	local maxZones = MAX_REPORTED_ZONES;
	if (cmd == "findall") then
		maxZones = 1000; -- arbitrarily high so we find everything.
	end
	if (rankNum) then
		GFWUtils.Print(format(FHH_FIND_LEARNED_FROM, GFWUtils.Hilite(niceSpellName.." "..rankNum)));
	else
		GFWUtils.Print(format(FHH_FIND_LEARNED_FROM, GFWUtils.Hilite(niceSpellName)));
	end	
	
	local reportLines = FHH_GenerateFindReport(spellToken, rankNum, maxZones);
	
	if (#reportLines > 0) then
		for _, reportLine in pairs(reportLines) do
			GFWUtils.Print(reportLine.zone.." "..GFWUtils.Hilite(FHH_CreatureListString(reportLine.critters)));
		end
	else
		local version = GetAddOnMetadata(ADDON_NAME, "Version");
		GFWUtils.Print(format(FHH_ERROR_NO_BEASTS, version, GFWUtils.Hilite(niceSpellName.." "..rankNum)));
	end
end

function FHH_CurrentZoneLearnableBeasts()
	local zone = GetRealZoneText();
	local zoneCritters = {};
	for beastName, info in pairs(FHH_BeastInfo) do
		if (info.z == zone) then
			local beastInfo = FHH_BeastInfo[beastName];
			for spellToken, rank in pairs(beastInfo) do
				if (not FHH_NonSpellKeys[spellToken]) then
					if (not FHH_KnownSpells[spellToken] or (rank and not FHH_KnownSpells[spellToken][rank])) then
						if (not GFWTable.KeyOf(zoneCritters, beastName)) then
							table.insert(zoneCritters, beastName);
						end
					end
				end
			end
		end
	end
	return zoneCritters;
end

function FHH_GenerateFindReport(spellToken, rankNum, maxZones)
	local reportLines = {};
	local zoneName = GFWZones.UnlocalizedZone(GetRealZoneText());
	local critterList = FHH_FindCreatures(spellToken, rankNum, zoneName);
	if (#critterList > 0) then
		table.insert(reportLines, {zone=GFWZones.LocalizedZone(zoneName), critters=critterList});
	end
	
	if (maxZones > 1) then
		local zoneConnections = GFWZones.ConnectionsForZone(zoneName);	
		if (zoneConnections == nil) then
			-- player is in an unknown zone; instead of doing nothing, let's pick a known zone to start searching from.
			local _, race = UnitRace("player");
			if (race == "Night Elf") then
				zoneName = "Teldrassil";
			elseif (race == "Dwarf") then
				zoneName = "Dun Morogh";
			elseif (race == "Gnome") then
				zoneName = "Dun Morogh";
			elseif (race == "Human") then
				zoneName = "Elwynn Forest";
			elseif (race == "Draenei") then
				zoneName = "Azuremyst Isle";
			elseif (race == "Tauren") then
				zoneName = "Mulgore";
			elseif (race == "Orc") then
				zoneName = "Durotar";
			elseif (race == "Troll") then
				zoneName = "Durotar";
			elseif (race == "Scourge") then
				zoneName = "Tirisfal Glades";
			elseif (race == "Blood Elf") then
				zoneName = "Eversong Woods";
			else
				-- unlikely, but in case we can't parse the race name...
				local faction = UnitFactionGroup("player");
				if (faction == "Alliance") then
					zoneName = "Ironforge";
				elseif (faction == "Horde") then
					zoneName = "Orgrimmar";
				else
					-- on the off chance we can't even parse a major-faction name...
					zoneName = "Stranglethorn Vale";
				end
			end
			zoneConnections = GFWZones.ConnectionsForZone(zoneName);
		end
	
		local shouldBreak;
		for _, zones in pairs(zoneConnections) do
			for _, zoneName in pairs(zones) do
				critterList = FHH_FindCreatures(spellToken, rankNum, zoneName);
				if (#critterList > 0) then
					table.insert(reportLines, {zone=GFWZones.LocalizedZone(zoneName), critters=critterList});
					if (#reportLines >= maxZones) then
						shouldBreak = true;
						break;
					end
				end
			end
			if (shouldBreak) then break; end
		end
	end
	
	return reportLines;
end

function FHH_FindCreatures(spellToken, rankNum, zone)
	local creatures = {};
	for name, info in pairs(FHH_BeastInfo) do
		if (info.z == zone and ((rankNum and info[spellToken] == rankNum) or info[spellToken] == 0)) then
			table.insert(creatures, name);
		end
	end
	if (FHH_NewInfo and FHH_NewInfo.BeastInfo) then
		for name, info in pairs(FHH_NewInfo.BeastInfo) do
			if (info.z == zone and ((rankNum and info[spellToken] == rankNum) or info[spellToken] == 0)) then
				table.insert(creatures, name);
			end
		end
	end
	return creatures;
end

function FHH_CreatureListString(critterList)
	local listString = ""
	for _, name in pairs(critterList) do
		local info = FHH_BeastInfo[name];
		if (info == nil and FHH_NewInfo and FHH_NewInfo.BeastLevels) then
			info = FHH_NewInfo.BeastLevels[name];
		end
		if (info == nil) then
			listString = listString..", ";
		else
			local unlocalizedName = FHH_Localized[name];
			if (unlocalizedName) then
				name = unlocalizedName;
			end
			listString = listString .. name .. " ";
			local myLevel = UnitLevel("player");
			local minLevel = info.min;
			local maxLevel = info.max;
			if (info.min > UnitLevel("player")) then
				minLevel = RED_FONT_COLOR_CODE..info.min..FONT_COLOR_CODE_CLOSE;
			end
			if (info.max and info.max > UnitLevel("player")) then
				maxLevel = RED_FONT_COLOR_CODE..info.max..FONT_COLOR_CODE_CLOSE;
			end
			if (info.min == info.max or info.max == nil) then			
				listString = listString.."("..minLevel;
			else
				listString = listString.."("..minLevel.."-"..maxLevel;
			end
			if (info.t == nil) then
				listString = listString.."), ";
			elseif (info.t == 1) then
				listString = listString.." "..ELITE.."), ";	-- Elite
			elseif (info.t == 2) then
				listString = listString.." "..ITEM_QUALITY3_DESC.."), ";	-- Rare
			elseif (info.t == 3) then
				listString = listString.." "..ITEM_QUALITY3_DESC.." "..ELITE.."), ";	-- Rare Elite
			end				
		end
	end
	listString = string.gsub(listString, ", $", "");
	return listString;
end

function FHH_HasTameEffect(unit)

	local i = 1;
	local buff;
	buff = UnitBuff(unit, i);
	while buff do
		if ( string.find(buff, "Ability_Hunter_BeastTaming") ) then
			return true;
		end
		i = i + 1;
		buff = UnitBuff(unit, i);
	end
	return false;

end

function FHH_SpellTokenforName(spellName)
	local token = FHH_SpellNamesToTokens[spellName];
	if (token == nil and FHH_NewInfo and FHH_NewInfo.SpellNamesToTokens) then
		token = FHH_NewInfo.SpellNamesToTokens[spellName];
	end
	return token;
end

function FHH_SpellTokenForIcon(spellIcon, spellName)
	local spellToken;
	for spellID, token in pairs(FHH_SpellIDsToTokens) do
		local _, _, icon = GetSpellInfo(spellID);
		if (icon == spellIcon) then
			spellToken = token;
			break;
		end
	end
	if (spellToken == nil and FHH_NewInfo and FHH_NewInfo.SpellIcons) then
		spellToken = FHH_NewInfo.SpellIcons[spellIcon];
	end
	if (spellToken == nil) then
		spellToken = FHH_SpellTokenforName(spellName);
	end	
	if (spellToken == nil) then
		spellToken = FHH_RecordNewSpellIcon(spellIcon, spellName);
	end
	return spellToken;
end

function FHH_GetCurrentPetSpells(includeTrainerSpells)
	
	local _, isHunterPet = HasPetUI();
	if (not isHunterPet) then return; end

	local currentPetSpells = { };
	local i = 1;
	local spellName, spellRank = GetSpellName(i, BOOKTYPE_PET);
	local spellIcon = GetSpellTexture(i, BOOKTYPE_PET);
	while spellName do
		local _, _, rankNum = string.find(spellRank, "(%d+)");
		local spellToken = FHH_SpellTokenForIcon(spellIcon, spellName);
		local nameSpellToken = FHH_SpellTokenforName(spellName);
		if (spellToken and nameSpellToken and spellToken ~= nameSpellToken) then
			if (FHH_NewInfo == nil) then
				FHH_NewInfo = {};
			end
			if (FHH_NewInfo.SpellTokenAliases == nil) then
				FHH_NewInfo.SpellTokenAliases = {};
			end
			FHH_NewInfo.SpellTokenAliases[nameSpellToken] = spellToken;
		end

		if (includeTrainerSpells or not FHH_TrainerSpells[spellToken]) then
			currentPetSpells[spellToken] = tonumber(rankNum) or 0;
		end
		i = i + 1;
		spellName, spellRank = GetSpellName(i, BOOKTYPE_PET);
		spellIcon = GetSpellTexture(i, BOOKTYPE_PET);
	end
	
	return currentPetSpells;
end

function FHH_CheckPetSpells()
	
	local currentPetSpells = FHH_GetCurrentPetSpells();
	if (currentPetSpells) then
		FHH_ProcessAliases();
		FHH_CheckSpellTables(FHH_State.TamingCritter, currentPetSpells);
	else
		--GFWUtils.Print("pet has no spells");
	end
end

function FHH_SpellDescription(spellToken, rankNum, pretty)
	local niceSpellName = FHH_NameForSpellToken(spellToken);
	if (niceSpellName == nil and FHH_NewInfo and FHH_NewInfo.SpellTokensToNames and FHH_NewInfo.SpellTokensToNames[spellToken]) then
		niceSpellName = FHH_NewInfo.SpellTokensToNames[spellToken];
	end
	if (niceSpellName == nil) then
		niceSpellName = spellToken;
	end
	if (rankNum and rankNum ~= 0) then
		if (pretty) then
			return string.format("%s ("..RANK.." %d)", niceSpellName, rankNum);
		else
			return niceSpellName.." "..rankNum;
		end
	else
		return niceSpellName;
	end
end

function FHH_SpellDescriptions(spellList)
	local descriptions = {};
	for spellToken, rankNum in pairs(spellList) do
		if (not FHH_NonSpellKeys[spellToken]) then
			table.insert(descriptions, FHH_SpellDescription(spellToken, rankNum));
		end
	end
	return descriptions;
end

function FHH_SpellDescripionList(spellList)
	return table.concat(FHH_SpellDescriptions(spellList), ", ");
end

function FHH_SpellIsLearnableByFamily(spellToken, family)
	return (FHH_LearnableBy[spellToken] == FHH_ALL_FAMILIES or GFWTable.KeyOf(FHH_LearnableBy[spellToken], family));
end

function FHH_SpellHasLearnableBeasts(spellToken, spellRank)
	
	if (FHH_TrainerSpells[spellToken]) then
		return;
	end
	
	if (not FHH_SpellBeastCount) then
		FHH_SpellBeastCount = {};
		
		for id, ranks in pairs(FHH_RequiredLevel) do
			if (not FHH_TrainerSpells[id]) then
				if (type(ranks) == "table") then
					FHH_SpellBeastCount[id] = {};
					for rank in pairs(ranks) do
						FHH_SpellBeastCount[id][rank] = FHH_GetSpellBeastCount(id, rank);
					end
				else
					FHH_SpellBeastCount[id] = FHH_GetSpellBeastCount(id);
				end
			end
		end
	end
	
	if (FHH_SpellBeastCount[spellToken] and FHH_SpellBeastCount[spellToken][spellRank] ~= 0) then
		return true;
	end
end

function FHH_GetSpellBeastCount(spellToken, spellRank)
	local count = 0;
	for beastName, info in pairs(FHH_BeastInfo) do
		if (info[spellToken] == spellRank or (not spellRank and info[spellToken])) then
			count = count + 1;
		end
	end
	return count;
end

function FHH_CheckSpellTables(critter, spellList, level, family)
	
	if ( spellList == nil or GFWTable.Count(spellList) == 0 ) then return; end

	-- process any recently learned spellToken aliases so we record data correctly.
	local newSpellList = {};
	local changed = false;
	for spellToken, rankNum in pairs(spellList) do
		if (FHH_NewInfo and FHH_NewInfo.SpellTokenAliases and FHH_NewInfo.SpellTokenAliases[spellToken]) then
			spellToken = FHH_NewInfo.SpellTokenAliases[spellToken];
			changed = true;
		end
		newSpellList[spellToken] = rankNum;
	end
	if (changed) then
		spellList = newSpellList;
	end	

	if (level == nil) then
		level = UnitLevel("pet");
	end
	if (family == nil) then
		family = UnitCreatureFamily("pet");
	end
	
	if ( FHH_BeastInfo[critter] ) then
	
		-- record any spells the critter has that our built-in table doesn't know about 
		local unknownPetSpells = { };
		for spellToken, rankNum in pairs(spellList) do
			if ( FHH_BeastInfo[critter][spellToken] == nil ) then
				unknownPetSpells[spellToken] = rankNum;
			end
		end
		if ( GFWTable.Count(unknownPetSpells) > 0 ) then
			if (FHH_NewInfo == nil) then
				FHH_NewInfo = {};
			end
			if (FHH_NewInfo.BeastInfo == nil) then
				FHH_NewInfo.BeastInfo = {};
			end
			FHH_NewInfo.BeastInfo[critter] = spellList; -- we want to remember the entire current spells list
		end
		
		-- record any spells our built-in table thinks the critter has, but the critter actually doesn't
		local wrongPetSpells = { };
		for spellToken, rankNum in pairs(FHH_BeastInfo[critter]) do
			if ( spellList[spellToken] ~= rankNum and not FHH_NonSpellKeys[spellToken]) then
				wrongPetSpells[spellToken] = rankNum;
			end
		end
		if ( GFWTable.Count(wrongPetSpells) > 0 ) then
			if (FHH_NewInfo == nil) then
				FHH_NewInfo = {};
			end
			if (FHH_NewInfo.BadBeastInfo == nil) then
				FHH_NewInfo.BadBeastInfo = {};
			end
			FHH_NewInfo.BadBeastInfo[critter] = wrongPetSpells;
		end
		
		if (FHH_NewInfo and (( FHH_NewInfo.BeastInfo and FHH_NewInfo.BeastInfo[critter]) or (FHH_NewInfo.BadBeastInfo and FHH_NewInfo.BadBeastInfo[critter]))) then
			local details = "(expected "..FHH_SpellDescripionList(FHH_BeastInfo[critter]).."; found "..FHH_SpellDescripionList(spellList)..").";
			local version = GetAddOnMetadata(ADDON_NAME, "Version");
			GFWUtils.PrintOnce("Hunter's Helper "..version.." has incorrect data on "..GFWUtils.Hilite(critter.." "..details).." Please visit http://petopia.brashendeavors.net to submit a correction.");
		end
		
	else
	
		-- this pet is entirely new to our list
		if (FHH_NewInfo == nil) then
			FHH_NewInfo = {};
		end
		if (FHH_NewInfo.BeastInfo == nil) then
			FHH_NewInfo.BeastInfo = {};
		end
		FHH_NewInfo.BeastInfo[critter] = spellList;
		FHH_CheckBeastLevel(critter, level, FHH_State.TamingType);
		
		local details = "(found "..FHH_SpellDescripionList(spellList).." in "..GetRealZoneText()..").";
		local version = GetAddOnMetadata(ADDON_NAME, "Version");
		GFWUtils.PrintOnce("Hunter's Helper "..version.." has no data on "..GFWUtils.Hilite(critter.." "..details).." Please visit http://petopia.brashendeavors.net to submit a correction.)", 60);

	end
	
	for spellToken, rankNum in pairs(spellList) do
		FHH_RecordNewRequiredFamily(spellToken, family);
		FHH_RecordNewRequiredLevel(spellToken, rankNum, level);
	end

end

function FHH_RecordNewRequiredFamily(spellToken, family)
	if (FHH_LearnableBy[spellToken] and GFWTable.KeyOf(FHH_LearnableBy[spellToken], family)) then
		return; -- we've already recorded this in our static data
	end
	
	if (FHH_NewInfo == nil) then
		FHH_NewInfo = {};
	end
	if (FHH_NewInfo.LearnableBy == nil) then
		FHH_NewInfo.LearnableBy = {};
	end
	if (FHH_NewInfo.LearnableBy[spellToken] == nil) then
		FHH_NewInfo.LearnableBy[spellToken] = {};
	end
	if (not GFWTable.KeyOf(FHH_NewInfo.LearnableBy[spellToken], family)) then
		table.insert(FHH_NewInfo.LearnableBy[spellToken], family);
	end
end

function FHH_RecordNewRequiredLevel(spellToken, rankNum, level, verified)
	local staticData = FHH_RequiredLevel[spellToken];
	if (staticData and (type(staticData) == "number" or staticData[rankNum])) then
		return; -- we've already recorded this in our static data
	end
	
	if (FHH_NewInfo == nil) then
		FHH_NewInfo = {};
	end
	if (FHH_NewInfo.RequiredLevel == nil) then
		FHH_NewInfo.RequiredLevel = {};
	end
	if (FHH_NewInfo.RequiredLevel[spellToken] == nil) then
		FHH_NewInfo.RequiredLevel[spellToken] = {};
	end
	if (rankNum) then
		if (verified) then
			FHH_NewInfo.RequiredLevel[spellToken][rankNum] = level;
		elseif (FHH_NewInfo.RequiredLevel[spellToken][rankNum] == nil) then
			FHH_NewInfo.RequiredLevel[spellToken][rankNum] = tostring(level);
		else
			local existingRank = FHH_NewInfo.RequiredLevel[spellToken][rankNum];
			if (type(existingRank) == "string") then
				-- we don't have a certain answer yet, we'll use what we just got to refine it
				FHH_NewInfo.RequiredLevel[spellToken][rankNum] = tostring(math.min(level, tonumber(existingRank)));
			end
		end
	else
		if (verified) then
			FHH_NewInfo.RequiredLevel[spellToken] = level;
		else                                  
			FHH_NewInfo.RequiredLevel[spellToken] = tostring(level);
		end
	end
			
end

function FHH_CodeForType(typeString)
	if (typeString == "elite") then
		return 1;
	elseif (typeString == "rare") then
		return 2;
	elseif (typeString == "rareelite") then
		return 3;
	end
end

function FHH_TypeForCode(typeCode)
	if (typeCode == 1) then
		return "elite";
	elseif (typeCode == 2) then
		return "rare";
	elseif (typeCode == 3) then
		return "rareelite";
	end
end

function FHH_CheckBeastLevel(creepName, creepLevel, creepType)
	if (creepLevel < 1) then
		return; -- UnitLevel sometimes returns -1 for common mobs (maybe a WDB cache thing) so we toss nonsensical values.
	end

	if (FHH_NewInfo and FHH_NewInfo.BeastLevels and FHH_NewInfo.BeastLevels[creepName]) then
		FHH_NewInfo.BeastLevels[creepName].min = math.min(FHH_NewInfo.BeastLevels[creepName].min, creepLevel);
		FHH_NewInfo.BeastLevels[creepName].max = math.max(FHH_NewInfo.BeastLevels[creepName].max, creepLevel);
		if (FHH_NewInfo.BeastLevels[creepName].type and creepType ~= "normal") then
			FHH_NewInfo.BeastLevels[creepName].type = creepType;
		end
	elseif (FHH_BeastInfo[creepName]) then
		if (creepLevel < FHH_BeastInfo[creepName].min or (FHH_BeastInfo[creepName].max and creepLevel > FHH_BeastInfo[creepName].max)) then
			if (FHH_NewInfo == nil) then
				FHH_NewInfo = {};
			end
			if (FHH_NewInfo.BeastLevels == nil) then
				FHH_NewInfo.BeastLevels = {};
			end
			FHH_NewInfo.BeastLevels[creepName] = {};
			FHH_NewInfo.BeastLevels[creepName].min = math.min(FHH_BeastInfo[creepName].min, creepLevel);
			FHH_NewInfo.BeastLevels[creepName].max = math.max(FHH_BeastInfo[creepName].max or FHH_BeastInfo[creepName].min, creepLevel);
		end
		if (creepType ~= "normal" and creepType ~= FHH_TypeForCode(FHH_BeastInfo[creepName].t)) then
			if (FHH_NewInfo == nil) then
				FHH_NewInfo = {};
			end
			if (FHH_NewInfo.BeastLevels == nil) then
				FHH_NewInfo.BeastLevels = {};
			end
			if (FHH_NewInfo.BeastLevels[creepName] == nil) then
				FHH_NewInfo.BeastLevels[creepName] = {};
			end
			FHH_NewInfo.BeastLevels[creepName].min = math.min(FHH_BeastInfo[creepName].min, creepLevel);
			FHH_NewInfo.BeastLevels[creepName].max = math.max(FHH_BeastInfo[creepName].max or FHH_BeastInfo[creepName].min, creepLevel);
			FHH_NewInfo.BeastLevels[creepName].t = FHH_CodeForType(creepType);
		end
	end
end

function FHH_RecordNewSpellToken(spellName)
	-- we have a new spell on our hands; we'll use its lowercase name as a key for now.
	spellToken = string.lower(spellName);
	if (FHH_NewInfo == nil) then
		FHH_NewInfo = {};
	end
	if (FHH_NewInfo.SpellNamesToTokens == nil) then
		FHH_NewInfo.SpellNamesToTokens = {};
	end
	if (FHH_NewInfo.SpellTokensToNames == nil) then
		FHH_NewInfo.SpellTokensToNames = {};
	end
	FHH_NewInfo.SpellNamesToTokens[spellName] = spellToken;
	FHH_NewInfo.SpellTokensToNames[spellToken] = spellName;
	return spellToken;
end

function FHH_RecordNewSpellIcon(spellIcon, spellName)
	spellToken = FHH_RecordNewSpellToken(spellName);
	if (FHH_NewInfo == nil) then
		FHH_NewInfo = {};
	end
	if (FHH_NewInfo.SpellIcons == nil) then
		FHH_NewInfo.SpellIcons = {};
	end
	FHH_NewInfo.SpellIcons[spellIcon] = spellToken;
	return spellToken;
end

function FHH_ProcessAliases()
	if (FHH_NewInfo and FHH_NewInfo.SpellTokenAliases) then
		for oldID, newID in pairs(FHH_NewInfo.SpellTokenAliases) do
			
			if (FHH_NewInfo.SpellNamesToTokens) then
				local newNamesToIDs = {};
				local changed = false;
				for name, id in pairs(FHH_NewInfo.SpellNamesToTokens) do
					if (id == oldID) then
						newNamesToIDs[name] = newID;
						changed = true;
					else
						newNamesToIDs[name] = id;
					end
				end
				if (changed) then
					FHH_NewInfo.SpellNamesToTokens = newNamesToIDs;
				end
			end

			if (FHH_NewInfo.BeastInfo) then
				for beast, spellList in pairs(FHH_NewInfo.BeastInfo) do
					if (spellList[oldID]) then
						spellList[newID] = spellList[oldID];
						spellList[oldID] = nil;
					end
				end
			end

			if (FHH_NewInfo.BadBeastInfo) then
				for beast, spellList in pairs(FHH_NewInfo.BadBeastInfo) do
					if (spellList[oldID]) then
						spellList[newID] = spellList[oldID];
						spellList[oldID] = nil;
					end
				end
			end
			
			if (FHH_KnownSpells) then
				if (FHH_KnownSpells[oldID]) then
					FHH_KnownSpells[newID] = FHH_KnownSpells[oldID];
					FHH_KnownSpells[oldID] = nil;
				end
			end

			if (FHH_NewInfo.SpellTokensToNames and FHH_NewInfo.SpellTokensToNames[oldID]) then
				FHH_NewInfo.SpellTokensToNames[newID] = FHH_NewInfo.SpellTokensToNames[oldID];
				FHH_NewInfo.SpellTokensToNames[oldID] = nil;
			end
						
			if (FHH_NewInfo.RequiredLevel and FHH_NewInfo.RequiredLevel[oldID]) then
				FHH_NewInfo.RequiredLevel[newID] = FHH_NewInfo.RequiredLevel[oldID];
				FHH_NewInfo.RequiredLevel[oldID] = nil;				
			end

			if (FHH_NewInfo.LearnableBy and FHH_NewInfo.LearnableBy[oldID]) then
				FHH_NewInfo.LearnableBy[newID] = FHH_NewInfo.LearnableBy[oldID];
				FHH_NewInfo.LearnableBy[oldID] = nil;				
			end

		end
	end
end

function FHH_GenerateSpellNamesToTokens()
	FHH_SpellNamesToTokens = {};
	for id, token in pairs(FHH_SpellIDsToTokens) do
		local name = GetSpellInfo(id);
		if (not FHH_SpellNamesToTokens[name]) then
			FHH_SpellNamesToTokens[name] = token;
		end
	end
end

function FHH_NameForSpellToken(token)
	for spellID, spellToken in pairs(FHH_SpellIDsToTokens) do
		if (spellToken == token) then
			return GetSpellInfo(spellID);
		end
	end
end
	
------------------------------------------------------
-- Dongle & GFWOptions stuff
------------------------------------------------------

GFW_HuntersHelper = {};
local GFWOptions = DongleStub("GFWOptions-1.0");

local function buildOptionsUI(panel)

	GFW_HuntersHelper.optionsText = {
		BeastTooltip = FHH_OPTIONS_BEAST_TOOLTIP,
		BeastTooltipOnlyHunter = FHH_OPTIONS_HUNTER_ONLY,
		ShowAlreadyKnownBeasts = FHH_OPTIONS_SHOW_ALREADY_KNOWN,
		UITooltip = FHH_OPTIONS_UI_TOOLTIP,
		ShowMinimap = FHH_OPTIONS_MINIMAP,
		MinimapPosition = FHH_OPTIONS_MINIMAP_POSITION,
	};
	
	local widget, lastWidget;
	widget = panel:CreateCheckButton("BeastTooltip", true);
	widget:SetPoint("TOPLEFT", panel.contentAnchor, "BOTTOMLEFT", -2, -8);
	lastWidget = widget;
	
	widget = panel:CreateCheckButton("BeastTooltipOnlyHunter", false);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 16, -2);
	lastWidget.dependentControls = { widget };
	lastWidget = widget;

	widget = panel:CreateCheckButton("ShowMinimap", false);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", -16, -2);
	lastWidget = widget;

	widget = panel:CreateSlider("MinimapPosition", -180, 180, 1);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 4, -24);
	lastWidget = widget;
	
	local s;	
	s = panel:CreateFontString("FHH_OptionsPanel_PanelHeader", "ARTWORK", "GameFontNormal");
	s:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", -4, -16);
	s:SetText(FHH_OPTIONS_PANEL_HEADER);
	lastWidget = s;

	widget = panel:CreateCheckButton("ShowAlreadyKnownBeasts", false);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -2);
	lastWidget = widget;

	widget = panel:CreateCheckButton("UITooltip", true);
	widget:SetPoint("TOPLEFT", lastWidget, "BOTTOMLEFT", 0, -2);

end

function FHH_ShowOptions()
	InterfaceOptionsFrame_OpenToCategory(FHH_OptionsPanel);
	--Call a second time to work around bug: https://www.wowinterface.com/forums/showthread.php?t=54599
	InterfaceOptionsFrame_OpenToCategory(FHH_OptionsPanel);
end

function GFW_HuntersHelper:Initialize()
	self.defaults = { profile = FHH_Defaults };
	self.db = self:InitializeDB("GFW_HuntersHelperDB", self.defaults);
	FHH_Options = self.db.profile;
end

function GFW_HuntersHelper:Enable()
	GFWOptions:CreateMainPanel("GFW_HuntersHelper", "FHH_OptionsPanel", FHH_OPTIONS_SUBTEXT);
	FHH_OptionsPanel.BuildUI = buildOptionsUI;
end

function GFW_HuntersHelper:OptionsChanged()
	FHH_MinimapButtonCheck();
end

GFW_HuntersHelper = DongleStub("Dongle-1.2"):New("GFW_HuntersHelper", GFW_HuntersHelper);

