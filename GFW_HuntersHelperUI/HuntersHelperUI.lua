------------------------------------------------------
-- HuntersHelperUI.lua
-- $Id: HuntersHelperUI.lua @project-revision@ @project-date-iso@
------------------------------------------------------

local PetSpells = _G['PetSpells']
local HHSpells = _G['HHSpells']
local CurrentPet = _G['CurrentPet']
local utils = _G['BMUtils']
utils = _G.LibStub('BM-utils-1', 5)
local LibPet = _G['LibPet']
local HHZoneLocale = _G['HHZoneLocale']
local ZoneInfo = _G['ZoneInfo']

FHH_UI_MAX_LIST_DISPLAYED = 7;
FHH_UI_LIST_HEIGHT = 16;
FHH_UI_NUM_RANK_BUTTONS = 13;

FHH_UIFilterKnownSkills = {};
FHH_UICollapsedHeaders = {};

local rareColor = {GetItemQualityColor(3)};
FHH_UIColors = {
	available	= { r = 0.0, g = 1.0, b = 0.0},
	unavailable	= { r = 0.9, g = 0.0, b = 0.0},
	used		= GRAY_FONT_COLOR,
	trained		= GRAY_FONT_COLOR,
	trainable	= ITEM_QUALITY_COLORS[3],
	untrainable	= QuestDifficultyColors["verydifficult"],
	nevertrain	= QuestDifficultyColors["verydifficult"],
	learning	= QuestDifficultyColors["difficult"],
};


function FHH_UIOnLoad(self)
	local title = GetAddOnMetadata("GFW_HuntersHelper", "Title");
	local version = GetAddOnMetadata("GFW_HuntersHelper", "Version");
	FHH_UITitleText:SetText(title .. " " .. version);

	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	--FHH_UIUpdateList();
	--ShowUIPanel(FHH_UI);
end

function FHH_UIOnShow()
	FHH_UIFilterFamily = UnitCreatureFamily("pet");
	if not FHH_UIFilterFamily then
		--@debug@
		print('No active pet')
		--@end-debug@
		return
	end

	local petFamilyInfo = CurrentPet.info()
	FHH_UIFilterFamily = petFamilyInfo['id']

	UIDropDownMenu_Initialize(FHH_UIFamilyDropDown, FHH_UIFamilyDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(FHH_UIFamilyDropDown, FHH_UIFilterFamily or FHH_UI_ALL_FAMILIES);
	HHSpells:scanCraftFrame()
	FHH_UIUpdateList();
	FHH_UIUpdateDisplayList();
	FHH_UISetSelection(FHH_UIListSelectionIndex, FHH_UISelectedRank);
	FHH_UIUpdate();
end

function FHH_UIOnEvent(self, event, ...)
    local arg1 = ...
	if (event == "ADDON_LOADED" and arg1 == "GFW_HuntersHelperUI") then
		local viewBy = FHH_UIViewByZone and FHH_UI_VIEW_BY_ZONE or FHH_UI_VIEW_BY_ABILITY;
		UIDropDownMenu_SetSelectedValue(FHH_UIViewByDropDown, viewBy, 1);
		UIDropDownMenu_SetText(FHH_UIViewByDropDown, viewBy);

		self:UnregisterEvent("ADDON_LOADED");

		self:RegisterEvent("UNIT_PET_TRAINING_POINTS");
		self:RegisterEvent("UNIT_PET");
		self:RegisterEvent("CRAFT_UPDATE");

		if ( UnitExists("pet") and FHH_ReplacingCraftFrame) then
			SetPortraitTexture(FHH_UIPortrait, "pet");
		else
			SetPortraitTexture(FHH_UIPortrait, "player");
		end

	elseif ( event == "UNIT_PET" ) then

		if ( UnitExists("pet") and FHH_ReplacingCraftFrame) then
			SetPortraitTexture(FHH_UIPortrait, "pet");
		else
			SetPortraitTexture(FHH_UIPortrait, "player");
		end

	elseif ( event == "CRAFT_UPDATE" ) then

		if ( UnitExists("pet") and FHH_ReplacingCraftFrame ) then
			SetPortraitTexture(FHH_UIPortrait, "pet");
		else
			SetPortraitTexture(FHH_UIPortrait, "player");
		end

		--FHH_UIUpdateList();
		--FHH_UIUpdateDisplayList();
		--FHH_UISetSelection(FHH_UIListSelectionIndex, FHH_UISelectedRank);
		--FHH_UIUpdate();

	elseif ( event == "UNIT_PET_TRAINING_POINTS" ) then
		FHH_UIUpdateTrainingPoints();

	elseif ( event == "UNIT_PORTRAIT_UPDATE" and FHH_UI:IsShown()) then
		if ( arg1 == "pet" and FHH_ReplacingCraftFrame) then
			SetPortraitTexture(FHH_UIPortrait, "pet");
		elseif ( arg1 == "player" and (not FHH_ReplacingCraftFrame or not UnitExists("pet")) ) then
			SetPortraitTexture(FHH_UIPortrait, "player");
		end
	end
end

-- list/state management

function FHH_UIUpdateList()
	FHH_UIListItems = {};

	if (FHH_UIViewByZone) then
		local currentZone = _G.GetRealZoneText()
		local zoneConnections = GFWZones.ConnectionsForZone(HHZoneLocale.unlocalize(currentZone))
		local zoneList = {currentZone};
		for stepsAway, zones in pairs(zoneConnections) do
			for _, zone in pairs(zones) do
				table.insert(zoneList, zone);
			end
		end
		for key, zone in pairs(zoneList) do
			local zoneId, zoneName
			if key == 1 then
				zoneId = ZoneInfo.getCurrentZoneId()
				zoneName = zone --Current zone is already localized
			else
				zoneId = ZoneInfo.getZoneIdByName(zone)
				zoneName = HHZoneLocale.localize(zone)
			end

			local zonePets = {}
			if zoneId ~= nil then
				zonePets = LibPet.zonePets(zoneId)
			end

			if (zonePets ~= {}) then
				local listItemHeader = {};

				--Zone name header
				listItemHeader.name = zoneName
				listItemHeader.header = 1;
				listItemHeader.expanded = not FHH_UICollapsedHeaders[listItemHeader.name];

				if zonePets ~= nil then
					for petId, petInfo in pairs(zonePets) do
						local listItem = {};
						listItem.name = petInfo['name'];
						listItem.petInfo = petInfo
						listItem.petSpells = LibPet.petSkills(petId)

						-- start by assuming every critter has known spells, then check each spell...
						-- Check pet spells to determine if the pet has available spells
						listItem.status = "used";
						if listItem.petSpells ~= nil then
							for spellIcon, rank in pairs(listItem.petSpells) do
								if (not HHSpells:isSpellKnown(spellIcon, rank)) then
									-- and mark it available if we have that rank
									listItem.status = "available";
								else
									local spell = PetSpells.getSpellPropertiesByIcon(spellIcon, rank)
									-- or unavailable if we're too low level for that rank
									if (spell['level'] > _G.UnitLevel("player")) then
										listItem.status = "unavailable";
									end
								end
							end

							if (listItem.petSpells ~= {} and not FHH_UIFilterKnownSkills[listItem.status]) then
								if listItemHeader ~= nil then
									table.insert(FHH_UIListItems, listItemHeader)
									listItemHeader = nil
								end
								table.insert(FHH_UIListItems, listItem);
							end
						end
					end
				end
			end
		end
	else
		HHSpells:buildSpellList(false)
		HHSpells:buildSpellList(true)
	end
end

local statusPriority = {
	["trainable"]	= 1,
	["learning"]	= 2,
	["untrainable"]	= 3,
	["nevertrain"]	= 3,
	["available"]	= 4,
	["unavailable"]	= 5,
	["used"]		= 6,
	["trained"]		= 6,
};
local function statusSort(a,b)
	local aPriority = statusPriority[a];
	local bPriority = statusPriority[b];
	return aPriority < bPriority;
end

local function valueInTable(table, value)
	assert(type(table) == 'table', 'Bad argument #1 to valueInTable (table expected)')
	for _, value_check in pairs(table) do
		if value == value_check then
			return true
		end
	end
	return false
end

---Generate spell list item
---@param spellName string
---@param spellIcon string
function FHH_GenerateListItem(spellName, spellIcon)
	--Show only spells learnable by the given family
	if _G.FHH_UIFilterFamily and not PetSpells.learnableByFamily(spellIcon, _G.FHH_UIFilterFamily) then
		return
	end

	--Filter by spell name
	if FHH_UIFilterName and string.find(string.lower(spellName), FHH_UIFilterName) == nil then
		return
	end

	local listItem = {};
	listItem.name = spellName
	listItem.id = spellIcon
	listItem.status = FHH_UISpellStatus(spellIcon)

	if (not FHH_UIFilterKnownSkills[listItem.status]) then
		return listItem;
	end
end

function FHH_UISpellStatus(spellIcon)
	-- check statuses of each rank, use priority sort to determine status for the overall spell line-item
	local statuses = {};
	for rank in pairs(_G['PetSpellRanks'][spellIcon]) do
		table.insert(statuses, FHH_UISpellAndRankStatus(spellIcon, rank));
	end
	--DevTools_Dump({[spellToken]=statuses});
	table.sort(statuses, statusSort);
	return statuses[1];
end

function FHH_UISpellAndRankStatus(spellIcon, rank)
	local spell = PetSpells.getSpellPropertiesByIcon(spellIcon, rank)
	local petKnownRank;
	petKnownRank = HHSpells:getHighestKnownRank(spellIcon)

	if (HHSpells:hunterKnowSpell(spellIcon)) then
		-- hunter knows the spell in general, test rank
		local petSpellInfo = HHSpells:isSpellKnown(spellIcon, rank)
		if petSpellInfo ~= nil then
			-- hunter knows this rank, check pet
			if (_G.UnitExists("pet") and _G.FHH_ReplacingCraftFrame) then
				if petSpellInfo['petKnows'] == true then
					return "trained";
				else
					local petFamilyInfo = LibPet.getFamilyInfoFromTexture(_G.GetPetIcon())
					if (not PetSpells.learnableByFamily(spellIcon, petFamilyInfo['id'])) then
						-- pet can't learn any rank of this spell
						return "nevertrain";
					elseif (spell['level'] > _G.UnitLevel("pet")) then
						return "untrainable";
					else
						return "trainable";
					end
				end
			else
				return "used";
			end
		else
			-- hunter doesn't know this rank
			if (_G.UnitExists("pet") and petKnownRank == rank) then
				return "learning";
			else
				if (spell['level'] > UnitLevel("player") ) then
					return "unavailable";
				elseif (not FHH_SpellHasLearnableBeasts(spellIcon, rank)) then
					-- this spell can't be learned because no beasts have it
					-- TODO: should we distinguish this status from cant-learn-it-yet?
					return "unavailable";
				else
					return "available";
				end
			end
		end
	else
		-- hunter doesn't know any rank of this spell
		if (UnitExists("pet") and petKnownRank == rank) then
			return "learning";
		else
			if (spell['level'] > UnitLevel("player")) then
				return "unavailable";
			else
				return "available";
			end
		end
	end
end

function FHH_UIUpdateDisplayList()
	local underCollapsed;
	local headerCount, collapsedCount = 0, 0;
	FHH_UIDisplayList = {};
	for _, listItem in ipairs(FHH_UIListItems) do
		if (listItem.header) then
			headerCount = headerCount + 1;
			if (not listItem.expanded) then
				collapsedCount = collapsedCount + 1;
			end
		end
		if (underCollapsed) then
			if (listItem.header) then
				if (listItem.expanded) then
					underCollapsed = false;
				end
				table.insert(FHH_UIDisplayList, listItem);
			end
		else
			table.insert(FHH_UIDisplayList, listItem);
			if (listItem.header and not listItem.expanded) then
				underCollapsed = true;
			end
		end
	end
	FHH_UIListSelectionIndex = FHH_UIGetFirstSelectableIndex(FHH_UIListSelectionIndex);

	-- If all headers are not expanded then show collapse button, otherwise show the expand button
	if ( headerCount == collapsedCount ) then
		FHH_UICollapseAllButton.collapsed = 1;
		FHH_UICollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
	else
		FHH_UICollapseAllButton.collapsed = nil;
		FHH_UICollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
	end
end

function FHH_UIGetFirstSelectableIndex(id)
	local index = id;
	if (index == nil or index == 0) then
		index = 1;
	end
	local selectedItem = FHH_UIDisplayList[index];
	local isHeader;
	while (selectedItem) do
		isHeader = selectedItem.header;
		if (not isHeader) then break; end
		index = index + 1;
		selectedItem = FHH_UIDisplayList[index];
	end
	if (selectedItem) then
		return index;
	else
		return 0;
	end
end

-- display

function FHH_UIUpdate()
	local numListItems = #FHH_UIDisplayList;
	local listOffset = FauxScrollFrame_GetOffset(FHH_UIListScrollFrame);

	-- If empty
	if ( numListItems == 0 ) then
		FHH_UICollapseAllButton:Disable();
	else
		FHH_UICollapseAllButton:Enable();
	end

	-- ScrollFrame update
	FauxScrollFrame_Update(FHH_UIListScrollFrame, numListItems, FHH_UI_MAX_LIST_DISPLAYED, FHH_UI_LIST_HEIGHT, nil, nil, nil, FHH_UIHighlightFrame, 293, 316 );

	FHH_UIHighlightFrame:Hide();
	for i=1, FHH_UI_MAX_LIST_DISPLAYED, 1 do
		local listIndex = i + listOffset;
		local listItem = FHH_UIDisplayList[listIndex];
        local skillButton = _G["FHH_UIList"..i];
		local listButton = skillButton

        if ( listIndex <= numListItems ) then
			-- Set button widths if scrollbar is shown or hidden
			if ( FHH_UIListScrollFrame:IsShown() ) then
				listButton:SetWidth(293);
			else
				listButton:SetWidth(323);
			end
            local skillSubText = _G["FHH_UIList"..i.."SubText"];

			skillButton:SetNormalFontObject("GameFontNormalLeft");
			listButton:SetID(listIndex);
			listButton:Show();

			-- Handle headers
			if ( listItem.header ) then
                local skillText = _G["FHH_UIList"..i.."Text"];
                skillText:SetText(listItem.name);
				skillText:SetTextColor(1, 0.82, 0) --TradeSkillTypeColor["header"]

                skillSubText:Hide();
				if ( listItem.expanded ) then
					listButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
				else
					listButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
				end
                _G["FHH_UIList"..i.."Highlight"]:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight");

				listButton.status = nil;
				listButton.spell = nil;
			else
				if ( not listItem ) then
					return;	-- we shouldn't get here
				end
                skillButton:SetNormalTexture("");
                _G["FHH_UIList"..i.."Highlight"]:SetTexture("");
                local skillText = _G["FHH_UIList"..i.."Text"];
                skillText:SetText("  "..listItem.name)

				local color = FHH_UIColors[listItem.status];
				skillText:SetTextColor(color.r, color.g, color.b);

				listButton.status = listItem.status;
				listButton.spell = listItem.id;
				listButton.name = listItem.name

				listButton:SetNormalTexture("");

				-- Place the highlight and lock the highlight state
				if ( FHH_UIListSelectionIndex == listIndex ) then
					FHH_UIHighlight:SetVertexColor(color.r, color.g, color.b);
					FHH_UIHighlightFrame:SetPoint("TOPLEFT", "FHH_UIList"..i, "TOPLEFT", 0, 0);
					FHH_UIHighlightFrame:Show();
					listButton:LockHighlight();
				else
					listButton:UnlockHighlight();
				end
			end
		else
			listButton:Hide();
		end
	end
	FHH_UIUpdateTrainingPoints();
end

function FHH_UISetSelection(id, rank)
	if FHH_ReplacingCraftFrame then
		_G.CraftCreateButton:SetParent(FHH_UI)
		_G.CraftCreateButton:Disable();
	end

	FHH_UIListSelectionIndex = id;
	FHH_UISelectedRank = rank;

	local listItem = FHH_UIDisplayList[id];
	if (listItem and not listItem.header) then
		FHH_UIDetail:Show();

		FHH_UIDetailName:SetText(listItem.name);
		if (FHH_UIViewByZone) then
			FHH_UIDetailIcon:SetPoint("TOPLEFT", 18, -13);
			FHH_UIDetailName:SetPoint("TOPLEFT", 60, -15);
			FHH_UIDetailHeaderLeft:SetPoint("TOPLEFT", 10, -7);
			FHH_UIDetailHeaderLeft:SetWidth(246);
			FHH_UIDetailDescription:SetPoint("TOPLEFT", 5, -60);

			FHH_UIShowPetDetail(listItem);
			FHH_UIShowPetSpells(listItem);
			FHH_UIHideRanksBar();
		else
			FHH_UIDetailIcon:SetPoint("TOPLEFT", 8, -3);
			FHH_UIDetailName:SetPoint("TOPLEFT", 50, -5);
			FHH_UIDetailHeaderLeft:SetPoint("TOPLEFT", 0, 3);
			FHH_UIDetailHeaderLeft:SetWidth(256);
			FHH_UIDetailDescription:SetPoint("TOPLEFT", 5, -50);
			local ranks = PetSpells.getSpellRanks(listItem.id)
			if (#ranks > 1) then
				if (not rank or rank > #ranks) then
					local _, isHunterPet = HasPetUI();
					if (isHunterPet) then
						-- select highest trainable rank
						for i, spellId in ipairs(ranks) do
							local spellInfo = PetSpells.getSpellProperties(spellId)
							if (spellInfo['level'] <= UnitLevel("pet")) then
								if HHSpells:isSpellKnown(listItem.id, i) then
									rank = i;
								end
							else
								break;
							end
						end
					else
						-- select highest available rank
						for i, spellId in ipairs(ranks) do
							local spellInfo = PetSpells.getSpellProperties(spellId)
							if (spellInfo['level'] <= UnitLevel("player")) then
								if HHSpells:isSpellKnown(listItem.id, i) then
									rank = i;
								end
							end
						end
						-- or highest rank if we know them all
						if (not rank or rank > #ranks) then
							rank = #ranks;
						end
					end
					if (not rank) then
						rank = 1;
					end
					FHH_UISelectedRank = rank;
				end
				FHH_UIShowRanksBar(listItem.id, ranks);
			else
				-- this spell doesn't have ranks
				rank = 1;
				FHH_UIHideRanksBar();
			end

			FHH_UIShowSpellDetail(listItem.id, rank);
			FHH_UIShowSpellPets(listItem.id, rank);
		end
	else
		FHH_UIDetail:Hide();
		FHH_UIHideRanksBar();
	end
	--@debug@
	--utils:printf('Set selection to id %s and rank %s', id, rank or 'nil')
	--@end-debug@
end

function FHH_UIShowRanksBar(spellIcon, ranks)
	FHH_UIDetailScrollFrame:SetHeight(168);
	FHH_UIDetailScrollFrame:SetPoint("TOPLEFT", 20, -242);
	FHH_UIRankLabel:Show();
	FHH_UIHorizontalBar2Left:Show();
	FHH_UIHorizontalBar2Right:Show();

	for i = 1, FHH_UI_NUM_RANK_BUTTONS do
		local button = _G["FHH_UIRank"..i]
        local rankText = _G["FHH_UIRank"..i.."Text"];
		if (ranks[i]) then
			button:Show();
            rankText:SetText(i);
			button.spell = ranks[i];
			button.rank = i;
			button.status = FHH_UISpellAndRankStatus(spellIcon, i);
			local color = FHH_UIColors[button.status];
            rankText:SetTextColor(color.r, color.g, color.b);

			-- Place the highlight and lock the highlight state
			if ( FHH_UISelectedRank == i ) then
				--FHH_UIRankHighlight:SetVertexColor(button:GetTextColor());
				FHH_UIRankHighlight:SetVertexColor(color.r, color.g, color.b);
				FHH_UIRankHighlightFrame:SetPoint("TOPLEFT", "FHH_UIRank"..i, "TOPLEFT", 0, 0);
				FHH_UIRankHighlightFrame:Show();
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end
		else
			button:Hide();
		end
	end
end

function FHH_UIHideRanksBar()
	FHH_UIDetailScrollFrame:SetHeight(192);
	FHH_UIDetailScrollFrame:SetPoint("TOPLEFT", 20, -218);
	FHH_UIRankHighlightFrame:Hide();
	FHH_UIRankLabel:Hide();
	FHH_UIHorizontalBar2Left:Hide();
	FHH_UIHorizontalBar2Right:Hide();
	for i = 1, FHH_UI_NUM_RANK_BUTTONS do
		local button = getglobal("FHH_UIRank"..i);
		button:Hide();
	end
end

function FHH_UIShowSpellDetail(spellIcon, rank)
	local spell = PetSpells.getSpellPropertiesByIcon(spellIcon, rank)
	local spellCraftInfo = HHSpells:isSpellKnown(spellIcon, rank)
	FHH_UIDetailScrollFrame:SetVerticalScroll(0);

	FHH_UIDetailIcon.spell = spell['id']
	FHH_UIDetailIcon:SetNormalTexture(spell['icon_texture']);
	FHH_UIDetailIconDecoration:Hide();

	local requiredLevel = spell['level']
	assert(requiredLevel, format("FHH_UIShowSpellDetail(%s,%s): can't find requiredLevel", spellIcon or "nil", rank or "nil"));
	if ( UnitLevel("pet") >= requiredLevel ) then
		FHH_UIDetailRequirements:SetText(format(ITEM_REQ_SKILL, format(TRAINER_PET_LEVEL, requiredLevel)));
	else
		FHH_UIDetailRequirements:SetText(format(ITEM_REQ_SKILL, format(TRAINER_PET_LEVEL_RED, requiredLevel)));
	end

	if (spellCraftInfo ~= nil) then
		local craftType = spellCraftInfo['craftType']
		local trainingPointCost = spellCraftInfo['trainingPointCost']
		if (trainingPointCost > 0) then
			local totalPoints, spent = GetPetTrainingPoints();
			local usablePoints = totalPoints - spent;
			local petKnownRank = HHSpells:getHighestKnownRank(spellIcon)
			if (petKnownRank > 0 and petKnownRank < rank) then
				-- show accurate cost for upgrading to new rank of same spell
				local knownRank = HHSpells:getHighestKnownRank(spellIcon)
				local knownRankCraftInfo = HHSpells:isSpellKnown(spellIcon, knownRank)

				local _, _, _, _, _, alreadySpent = GetCraftInfo(knownRankCraftInfo['craftIndex']);
				local effectiveCost = trainingPointCost - alreadySpent;

				local baseCostText = trainingPointCost;
				if (trainingPointCost > usablePoints) then
					baseCostText = RED_FONT_COLOR_CODE..trainingPointCost..FONT_COLOR_CODE_CLOSE;
				end
				local effectiveCostText = effectiveCost;
				if (effectiveCost > usablePoints) then
					effectiveCostText = RED_FONT_COLOR_CODE..effectiveCostText..FONT_COLOR_CODE_CLOSE;
				end
				local alreadySpentText = GREEN_FONT_COLOR_CODE.."-"..alreadySpent..FONT_COLOR_CODE_CLOSE;
				local allCostText = format("%s (%s%s)", effectiveCostText, baseCostText, alreadySpentText);
				FHH_UIDetailCost:SetText(COSTS_LABEL.." "..allCostText.." "..TRAINING_POINTS_LABEL);
			else
				if ( usablePoints >= trainingPointCost ) then
					FHH_UIDetailCost:SetText(COSTS_LABEL.." "..trainingPointCost.." "..TRAINING_POINTS_LABEL);
				else
					FHH_UIDetailCost:SetText(COSTS_LABEL.." "..RED_FONT_COLOR_CODE..trainingPointCost..FONT_COLOR_CODE_CLOSE.." "..TRAINING_POINTS_LABEL);
				end
			end
		else
			FHH_UIDetailCost:SetText("");
		end

		if (craftType ~= "used") then
			_G.CraftCreateButton:Enable();
		end
	else
		FHH_UIDetailCost:SetText("");
	end

	if (spellCraftInfo ~= nil) then
		FHH_UIDetailDescription:SetText(GetCraftDescription(spellCraftInfo['craftIndex']));
		FHH_UIDetailDescription:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	elseif (spellIcon == "ability_physical_taunt" and (rank == 1 or rank == 2)) then
		FHH_UIDetailDescription:SetText(FHH_UI_GROWL_INNATE);
		FHH_UIDetailDescription:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	elseif (spell['source']=='trainer') then
		FHH_UIDetailDescription:SetText(FHH_UI_GO_LEARN_TRAINER);
		FHH_UIDetailDescription:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	else
		FHH_UIDetailDescription:SetText(FHH_UI_GO_LEARN_BEAST);
		FHH_UIDetailDescription:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
end

function FHH_UIShowSpellPets(spellIcon, rank)
	--@debug@
	utils:printf('Show pets for %s rank %s', spellIcon, rank)
	--@end-debug@
	local detailNum = 0;
	local lastLeftDetail;

	for i = 1, FHH_NumZoneHeaders do
		local header = getglobal("FHH_UIDetailZoneHeader"..i);
		header:Hide();
		header:ClearAllPoints();
	end
	for i = 1, FHH_NumDetailItems do
		local button = getglobal("FHH_UIDetailItem"..i);
		button:Hide();
		button:ClearAllPoints();
	end

	FHH_UIDetailNoDetailsText:Hide();
	local reportZones = {};
	--local craftIndex = FHH_UICraftIndexForSpell(spellIcon, rank);
	local spellInfo = PetSpells.getSpellPropertiesByIcon(spellIcon, rank)
	local craftInfo = HHSpells:isSpellKnown(spellIcon, rank)
	local craftIndex
	local isSpellKnown = craftInfo ~= nil
	if craftInfo ~= nil then
		craftIndex = craftInfo['craftIndex']
	end

	if spellInfo['source'] ~= 'trainer' then
		if not isSpellKnown or (isSpellKnown and _G['HuntersHelperDB'].show_known) then
			reportZones = FHH_GenerateFindReport(spellInfo['id'], 1000);
			if (#reportZones == 0) then
				FHH_UIDetailNoDetailsText:SetText(FHH_UI_UNKNOWN_RANK);
				FHH_UIDetailNoDetailsText:Show();
			elseif (isSpellKnown) then
				FHH_UIDetailNoDetailsText:SetText(FHH_UI_ALSO_FOUND_ON);
				FHH_UIDetailNoDetailsText:Show();
			end
		end
	end

	for zoneNum, zoneDetails in ipairs(reportZones) do
		local header = FHH_UIGetZoneHeader(zoneNum);
		if (zoneNum == 1) then
			if (FHH_UIDetailNoDetailsText:IsShown()) then
				header:SetPoint("TOPLEFT", FHH_UIDetailNoDetailsText, "BOTTOMLEFT", 0, -10);
			else
				header:SetPoint("TOPLEFT", FHH_UIDetailDescription, "BOTTOMLEFT", 0, -10);
			end
		else
			header:SetPoint("TOPLEFT", lastLeftDetail, "BOTTOMLEFT", -10, -10);
		end
		header:SetText(zoneDetails.zone);
		header:Show();

		for i = 1, #zoneDetails.critters, 2 do
			-- set up left-side detail button
			local petInfo = zoneDetails.critters[i]
			if (petInfo) then
				detailNum = detailNum + 1;
				local detailItem = FHH_UIGetDetailItem(detailNum);
				if (i == 1) then
					detailItem:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 10, -10);
				else
					detailItem:SetPoint("TOPLEFT", "FHH_UIDetailItem"..(detailNum-2), "BOTTOMLEFT", 0, -10);
				end
				FHH_UISetBeastDetail(detailItem, petInfo);
				lastLeftDetail = detailItem;
			end

			-- set up right-side detail button
			petInfo = zoneDetails.critters[i+1];
			if (petInfo) then
				detailNum = detailNum + 1;
				local detailItem = FHH_UIGetDetailItem(detailNum);
				detailItem:SetPoint("LEFT", "FHH_UIDetailItem"..(detailNum-1), "RIGHT", 10, 0);
				FHH_UISetBeastDetail(detailItem, petInfo);
			end
		end
	end
end

function FHH_UIShowPetDetail(listItem)
	local petInfo = listItem.petInfo
	local familyInfo = LibPet.familyInfo(petInfo['family'])
	--@debug@
	print('Show pet details', petInfo['name'])
	--@end-debug@
	FHH_UIDetailScrollFrame:SetVerticalScroll(0);

	--local info = FHH_BeastInfo[petInfo['name']];

	if (familyInfo and familyInfo['icon_texture']) then
		FHH_UIDetailIcon:SetNormalTexture(familyInfo['icon_texture']);
	end

	if petInfo['minlevel'] ~= nil then
		local levelString = _G.LEVEL.." "..LibPet.levelRange(petInfo['minlevel'], petInfo['maxlevel'], _G.UnitLevel("player"));
		FHH_UIDetailRequirements:SetText(levelString)
	end

	if (petInfo['classification'] == 0) then
		FHH_UIDetailIconDecoration:Hide();
		FHH_UIDetailCost:SetText("");
	else
		local texture = LibPet.getClassificationDecoration(petInfo['classification'])
		local text = LibPet.getClassificationString(petInfo['classification'])
		FHH_UIDetailIconDecoration:SetTexture(texture);
		FHH_UIDetailIconDecoration:Show();
		FHH_UIDetailCost:SetText(text);
	end

	local diet = LibPet.getDietStrings(familyInfo['id'])
	FHH_UIDetailDescription:SetText(string.format(PET_DIET_TEMPLATE, table.concat(diet, ", ")));
end

function FHH_UIShowPetSpells(listItem)
	local petInfo = listItem.petInfo
	local detailNum = 0;

	for i = 1, FHH_NumZoneHeaders do
		local header = getglobal("FHH_UIDetailZoneHeader"..i);
		header:Hide();
		header:ClearAllPoints();
	end

	for i = 1, FHH_NumDetailItems do
		local button = getglobal("FHH_UIDetailItem"..i);
		button:Hide();
		button:ClearAllPoints();
	end

	for spellIcon, rank in pairs(listItem.petSpells) do
		local spellInfo = PetSpells.getSpellPropertiesByIcon(spellIcon, rank)
		if spellInfo ~= nil then

			detailNum = detailNum + 1;
			local detailItem = FHH_UIGetDetailItem(detailNum);
			detailItem.spellInfo = spellInfo

			if (detailNum == 1) then
				detailItem:SetPoint("TOPLEFT", FHH_UIDetailDescription, "BOTTOMLEFT", 10, -10);
			elseif (detailNum % 2 == 0) then
				detailItem:SetPoint("LEFT", "FHH_UIDetailItem"..(detailNum-1), "RIGHT", 10, 0);
			else
				detailItem:SetPoint("TOPLEFT", "FHH_UIDetailItem"..(detailNum-2), "BOTTOMLEFT", 0, -10);
			end

			local buttonName = detailItem:GetName();
			local nameText = getglobal(buttonName.."Name");
			nameText:SetText(FHH_SpellDescription(spellInfo['name'], rank, true));
			if (HHSpells:isSpellKnown(spellIcon, rank)) then
				nameText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			else
				local requiredLevel = spellInfo['level']
				if (type(requiredLevel) == "table" and requiredLevel[rank] > UnitLevel("player")) then
					nameText:SetTextColor(0.9, 0, 0);
				elseif (type(requiredLevel) == "number" and requiredLevel > UnitLevel("player")) then
					nameText:SetTextColor(0.9, 0, 0);
				else
					nameText:SetTextColor(0, 1.0, 0);
				end
			end

			--local spellID = GFWTable.KeyOf(FHH_SpellIDsToTokens, spellToken);
			--local _, _, icon = GetSpellInfo(spellInfo['id']);
			SetItemButtonTexture(detailItem, spellInfo['icon_texture']);

			local levelText = getglobal(buttonName.."Count");
			levelText:SetText("");

			detailItem.spellIcon = spellIcon
			detailItem.spellInfo = spellInfo
			detailItem.rank = rank;
			detailItem:Show();
		end
	end
end

FHH_NumZoneHeaders = 0;
function FHH_UIGetZoneHeader(id)
	local header = getglobal("FHH_UIDetailZoneHeader"..id);
	if (not header) then
		header = FHH_UIDetail:CreateFontString("FHH_UIDetailZoneHeader"..id, "BACKGROUND", "GameFontNormal");
		FHH_NumZoneHeaders = FHH_NumZoneHeaders + 1;
	end
	return header;
end

FHH_NumDetailItems = 0;
function FHH_UIGetDetailItem(id)
	local button = getglobal("FHH_UIDetailItem"..id);
	if (not button) then
		button = CreateFrame("Button", "FHH_UIDetailItem"..id, FHH_UIDetail, "FHH_UIDetailItemTemplate");
		FHH_NumDetailItems = FHH_NumDetailItems + 1;
	end
	return button;
end

function FHH_UISetBeastDetail(button, petInfo)
	if (petInfo) then
		local buttonName = button:GetName();
		local nameText = getglobal(buttonName.."Name");
		nameText:SetText(FHH_Localized[petInfo['name']] or petInfo['name']);
		nameText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		if petInfo['minlevel'] ~= nil then
			local levelString = LibPet.levelRange(petInfo['minlevel'], petInfo['maxlevel'], _G.UnitLevel("player"))
			local levelText = getglobal(buttonName.."Count");
			levelText:SetText(levelString);
			button.levelString = levelString
		else
			button.levelString = nil
		end

		local icon = LibPet.familyInfo(petInfo['family'])['icon_texture']
		if (not icon) then
			--DevTools_Dump({"missing family?",[name]=info})
			icon = "QuestionMark";
		end
		SetItemButtonTexture(button, icon);

		local decoration = getglobal(buttonName.."Decoration");
		if petInfo['classification'] ~= nil then
			local texture = LibPet.getClassificationDecoration(petInfo['classification'])
			decoration:SetTexture(texture)
			decoration:Show()
		else
			decoration:Hide();
		end

		button.beastName = petInfo['name'];
		button.petInfo = petInfo
		button:Show();
	else
		error("missing beast info for "..(petInfo['name'] or "'nil'"), 2);
	end
end

-- list/rank buttons

function FHH_UIListButton_OnEnter(self)
	if _G['HuntersHelperDB']['show_gui_tooltip'] and self.name then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.name,
			HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

		if (self.status == "available") then
			local spellSource = PetSpells.getSkillSource(self.id)
			if (spellSource == 'trainer') then
				GameTooltip:AddLine(FHH_UI_AVAILABLE_TRAINER);
			else
				GameTooltip:AddLine(FHH_UI_AVAILABLE_TAME);
			end
		elseif (self.status == "learning") then
			GameTooltip:AddLine(format(FHH_UI_LEARN_FROM_PET_FMT, UnitName("pet")));
		elseif (self.status == "unavailable") then
			GameTooltip:AddLine(UNAVAILABLE);
		elseif (self.status == "used") then
			GameTooltip:AddLine(USED);
		elseif (self.status == "trainable") then
			GameTooltip:AddLine(format(FHH_UI_PET_CAN_TRAIN_FMT, UnitName("pet")));
		elseif (self.status == "nevertrain") then
			GameTooltip:AddLine(format(FHH_UI_PET_NEVER_LEARN_FMT, UnitName("pet")));
		elseif (self.status == "untrainable") then
			GameTooltip:AddLine(format(FHH_UI_PET_CANT_LEARN_FMT, UnitName("pet")));
		elseif (self.status == "trained") then
			GameTooltip:AddLine(format(FHH_UI_PET_TRAINED_FMT, UnitName("pet")));
		end
		GameTooltip:Show();
	end
end

function FHH_UIListButton_OnClick(self, _)
	local clickedIndex = self:GetID();
	local clickedItem = FHH_UIDisplayList[clickedIndex];

	if (clickedItem and clickedItem.header) then
		clickedItem.expanded = not clickedItem.expanded;
		FHH_UICollapsedHeaders[clickedItem.name] = not clickedItem.expanded;
	end

	FHH_UIUpdateDisplayList();
	FHH_UISetSelection(FHH_UIGetFirstSelectableIndex(clickedIndex));
	FHH_UIUpdate();
end

function FHH_UIRankButton_OnEnter(self)
	assert(self.spell, 'Spell is not set on button')
	if (_G['HuntersHelperDB'].show_gui_tooltips) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

		local spellName = _G.GetSpellInfo(self.spell)
		FHH_SpellDescription(self.spell)
		GameTooltip:AddDoubleLine(spellName, RANK.." "..self.rank,
			HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b,
			GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);

		if (self.status == "available") then
			if (PetSpells.getSkillSource(self.spell) == 'trainer') then
				GameTooltip:AddLine(FHH_UI_AVAILABLE_TRAINER);
			else
				GameTooltip:AddLine(FHH_UI_AVAILABLE_TAME);
			end
		elseif (self.status == "learning") then
			GameTooltip:AddLine(format(FHH_UI_LEARN_FROM_PET_FMT, UnitName("pet")));
		elseif (self.status == "unavailable") then
			GameTooltip:AddLine(UNAVAILABLE);
		elseif (self.status == "used") then
			GameTooltip:AddLine(USED);
		elseif (self.status == "trainable") then
			GameTooltip:AddLine(format(FHH_UI_PET_CAN_TRAIN_FMT, UnitName("pet")));
		elseif (self.status == "nevertrain") then
			GameTooltip:AddLine(format(FHH_UI_PET_NEVER_LEARN_FMT, UnitName("pet")));
		elseif (self.status == "untrainable") then
			GameTooltip:AddLine(format(FHH_UI_PET_CANT_LEARN_FMT, UnitName("pet")));
		elseif (self.status == "trained") then
			GameTooltip:AddLine(format(FHH_UI_PET_TRAINED_FMT, UnitName("pet")));
		end
		GameTooltip:Show();
	end
end

function FHH_UIRankButton_OnClick(self, _)
	FHH_UISetSelection(FHH_UIListSelectionIndex, self:GetID());
end

-- collapse/expand all button

function FHH_UICollapseAllButton_OnClick(self)
	if (self.collapsed) then
		FHH_UIListSelectionIndex = 0;
		self.collapsed = nil;
	else
		self.collapsed = 1;
		FHH_UIListScrollFrameScrollBar:SetValue(0);
	end
	for _, listItem in ipairs(FHH_UIListItems) do
		if (listItem.header) then
			listItem.expanded = not self.collapsed;
			FHH_UICollapsedHeaders[listItem.name] = self.collapsed;
		end
	end

	FHH_UIUpdateDisplayList();
	FHH_UISetSelection(FHH_UIListSelectionIndex, FHH_UISelectedRank);
	FHH_UIUpdate();
end

-- text filter editbox

function FHH_UIFilter_OnTextChanged(self)
	local text = self:GetText();
	if ( text ~= FHH_UIFilterName) then
		if ( text == SEARCH or text == "" ) then
			FHH_UIFilterName = nil;
		else
			FHH_UIFilterName = string.lower(text);
		end
		FHH_UIUpdateList();
		FHH_UIUpdateDisplayList();
		FHH_UISetSelection(FHH_UIListSelectionIndex, FHH_UISelectedRank);
		FHH_UIUpdate();
	end
end

-- View By (ability / zone) menu

function FHH_UIViewByDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, FHH_UIViewByDropDown_Initialize);
	UIDropDownMenu_SetWidth(FHH_UIViewByDropDown, 120);
	UIDropDownMenu_SetSelectedValue(FHH_UIViewByDropDown, FHH_UIViewByZone and FHH_UI_VIEW_BY_ZONE or FHH_UI_VIEW_BY_ABILITY);
	UIDropDownMenu_SetText(FHH_UIViewByDropDown, FHH_UIViewByZone and FHH_UI_VIEW_BY_ZONE or FHH_UI_VIEW_BY_ABILITY);
end

function FHH_UIViewByDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	info.func = FHH_UIViewByDropDown_OnClick;
	info.text = FHH_UI_VIEW_BY_ABILITY;
	info.value = FHH_UI_VIEW_BY_ABILITY;
	info.checked = not FHH_UIViewByZone;
	UIDropDownMenu_AddButton(info);

	info.func = FHH_UIViewByDropDown_OnClick;
	info.text = FHH_UI_VIEW_BY_ZONE;
	info.value = FHH_UI_VIEW_BY_ZONE;
	info.checked = FHH_UIViewByZone;
	UIDropDownMenu_AddButton(info);
end

function FHH_UIViewByDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(FHH_UIViewByDropDown, self.value);
	FHH_UIViewByZone = (self.value == FHH_UI_VIEW_BY_ZONE) and 1 or nil;
	FHH_UICollapsedHeaders = {};
	FHH_UIUpdateList();
	FHH_UIUpdateDisplayList();
	FHH_UISetSelection(FHH_UIListSelectionIndex, FHH_UISelectedRank);
	FHH_UIUpdate();
end

-- filter by Known menu
function FHH_UIKnownDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, FHH_UIKnownDropDown_Initialize);
	UIDropDownMenu_SetText(self, FILTER);
	UIDropDownMenu_SetWidth(FHH_UIKnownDropDown, 120);
end

function FHH_UIKnownDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	local _, isHunterPet = HasPetUI();
	if (isHunterPet and FHH_ReplacingCraftFrame) then
		local pet = UnitName("pet");

		info.text = GREEN_FONT_COLOR_CODE..AVAILABLE..FONT_COLOR_CODE_CLOSE;
		info.value = "available";
		info.func = FHH_UIKnownDropDown_OnClick;
		info.checked = not FHH_UIFilterKnownSkills.available;
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info);

		info.text = GFWUtils.ColorToCode(FHH_UIColors.learning)..format(FHH_UI_LEARN_FROM_PET_FMT, pet)..FONT_COLOR_CODE_CLOSE;
		info.value = "learning";
		info.func = FHH_UIKnownDropDown_OnClick;
		info.checked = not FHH_UIFilterKnownSkills.learning;
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info);

		info.text = "";
		info.disabled = 1;
		info.checked = nil;
		UIDropDownMenu_AddButton(info);
		info.disabled = nil;

		info.text = RED_FONT_COLOR_CODE..UNAVAILABLE..FONT_COLOR_CODE_CLOSE;
		info.value = "unavailable";
		info.func = FHH_UIKnownDropDown_OnClick;
		info.checked = not FHH_UIFilterKnownSkills.unavailable;
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info);

		info.text = "";
		info.disabled = 1;
		info.checked = nil;
		UIDropDownMenu_AddButton(info);
		info.disabled = nil;

		info.text = GFWUtils.ColorToCode(FHH_UIColors.trainable)..format(FHH_UI_PET_CAN_TRAIN_FMT, pet)..FONT_COLOR_CODE_CLOSE;
		info.value = "trainable";
		info.func = FHH_UIKnownDropDown_OnClick;
		info.checked = not FHH_UIFilterKnownSkills.trainable;
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info);

		info.text = GFWUtils.ColorToCode(FHH_UIColors.untrainable)..format(FHH_UI_PET_CANT_LEARN_FMT, pet)..FONT_COLOR_CODE_CLOSE;
		info.value = "untrainable";
		info.func = FHH_UIKnownDropDown_OnClick;
		info.checked = not FHH_UIFilterKnownSkills.untrainable;
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info);

		info.text = GRAY_FONT_COLOR_CODE..format(FHH_UI_PET_TRAINED_FMT, pet)..FONT_COLOR_CODE_CLOSE;
		info.value = "trained";
		info.func = FHH_UIKnownDropDown_OnClick;
		info.checked = not FHH_UIFilterKnownSkills.trained;
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info);
	else
		info.text = GREEN_FONT_COLOR_CODE..AVAILABLE..FONT_COLOR_CODE_CLOSE;
		info.value = "available";
		info.func = FHH_UIKnownDropDown_OnClick;
		info.checked = not FHH_UIFilterKnownSkills.available;
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info);

		info.text = RED_FONT_COLOR_CODE..UNAVAILABLE..FONT_COLOR_CODE_CLOSE;
		info.value = "unavailable";
		info.func = FHH_UIKnownDropDown_OnClick;
		info.checked = not FHH_UIFilterKnownSkills.unavailable;
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info);

		info.text = GRAY_FONT_COLOR_CODE..USED..FONT_COLOR_CODE_CLOSE;
		info.value = "used";
		info.func = FHH_UIKnownDropDown_OnClick;
		info.checked = not FHH_UIFilterKnownSkills.used;
		info.keepShownOnClick = 1;
		UIDropDownMenu_AddButton(info);
	end
end

function FHH_UIKnownDropDown_OnClick(self)
	FHH_UIFilterKnownSkills[self.value] = not (UIDropDownMenuButton_GetChecked(self) == true);
	FHH_UIUpdateList();
	FHH_UIUpdateDisplayList();
	FHH_UISetSelection(FHH_UIListSelectionIndex, FHH_UISelectedRank);
	FHH_UIUpdate();
end

-- filter by family menu

function FHH_UIFamilyDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, FHH_UIFamilyDropDown_Initialize);
	UIDropDownMenu_SetWidth(FHH_UIFamilyDropDown, 120);
	UIDropDownMenu_SetSelectedValue(FHH_UIFamilyDropDown, FHH_UIFilterFamily or FHH_UI_ALL_FAMILIES);
end

function FHH_UIFamilyDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	info.text = FHH_UI_ALL_FAMILIES;
	info.value = nil;
	info.func = FHH_UIFamilyDropDown_OnClick;
	info.checked = (FHH_UIFilterFamily == nil);
	UIDropDownMenu_AddButton(info);

	for id, family in pairs(LibPet.getFamilyNames()) do
		info.text = family;
		info.value = id
		info.func = FHH_UIFamilyDropDown_OnClick;
		info.checked = (FHH_UIFilterFamily == id);
		UIDropDownMenu_AddButton(info);
	end
end

function FHH_UIFamilyDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedID(FHH_UIFamilyDropDown, self:GetID());
	if (self.value == FHH_UI_ALL_FAMILIES) then
		FHH_UIFilterFamily = nil;
	else
		FHH_UIFilterFamily = self.value;
	end
	FHH_UIUpdateList();
	FHH_UIUpdateDisplayList();
	FHH_UISetSelection(FHH_UIListSelectionIndex, FHH_UISelectedRank);
	FHH_UIUpdate();
end

-- Detail UI tooltips

function FHH_UIDetailIcon_OnEnter(self)

	-- only show a tooltip on this icon for spells we know;
	-- there's nothing to show for beasts that isn't already visible,
	-- likewise for spells we don't know
	if (not FHH_UIViewByZone) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetSpellByID(self.spell)

		local listItem = FHH_UIDisplayList[FHH_UIListSelectionIndex];
		local craftIndex = FHH_UICraftIndexForSpell(listItem.id, FHH_UISelectedRank);
		if (craftIndex) then
			GameTooltip:SetCraftSpell(craftIndex);
			GameTooltip:Show();
		end
	end
end

function FHH_UIDetailItem_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if (FHH_UIViewByZone) then
		-- detail items are spells
		--Properties set in FHH_UIShowPetSpells
		local spellCraftInfo = HHSpells:isSpellKnown(self.spellIcon, self.rank)

		if (spellCraftInfo ~= nil) then
			GameTooltip:SetCraftSpell(spellCraftInfo['craftIndex']);
		else
			local rankText = "";
			if (self.rank) then
				rankText = _G.RANK.." "..self.rank;
			end
			GameTooltip:AddDoubleLine(self.spellInfo['name'], rankText,
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b,
				GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		end

		local requiredLevel = self.spellInfo['level']
		if ( UnitLevel("pet") >= requiredLevel ) then
			GameTooltip:AddLine(format(ITEM_REQ_SKILL, format(TRAINER_PET_LEVEL, requiredLevel)),
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
		else
			GameTooltip:AddLine(format(ITEM_REQ_SKILL, format(TRAINER_PET_LEVEL_RED, requiredLevel)),
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
		end
		GameTooltip:Show();
	else
		-- detail items are pets
		GameTooltip:SetText(FHH_Localized[self.beastName] or self.beastName,
			HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

		local info = self.petInfo
		local levelString = self.levelString or ''

		local typeString = LibPet.getClassificationString(self.petInfo['classification'])
		if (typeString) then
			GameTooltip:AddLine(string.format(TOOLTIP_UNIT_LEVEL_CLASS_TYPE, levelString, LibPet.getLocalizedFamilyName(info['family']), typeString),
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		else
			GameTooltip:AddLine(string.format(TOOLTIP_UNIT_LEVEL_CLASS, levelString, LibPet.getLocalizedFamilyName(info['family'])),
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end
		local diet = LibPet.getDietStrings(self.petInfo['family'])
		GameTooltip:AddLine(string.format(PET_DIET_TEMPLATE, table.concat(diet, ", ")),
			HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
		GameTooltip:Show();
	end
end

-- training points display

function FHH_UIUpdateTrainingPoints()
	local totalPoints, spent = GetPetTrainingPoints();
	if ( CraftIsPetTraining() ) then
		FHH_UITrainingPointsLabel:Show();
		FHH_UITrainingPointsText:Show();
		FHH_UITrainingPointsText:SetText(totalPoints - spent);
	else
		FHH_UITrainingPointsLabel:Hide();
		FHH_UITrainingPointsText:Hide();
	end
end

-- CraftFrame related stuff

---Get craft index for spell
---/dump FHH_UICraftIndexForSpell('ability_druid_cover', 1)
---@param spellIcon string
---@param rank number
function FHH_UICraftIndexForSpell(spellIcon, rank)
	if (not _G.CraftIsPetTraining()) then return nil; end

	local index = FHH_UISpellCraftIndices[spellIcon];
	if (type(index) == "table") then
		return index[rank];
	else
		return index;
	end
end
