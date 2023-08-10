------------------------------------------------------
-- HuntersHelper.lua
-- @project-revision@ @project-date-iso@
------------------------------------------------------
local ADDON_NAME = "GFW_HuntersHelper"

local utils = _G['BMUtils']
utils = _G.LibStub("BM-utils-1")
local LibPet = _G['LibPet']
local PetSpells = _G['PetSpells']
local HHSpells = _G['HHSpells']
local FHH_BeastInfo
local Tourist
if _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC then
	Tourist = _G.LibStub("LibTouristClassicEra")
elseif _G.WOW_PROJECT_ID == _G.WOW_PROJECT_WRATH_CLASSIC then
	Tourist = _G.LibStub("LibTouristClassic-1.0")
else
	error('HuntersHelper loaded on unknown game version')
end
local ZoneInfo = _G['ZoneInfo']
local HHZoneLocale = _G['HHZoneLocale']
_G['HHVersion'] = 'HuntersHelper @project-version@ @game-type@ LibHunterPetInfo '..LibPet.version

-- Saved configuration & info
local spellNamesToIcons = PetSpells.generateNamesToIcons()
FHH_KnownSpells = {};

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
local db

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
		_G['HH_SpellNamesToId'] = PetSpells.idToName(true)
		db = _G['HuntersHelperDB']
		if not db then error('Unable to load DB') end

		_, realClass = UnitClass("player");
		if (realClass == "HUNTER") then
			-- only do stuff related to taming and checking hunter spells if you're a hunter.
			self:RegisterEvent("UNIT_AURA");
			self:RegisterEvent("UNIT_NAME_UPDATE");
			self:RegisterEvent("CRAFT_SHOW");
			self:RegisterEvent("CRAFT_UPDATE");
			self:RegisterEvent("CRAFT_CLOSE");
			self:RegisterEvent("CHAT_MSG_SYSTEM");

			FHH_MinimapButtonCheck();
		end
		self:UnregisterEvent("ADDON_LOADED");

	elseif ( event == "UPDATE_MOUSEOVER_UNIT" ) then

		if ( UnitExists("mouseover") and not UnitPlayerControlled("mouseover") and db.beastTooltip ) then

			local _, myClass = UnitClass("player");
			if (db.onlyHunter and myClass ~= "HUNTER") then return end

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
			HHSpells:scanCraftFrame()
			ShowUIPanel(FHH_UI); --TODO: Do not call this in combat
			FHH_ReplacingCraftFrame = true;
		else
			FHH_RestoreCraftFrame();
			FHH_ReplacingCraftFrame = nil;
		end

	elseif ( event == "CRAFT_UPDATE" ) then

		if (CraftIsPetTraining()) then
			FHH_ScanCraftFrame();
			HHSpells:scanCraftFrame()
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
			HHSpells:saveCurrentPetSpells()
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
		GFWUtils.Print(_G['HHVersion']);
		return;
	end
		
	if (msg == "onlyhunter") then
		_G['HuntersHelperDB'].beastTooltip = true
		_G['HuntersHelperDB'].onlyHunter = true
		GFWUtils.Print(FHH_STATUS_ONLYHUNTER);
		return;
	end
	if (msg == "on") then
		_G['HuntersHelperDB'].beastTooltip = true
		_G['HuntersHelperDB'].onlyHunter = false
		GFWUtils.Print(FHH_STATUS_ON);
		return;
	end
	if (msg == "off") then
		_G['HuntersHelperDB'].beastTooltip = false
		GFWUtils.Print(FHH_STATUS_OFF);
		return;
	end

	if (msg == "button" or msg == "minimap") then
		_G['HuntersHelperDB'].showMinimapButton = not _G['HuntersHelperDB'].showMinimapButton
		FHH_MinimapButtonCheck();
		return;
	end

	if ( msg == "status" ) then
		if _G['HuntersHelperDB'].beastTooltip and _G['HuntersHelperDB'].onlyHunter then
			GFWUtils.Print(FHH_STATUS_ONLYHUNTER);
		elseif not _G['HuntersHelperDB'].beastTooltip then
			GFWUtils.Print(FHH_STATUS_OFF);
		else
			GFWUtils.Print(FHH_STATUS_ON);
		end
		return;
	end
	
	if (msg == "reset") then
		_G.HunterPetHelper.db:ResetProfile();
		GFWUtils.Print(FHH_STATUS_RESET);

		if (CraftIsPetTraining()) then
			FHH_ScanCraftFrame();
			HHSpells:scanCraftFrame()
		else
			GFWUtils.Print(FHH_NEED_SPELL_INFO);
		end
		
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

		-- try looking it up as a proper name, case insensitively

		for properName, spellIcon in pairs(spellNamesToIcons) do
			if (string.lower(properName) == spellQuery) then
				FHH_Find(spellIcon, rankNum)
				return
			end
		end
		GFWUtils.Print(format(FHH_FIND_SPELL_UNKNOWN, GFWUtils.Hilite(spellQuery)));
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
			utils:CastSpellById(5149)
			return true
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
		if (db.showMinimapButton) then
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
	local count = GFWTable.Count(zoneCritters)
	if (count > 0) then
		FHH_MinimapCount:SetText(count);
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
	local zoneCrittersCount = GFWTable.Count(zoneCritters)
	local color;
	if (zoneCrittersCount > 0) then
		color = HIGHLIGHT_FONT_COLOR;
		--GameTooltip:AddLine(format(FHH_NUM_BEASTS_IN_ZONE, zoneCrittersCount), color.r, color.g, color.b);
		GameTooltip:AddLine(FHH_NUM_BEASTS_IN_ZONE:format(zoneCrittersCount), color.r, color.g, color.b);

		for petId, petInfo in pairs(zoneCritters) do
			local beastString = LibPet.petLevelString(petInfo)

			for spellIcon, rank in GFWTable.PairsByKeys(LibPet.petSkills(petId)) do
				local spellId, spellName = PetSpells.getSpellFromIcon(spellIcon, rank)
				if spellName == nil then
					utils:error(('Unable to get spell name for icon %s rank %d id %s'):format(spellIcon, rank, spellId or 'nil'))
					spellName = spellIcon
				end

				local spellColor;
				if HHSpells:isSpellKnown(spellIcon, rank) then
					spellColor = GRAY_FONT_COLOR;
				else
					spellColor = GREEN_FONT_COLOR;
				end
				GameTooltip:AddDoubleLine(beastString, FHH_SpellDescription(spellName, rank, true),
					color.r, color.g, color.b, spellColor.r, spellColor.g, spellColor.b);
				beastString = " ";
			end
		end
	else
		color = GRAY_FONT_COLOR;
		GameTooltip:AddLine(format(FHH_NUM_BEASTS_IN_ZONE, 0), color.r, color.g, color.b);
	end
	GameTooltip:Show();
	
end

local function tooltipIsBeastLore()
	local pattern = _G.GFWUtils.FormatToPattern(_G.PET_SPELLS_TEMPLATE)
	for lineNum = 1, _G['GameTooltip']:NumLines() do
		local line = _G["GameTooltipTextLeft" .. lineNum]
		local _, _, match = string.find(line:GetText(), pattern)
		if match then
			return line
		end
	end
	return false
end


function FHH_ModifyTooltip(unit)
	local creepName = UnitName(unit);
	local creepLevel = UnitLevel(unit);
	local creepFamily = UnitCreatureFamily(unit);
	local creepType = UnitClassification(unit);
	local guid = UnitGUID(unit) or ""
	local creepId = tonumber(guid:match("-(%d+)-%x+$"), 10)

	local unlocalizedCreepName = GFWTable.KeyOf(FHH_Localized, creepName);
	if (unlocalizedCreepName) then
		creepName = unlocalizedCreepName;
	end

	-- look up the list of abilities we think this critter has
	local abilitiesList = LibPet.petSkills(creepId)

	if (abilitiesList and _G.GFWTable.Count(abilitiesList) > 0) then
		-- build textual description from that list (with color coding if you're a hunter)
		local coloredList = {};
		local _, myClass = UnitClass("player");
		for spellIcon, rankNum in pairs(abilitiesList) do
			local spellId, spellName = PetSpells.getSpellFromIcon(spellIcon, rankNum)

			if (myClass == "HUNTER") then
				if (HHSpells:isSpellKnown(spellIcon, rankNum) ~= nil) then
					table.insert(coloredList, GRAY_FONT_COLOR_CODE..FHH_SpellDescription(spellName, rankNum)..FONT_COLOR_CODE_CLOSE);
				else
					table.insert(coloredList, GREEN_FONT_COLOR_CODE..FHH_SpellDescription(spellName, rankNum)..FONT_COLOR_CODE_CLOSE);
				end
			else
				table.insert(coloredList, FHH_SpellDescription(spellName, rankNum));
			end
		end
		local abilitiesText = table.concat(coloredList, ", ");
		abilitiesText = string.gsub(abilitiesText, "( %d+)", " ("..RANK.."%1)");

		-- add it to the tooltip (or, if Beast Lore, replace its line with our color-coded one)
		local lineText = tooltipIsBeastLore()
		if (lineText) then
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

function FHH_Find(spellIcon, rankNum) --TODO: Rewrite this
	rankNum = tonumber(rankNum);
	local spellInfo = PetSpells.getSpellPropertiesByIcon(spellIcon, rankNum or 1)
	local niceSpellName = _G.GetSpellInfo(spellInfo['id'])
	local isTrainer = PetSpells.getSkillSource(spellIcon) == 'trainer'

	if (rankNum) then
		if (not spellInfo) then
			GFWUtils.Print(format(FHH_FIND_RANK_UNKNOWN, GFWUtils.Hilite(niceSpellName), GFWUtils.Hilite(rankNum)));
			return;
		end

		-- report minimum pet level for ability
		local minLevel = spellInfo['level'];
		local petLevel = MAX_PLAYER_LEVEL;
		if (UnitExists("pet")) then
			petLevel = tonumber(UnitLevel("pet"));
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
	else
		local knownRanks = {};
		for rankTableNum in GFWTable.PairsByKeys(PetSpells.getSpellRanks(spellIcon)) do
			table.insert(knownRanks, rankTableNum);
		end

		GFWUtils.Print(format(FHH_FIND_RANKS_LISTED, GFWUtils.Hilite(niceSpellName))..table.concat(knownRanks, " "));

		if isTrainer then
			GFWUtils.Print(format(FHH_FIND_NEED_RANK, spellToken));
		end
	end

	-- report available creature families
	local families = PetSpells.learnableByFamilies(spellInfo['icon'])
	for key, familyId in pairs(families) do
		families[key] = LibPet.familyName(familyId)
	end
	local familyCount = _G.GFWTable.Count(families)

	if familyCount == _G.GFWTable.Count(LibPet.getFamilyNames()) then
		families = FHH_ALL_FAMILIES
	elseif familyCount == 1 then
		families = families[1]
	else
		families = table.concat(families, ", ");
	end
	GFWUtils.Print(format(FHH_FIND_LEARNABLE_BY, GFWUtils.Hilite(niceSpellName), GFWUtils.Hilite(families)))

	-- case 1: first levels of Growl are innate
	if (spellIcon == "ability_physical_taunt" and rankNum and rankNum <= 2) then
		GFWUtils.Print(format(FHH_FIND_GROWL_INNATE, GFWUtils.Hilite(niceSpellName.." "..rankNum)));
		return;
	end

	-- case 2: spells taught by trainers, for which rank doesn't matter
	if (isTrainer) then
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

	local reportLines = FHH_GenerateFindReport(spellInfo['id'], maxZones);

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
	if _G.C_Map.GetBestMapForUnit("player") == 1415 then
		return {}
	end
	local zoneId = ZoneInfo.getCurrentZoneId()
	if zoneId == nil then
		return {}
	end

	local pets = LibPet.zonePets(zoneId)
	if not pets then
		--@debug@
		print('No pets in current zone')
		--@end-debug@
		return {}
	end
	local zoneCritters = {};
	for petId, petInfo in pairs(pets) do
		local spells = LibPet.petSkills(petId)
		if spells then
			for spellIcon, rank in pairs(spells) do
				if not HHSpells:isSpellKnown(spellIcon, rank) then
					table.insert(zoneCritters, petId, petInfo);
				end
			end
		end
	end
	return zoneCritters
end

--/dump FHH_GenerateFindReport(1754, 1000)
function FHH_GenerateFindReport(spellId, maxZones)
	assert(maxZones, 'maxZones not set')
	local reportLines = {};
	local zoneId = ZoneInfo.getCurrentZoneId()

	--@debug@
	print('Current zone', zoneId)
	print('FHH_GenerateFindReport', spellId, maxZones)
	--@end-debug@
	local petList = PetSpells.getPetsWithSpell(spellId, zoneId)

	if (GFWTable.Count(petList) > 0) then
		table.insert(reportLines, {zone=_G.GetZoneText(), critters=petList});
	end

	if (maxZones > 1) then

		local zoneConnections = GFWZones.ConnectionsForZone(HHZoneLocale.unlocalize(_G.GetRealZoneText()))
		--DevTools_Dump(zoneConnections)
		--/dump _G.LibStub('LibTouristClassic-1.0'):IterateBorderZones(_G.C_Map.GetBestMapForUnit("player"))
		--local borders = Tourist:IterateBorderZones(_G.C_Map.GetBestMapForUnit("player"))
		assert(zoneConnections, 'No zone connections found')
--[[		if (zoneConnections == nil) then
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
		end]]
	
		local shouldBreak;
		for _, zones in pairs(zoneConnections) do
			for _, zoneName in pairs(zones) do
				--print('zoneName', zoneName)
				local mapId = Tourist:GetZoneMapID(zoneName)
				--assert(mapId, 'mapId not found for zoneName '..zoneName)
				if mapId ~=nil then
					zoneId = ZoneInfo.getZoneId(mapId)
					assert(zoneId, 'ZoneId not found')
					petList = PetSpells.getPetsWithSpell(spellId, zoneId)
					--critterList = FHH_FindCreatures(spellToken, rankNum, zoneName);
					petList = PetSpells.getPetsWithSpell(spellId, zoneId)
					if (_G.GFWTable.Count(petList) > 0) then
						table.insert(reportLines, {zone=HHZoneLocale.localize(zoneName), critters=petList});
						if (#reportLines >= maxZones) then
							shouldBreak = true;
							break;
						end
					end
				end
			end
			if (shouldBreak) then break; end
		end
	end

	if _G.GFWTable.Count(petList) == 0 then
		--@debug@
		utils:sprintf('No pets found for spell %s', spellId)
		--@end-debug@
	end
	return reportLines;
end

function FHH_CreatureListString(critterList) --TODO: Rewrite this together with find
	_G['CritterList'] = critterList

	local listString = ""
	for _, petInfo in pairs(critterList) do
		listString = listString .. " " LibPet.petLevelString(petInfo)
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

function FHH_SpellDescription(niceSpellName, rankNum, pretty)
	assert(niceSpellName, 'Spell name missing')
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

function FHH_SpellHasLearnableBeasts(spellIcon, spellRank)
	local source = PetSpells.getSkillSource(spellIcon, spellRank)
	if (source == 'trainer') then
		return false
	elseif type(source) == 'table' then
		return true
	elseif source == nil or source == 'unknown' then
		return false
	else
		GFWUtils.Print('Unknown source '..source .. ', Icon: ' .. spellIcon .. ', Rank: ' .. spellRank)
		return false
		-- error('Unknown source '..source)
	end
end

function FHH_GetSpellBeastCount(spellIcon, spellRank)
	local source = PetSpells.getSkillSource(spellIcon, spellRank)
	if type(source) == 'table' then
		return #PetSpells.getSkillSource(spellIcon, spellRank)
	else
		return 0
	end
end

function FHH_ShowOptions()
	LibStub("AceConfigDialog-3.0"):Open("HunterPetHelper_options")
end
