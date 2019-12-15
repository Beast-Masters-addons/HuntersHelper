------------------------------------------------------
-- HuntersHelperUI.lua
-- $Id: HuntersHelperUI.lua 658 2008-06-21 00:56:15Z rick $
------------------------------------------------------

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
	UIDropDownMenu_Initialize(FHH_UIFamilyDropDown, FHH_UIFamilyDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(FHH_UIFamilyDropDown, FHH_UIFilterFamily or FHH_UI_ALL_FAMILIES);
		
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
		local currentZone = GFWZones.UnlocalizedZone(GetRealZoneText());
		local zoneConnections = GFWZones.ConnectionsForZone(currentZone);
		local zoneList = {currentZone};
		for stepsAway, zones in pairs(zoneConnections) do
			for _, zone in pairs(zones) do
				table.insert(zoneList, zone);
			end
		end
		for _, zone in pairs(zoneList) do
			local zoneCritters = {};
			for beastName, info in pairs(FHH_BeastInfo) do
				if (not FHH_UIFilterName or string.find(string.lower(zone), FHH_UIFilterName) or string.find(string.lower(beastName), FHH_UIFilterName)) then
					if (not FHH_UIFilterFamily or FHH_UIFilterFamily == info.f) then
						if (info.z == zone) then
							table.insert(zoneCritters, beastName);
						end
					end
				end
			end
			if (#zoneCritters > 0) then
				local listItem = {};

				listItem.name = zone;
				listItem.header = 1;
				listItem.expanded = not FHH_UICollapsedHeaders[listItem.name];
				table.insert(FHH_UIListItems, listItem);
				
				for _, beastName in pairs(zoneCritters) do 
					listItem = {};
					listItem.name = beastName;

					-- start by assuming every critter has known spells, then check each spell...
					listItem.status = "used";
					local beastInfo = FHH_BeastInfo[beastName];
					for spellToken, rank in pairs(beastInfo) do
						if (not FHH_NonSpellKeys[spellToken]) then
							if (not FHH_KnownSpells[spellToken] or (rank and not FHH_KnownSpells[spellToken][rank])) then
								-- and mark it available if we have that rank
								listItem.status = "available";
							else
								-- or unavailable if we're too low level for that rank
								local requiredLevel = FHH_RequiredLevel[spellToken];
								if (type(requiredLevel) == "table" and requiredLevel[rank] > UnitLevel("player")) then
									listItem.status = "unavailable";
								elseif (type(requiredLevel) == "number" and requiredLevel > UnitLevel("player")) then
									listItem.status = "unavailable";
								end
							end
						end
					end			

					if (not FHH_UIFilterKnownSkills[listItem.status]) then
						table.insert(FHH_UIListItems, listItem);
					end
					
				end
			end
		end
	else
		local listItem = {};
		
		listItem.name = FHH_ACTIVE_ABILITIES;
		listItem.header = 1;
		listItem.expanded = not FHH_UICollapsedHeaders[listItem.name];
		table.insert(FHH_UIListItems, listItem);
		
		for spellName, spellToken in GFWTable.PairsByKeys(FHH_SpellNamesToTokens) do
			if (not FHH_PassiveSpells[spellToken]) then
				listItem = FHH_GenerateListItem(spellName, spellToken);
				if (listItem) then
					table.insert(FHH_UIListItems, listItem);
				end
			end
		end

		listItem = {};
		listItem.name = FHH_PASSIVE_ABILITIES;
		listItem.header = 1;
		listItem.expanded = not FHH_UICollapsedHeaders[listItem.name];
		table.insert(FHH_UIListItems, listItem);
		
		for spellName, spellToken in GFWTable.PairsByKeys(FHH_SpellNamesToTokens) do
			if (FHH_PassiveSpells[spellToken]) then
				listItem = FHH_GenerateListItem(spellName, spellToken);
				if (listItem) then
					table.insert(FHH_UIListItems, listItem);
				end
			end
		end
		
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

function FHH_GenerateListItem(spellName, spellToken)
	if (not FHH_UIFilterFamily or FHH_LearnableBy[spellToken] == FHH_ALL_FAMILIES or GFWTable.KeyOf(FHH_LearnableBy[spellToken], FHH_UIFilterFamily)) then
		if (not FHH_UIFilterName or string.find(string.lower(spellName), FHH_UIFilterName)) then
			listItem = {};
			listItem.name = spellName;
			listItem.id = spellToken;
		
			local requiredLevel = FHH_RequiredLevel[spellToken];
			if (type(requiredLevel) == "table") then
				listItem.status = FHH_UISpellStatus(spellToken);
			else
				listItem.status = FHH_UISpellAndRankStatus(spellToken, 0);
			end
						
			if (not FHH_UIFilterKnownSkills[listItem.status]) then
				return listItem;
			end
		end
	end
end

function FHH_UISpellStatus(spellToken)
	-- check statuses of each rank, use priority sort to determine status for the overall spell line-item
	local statuses = {};
	for rank in pairs(FHH_RequiredLevel[spellToken]) do
		table.insert(statuses, FHH_UISpellAndRankStatus(spellToken, rank));
	end
	--DevTools_Dump({[spellToken]=statuses});
	table.sort(statuses, statusSort);
	return statuses[1];
end

function FHH_UISpellAndRankStatus(spellToken, rank)
	local requiredLevel = FHH_RequiredLevel[spellToken];
	local petKnownRank;
	if (FHH_PetKnownSpellRanks) then
	 	petKnownRank = FHH_PetKnownSpellRanks[spellToken];
	end
	local petLevel = UnitLevel("pet");
	local petFamily = UnitCreatureFamily("pet");
	
	if (FHH_KnownSpells[spellToken]) then
		-- hunter knows the spell in general, test rank
		if (type(requiredLevel) == "table") then
			if (FHH_KnownSpells[spellToken][rank]) then
				-- hunter knows this rank, check pet
				if (UnitExists("pet") and FHH_ReplacingCraftFrame) then
					if (petKnownRank and (rank <= petKnownRank)) then
						return "trained";
					else
						if (not FHH_SpellIsLearnableByFamily(spellToken, petFamily)) then
							-- pet can't learn any rank of this spell
							return "nevertrain";
						elseif (requiredLevel[rank] > petLevel) then
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
				if (UnitExists("pet") and petKnownRank == rank) then
					return "learning";
				else
					if (requiredLevel[rank] > UnitLevel("player") ) then
						return "unavailable";
					elseif (not FHH_SpellHasLearnableBeasts(spellToken, i)) then
						-- this spell can't be learned because no beasts have it
						-- TODO: should we distinguish this status from cant-learn-it-yet?
						return "unavailable";
					else
						return "available";
					end
				end
			end
		else
			-- hunter knows the only rank, check pet
			if (UnitExists("pet") and FHH_ReplacingCraftFrame) then
				if (petKnownRank) then
					return "trained";
				else
					if (not FHH_SpellIsLearnableByFamily(spellToken, petFamily)) then
						-- pet can't learn any rank of this spell
						return "nevertrain";
					elseif (requiredLevel > petLevel) then
						return "untrainable";
					else
						return "trainable";
					end
				end
			else
				return "used";
			end
		end
	else
		-- hunter doesn't know any rank of this spell
		if (UnitExists("pet") and petKnownRank == rank) then
			return "learning";
		else
			if (type(requiredLevel) == "table") then
				if (requiredLevel[rank] > UnitLevel("player") ) then
					return "unavailable";
				else
					return "available";
				end
			else
				if (requiredLevel > UnitLevel("player") ) then
					return "unavailable";
				else
					return "available";
				end
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

			listButton:SetID(listIndex);
			listButton:Show();
			
			-- Handle headers
			if ( listItem.header ) then
                local skillText = _G["FHH_UIList"..i.."Text"];
                skillText:SetText(listItem.name);
                skillButton:SetNormalFontObject("GameFontNormal");

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
                if ( listItem.status == "available" ) then
                    listButton:SetNormalFontObject("GameFontNormalLeftGreen");
                elseif ( listItem.status == "used" ) then
                    listButton:SetNormalFontObject("GameFontDisable");
                else
                    listButton:SetNormalFontObject("GameFontNormalLeftRed");
                end

				listButton.status = listItem.status;
				listButton.spell = listItem.id;
								
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

	FHH_UITrainButton:Disable();

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
			
			FHH_UIShowPetDetail(listItem.name);
			FHH_UIShowPetSpells(listItem.name);
			FHH_UIHideRanksBar();
			
		else
			FHH_UIDetailIcon:SetPoint("TOPLEFT", 8, -3);
			FHH_UIDetailName:SetPoint("TOPLEFT", 50, -5);
			FHH_UIDetailHeaderLeft:SetPoint("TOPLEFT", 0, 3);
			FHH_UIDetailHeaderLeft:SetWidth(256);
			FHH_UIDetailDescription:SetPoint("TOPLEFT", 5, -50);
		
			local ranks = FHH_RequiredLevel[listItem.id];
			if (type(ranks) == "table") then
				if (not rank or rank > #ranks) then
					local _, isHunterPet = HasPetUI();
					if (isHunterPet) then
						-- select highest trainable rank
						for i, requiredLevel in pairs(ranks) do
							if (requiredLevel <= UnitLevel("pet")) then
								if (FHH_KnownSpells[listItem.id] and FHH_KnownSpells[listItem.id][i]) then
									rank = i;
								end
							else
								break;
							end
						end
					else
						-- select highest available rank
						for i, requiredLevel in pairs(ranks) do
							if (requiredLevel <= UnitLevel("player")) then 
								if (not FHH_KnownSpells[listItem.id] or not FHH_KnownSpells[listItem.id][i]) then
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
				
				FHH_UIShowRanksBar(listItem.id);
			else
				-- this spell doesn't have ranks
				if (not rank) then
					rank = 0;
				end
				FHH_UIHideRanksBar();
			end
			
			FHH_UIShowSpellDetail(listItem.id, rank);
			FHH_UIShowSpellPets(listItem.id, rank);
						
		end
	
	else
		FHH_UIDetail:Hide();
		FHH_UIHideRanksBar();
	end

end

function FHH_UIShowRanksBar(spellToken)
	FHH_UIDetailScrollFrame:SetHeight(168);
	FHH_UIDetailScrollFrame:SetPoint("TOPLEFT", 20, -242);
	FHH_UIRankLabel:Show();
	FHH_UIHorizontalBar2Left:Show();
	FHH_UIHorizontalBar2Right:Show();
	
	local ranks = FHH_RequiredLevel[spellToken];
	for i = 1, FHH_UI_NUM_RANK_BUTTONS do
		local button = _G["FHH_UIRank"..i]
        local rankText = _G["FHH_UIRank"..i.."Text"];
		if (ranks[i]) then
			button:Show();
            rankText:SetText(i);
			button.spell = spellToken;
			button.rank = i;
			button.status = FHH_UISpellAndRankStatus(spellToken, i);
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

function FHH_UIShowSpellDetail(spellToken, rank)
	FHH_UIDetailScrollFrame:SetVerticalScroll(0);
	
	local spellID = GFWTable.KeyOf(FHH_SpellIDsToTokens, spellToken);
	local _, _, icon = GetSpellInfo(spellID);
	FHH_UIDetailIcon:SetNormalTexture(icon);
	FHH_UIDetailIconDecoration:Hide();

	local requiredLevel = FHH_RequiredLevel[spellToken];
	if (type(requiredLevel) == "table") then
		requiredLevel = requiredLevel[rank];
	end
	assert(requiredLevel, format("FHH_UIShowSpellDetail(%s,%s): can't find requiredLevel", spellToken or "nil", rank or "nil"));
	if ( UnitLevel("pet") >= requiredLevel ) then
		FHH_UIDetailRequirements:SetText(format(ITEM_REQ_SKILL, format(TRAINER_PET_LEVEL, requiredLevel)));
	else
		FHH_UIDetailRequirements:SetText(format(ITEM_REQ_SKILL, format(TRAINER_PET_LEVEL_RED, requiredLevel)));
	end
	
	local craftIndex = FHH_UICraftIndexForSpell(spellToken, rank);
	if (craftIndex) then
		local spellName, rankText, craftType, _, _, trainingPointCost = GetCraftInfo(craftIndex);
		if (trainingPointCost > 0) then
			local totalPoints, spent = GetPetTrainingPoints();
			local usablePoints = totalPoints - spent;
		
			if (FHH_PetKnownSpellRanks and FHH_PetKnownSpellRanks[spellToken] and FHH_PetKnownSpellRanks[spellToken] < rank) then
				-- show accurate cost for upgrading to new rank of same spell
				local knownRankCraftIndex = FHH_UICraftIndexForSpell(spellToken, FHH_PetKnownSpellRanks[spellToken]);
				local _, _, _, _, _, alreadySpent = GetCraftInfo(knownRankCraftIndex);
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
			FHH_UITrainButton:Enable();
		end
	else
		FHH_UIDetailCost:SetText("");
	end
		
	local descriptionText;
	if (craftIndex) then
		FHH_UIDetailDescription:SetText(GetCraftDescription(craftIndex));
		FHH_UIDetailDescription:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	elseif (spellToken == "growl" and (rank == 1 or rank == 2)) then
		FHH_UIDetailDescription:SetText(FHH_UI_GROWL_INNATE);
		FHH_UIDetailDescription:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	elseif (FHH_TrainerSpells[spellToken]) then
		FHH_UIDetailDescription:SetText(FHH_UI_GO_LEARN_TRAINER);
		FHH_UIDetailDescription:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	else
		FHH_UIDetailDescription:SetText(FHH_UI_GO_LEARN_BEAST);
		FHH_UIDetailDescription:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	
end

function FHH_UIShowSpellPets(spellToken, rank)
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
	local craftIndex = FHH_UICraftIndexForSpell(spellToken, rank);
	if (not FHH_TrainerSpells[spellToken])then
	 	if (not craftIndex or (craftIndex and FHH_Options.ShowAlreadyKnownBeasts)) then
			reportZones = FHH_GenerateFindReport(spellToken, rank, 1000);
			if (#reportZones == 0) then
				FHH_UIDetailNoDetailsText:SetText(FHH_UI_UNKNOWN_RANK);
				FHH_UIDetailNoDetailsText:Show();
			elseif (craftIndex) then
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
			local beastName = zoneDetails.critters[i];
			if (beastName) then
				detailNum = detailNum + 1;
				local detailItem = FHH_UIGetDetailItem(detailNum);
				if (i == 1) then
					detailItem:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 10, -10);
				else
					detailItem:SetPoint("TOPLEFT", "FHH_UIDetailItem"..(detailNum-2), "BOTTOMLEFT", 0, -10);
				end
				FHH_UISetBeastDetail(detailItem, beastName);
				lastLeftDetail = detailItem;
			end

			-- set up right-side detail button
			beastName = zoneDetails.critters[i+1];
			if (beastName) then
				detailNum = detailNum + 1;
				local detailItem = FHH_UIGetDetailItem(detailNum);
				detailItem:SetPoint("LEFT", "FHH_UIDetailItem"..(detailNum-1), "RIGHT", 10, 0);
				FHH_UISetBeastDetail(detailItem, beastName);
			end
		end
	end
end

function FHH_UIShowPetDetail(name)
	FHH_UIDetailScrollFrame:SetVerticalScroll(0);
	
	local info = FHH_BeastInfo[name];
	
	local icon = FHH_PetIcons[info.f];
	if (icon) then
		FHH_UIDetailIcon:SetNormalTexture("Interface\\Icons\\"..icon);
	end

	local levelString = LEVEL.." ";
	if (info.min > UnitLevel("player")) then
		levelString = levelString..RED_FONT_COLOR_CODE..info.min..FONT_COLOR_CODE_CLOSE;
	else
		levelString = levelString..info.min;
	end
	if (info.max) then
		if (info.max > UnitLevel("player")) then
			levelString = levelString.."-"..RED_FONT_COLOR_CODE..info.max..FONT_COLOR_CODE_CLOSE;
		else
			levelString = levelString.."-"..info.max;
		end
	end
	FHH_UIDetailRequirements:SetText(levelString);
		
	if (info.t == nil) then
		FHH_UIDetailIconDecoration:Hide();
		FHH_UIDetailCost:SetText("");
	elseif (info.t == 1) then	-- Elite
		FHH_UIDetailIconDecoration:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Dragon");
		FHH_UIDetailIconDecoration:Show();
		FHH_UIDetailCost:SetText(ELITE);
	elseif (info.t == 2) then	-- Rare
		FHH_UIDetailIconDecoration:SetTexture("Interface\\AddOns\\GFW_HuntersHelperUI\\Rare");
		FHH_UIDetailIconDecoration:Show();
		FHH_UIDetailCost:SetText(FHH_UI_RARE_MOB);
	elseif (info.t == 3) then	-- Rare Elite
		FHH_UIDetailIconDecoration:SetTexture("Interface\\AddOns\\GFW_HuntersHelperUI\\Rare-Elite");
		FHH_UIDetailIconDecoration:Show();
		FHH_UIDetailCost:SetText(FHH_UI_RARE_ELITE_MOB);
	end
	
	FHH_UIDetailDescription:SetText(string.format(PET_DIET_TEMPLATE, table.concat(FHH_PetDiets[info.f], ", ")));

end

function FHH_UIShowPetSpells(name)

	local info = FHH_BeastInfo[name];
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
	
	for spellToken, rank in pairs(info) do
		if (not FHH_NonSpellKeys[spellToken]) then
			detailNum = detailNum + 1;
			local detailItem = FHH_UIGetDetailItem(detailNum);
			if (detailNum == 1) then
				detailItem:SetPoint("TOPLEFT", FHH_UIDetailDescription, "BOTTOMLEFT", 10, -10);
			elseif (detailNum % 2 == 0) then
				detailItem:SetPoint("LEFT", "FHH_UIDetailItem"..(detailNum-1), "RIGHT", 10, 0);
			else
				detailItem:SetPoint("TOPLEFT", "FHH_UIDetailItem"..(detailNum-2), "BOTTOMLEFT", 0, -10);
			end
			
			local buttonName = detailItem:GetName();
			local nameText = getglobal(buttonName.."Name");
			nameText:SetText(FHH_SpellDescription(spellToken, rank, true));
			if (FHH_KnownSpells[spellToken] and (rank == nil or FHH_KnownSpells[spellToken][rank])) then
				nameText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			else
				local requiredLevel = FHH_RequiredLevel[spellToken];
				if (type(requiredLevel) == "table" and requiredLevel[rank] > UnitLevel("player")) then
					nameText:SetTextColor(0.9, 0, 0);
				elseif (type(requiredLevel) == "number" and requiredLevel > UnitLevel("player")) then
					nameText:SetTextColor(0.9, 0, 0);
				else
					nameText:SetTextColor(0, 1.0, 0);
				end
			end			

			local spellID = GFWTable.KeyOf(FHH_SpellIDsToTokens, spellToken);
			local _, _, icon = GetSpellInfo(spellID);
			SetItemButtonTexture(detailItem, icon);
			
			local levelText = getglobal(buttonName.."Count");
			levelText:SetText("");
			
			detailItem.spellToken = spellToken;
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

function FHH_UISetBeastDetail(button, name)
	local info = FHH_BeastInfo[name];
	if (info) then
		local buttonName = button:GetName();
		local nameText = getglobal(buttonName.."Name");
		nameText:SetText(FHH_Localized[name] or name);
		nameText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		
		local levelString;
		if (info.min > UnitLevel("player")) then
			levelString = RED_FONT_COLOR_CODE..info.min..FONT_COLOR_CODE_CLOSE;
		else
			levelString = info.min;
		end
		if (info.max) then
			if (info.max > UnitLevel("player")) then
				levelString = levelString.."-"..RED_FONT_COLOR_CODE..info.max..FONT_COLOR_CODE_CLOSE;
			else
				levelString = levelString.."-"..info.max;
			end
		end
		local levelText = getglobal(buttonName.."Count");
		levelText:SetText(levelString);
		
		local icon = FHH_PetIcons[info.f];
		if (not icon) then
			--DevTools_Dump({"missing family?",[name]=info})
			icon = "QuestionMark";
		end
		SetItemButtonTexture(button, "Interface\\Icons\\"..icon);

		local decoration = getglobal(buttonName.."Decoration");
		if (info.t == nil) then
			decoration:Hide();
		elseif (info.t == 1) then	-- Elite
			decoration:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Gold-Dragon");
			decoration:Show();
		elseif (info.t == 2) then	-- Rare
			decoration:SetTexture("Interface\\AddOns\\GFW_HuntersHelperUI\\Rare");
			decoration:Show();
		elseif (info.t == 3) then	-- Rare Elite
			decoration:SetTexture("Interface\\AddOns\\GFW_HuntersHelperUI\\Rare-Elite");
			decoration:Show();
		end
		
		button.beastName = name;
		button:Show();
	else
		error("missing beast info for "..(name or "'nil'"), 2);
	end
end

-- list/rank buttons

function FHH_UIListButton_OnEnter(self)
	if (not FHH_Options.NoUITooltip and self.spell) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(FHH_SpellDescription(self.spell),
			HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		
		if (self.status == "available") then
			if (FHH_TrainerSpells[self.spell]) then
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
	if (not FHH_Options.NoUITooltip) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:AddDoubleLine(FHH_SpellDescription(self.spell), RANK.." "..self.rank,
			HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b,
			GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		
		if (self.status == "available") then
			if (FHH_TrainerSpells[self.spell]) then
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
	FHH_UIFilterKnownSkills[self.value] = not (UIDropDownMenuButton_GetChecked() == 1);
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
	
	for _, family in ipairs(FHH_AllFamilies) do
		info.text = family;
		info.value = family;
		info.func = FHH_UIFamilyDropDown_OnClick;
		info.checked = (FHH_UIFilterFamily == family);
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

		local craftIndex = FHH_UICraftIndexForSpell(self.spellToken, self.rank);
		if (craftIndex) then
			GameTooltip:SetCraftSpell(craftIndex);
		else
			local rankText = "";
			if (self.rank) then
				rankText = RANK.." "..self.rank;
			end
			GameTooltip:AddDoubleLine(FHH_SpellDescription(self.spellToken), rankText,
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b,
				GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		end
		
		local requiredLevel = FHH_RequiredLevel[self.spellToken];
		if (type(requiredLevel) == "table") then
			requiredLevel = requiredLevel[self.rank];
		end
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
		
		local info = FHH_BeastInfo[self.beastName];
		local levelString;
		if (info.min > UnitLevel("player")) then
			levelString = RED_FONT_COLOR_CODE..info.min..FONT_COLOR_CODE_CLOSE;
		else
			levelString = info.min;
		end
		if (info.max) then
			if (info.max > UnitLevel("player")) then
				levelString = levelString.."-"..RED_FONT_COLOR_CODE..info.max..FONT_COLOR_CODE_CLOSE;
			else
				levelString = levelString.."-"..info.max;
			end
		end
		local typeString;
		if (info.t == 1) then	-- Elite
			typeString = ELITE;
		elseif (info.t == 2) then	-- Rare
			typeString = FHH_UI_RARE_MOB;
		elseif (info.t == 3) then	-- Rare Elite
			typeString = FHH_UI_RARE_ELITE_MOB;
		end
		if (typeString) then
			GameTooltip:AddLine(string.format(TOOLTIP_UNIT_LEVEL_CLASS_TYPE, levelString, info.f, typeString),
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		else
			GameTooltip:AddLine(string.format(TOOLTIP_UNIT_LEVEL_CLASS, levelString, info.f),
				HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end
		GameTooltip:AddLine(string.format(PET_DIET_TEMPLATE, table.concat(FHH_PetDiets[info.f], ", ")),
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

function FHH_UICraftIndexForSpell(spellToken, rank)
	if (not CraftIsPetTraining()) then return nil; end
	
	local index = FHH_UISpellCraftIndices[spellToken];
	if (type(index) == "table") then
		return index[rank];
	else
		return index;
	end
end

function FHH_UITrainButton_OnClick(_)
	local listItem = FHH_UIDisplayList[FHH_UIListSelectionIndex];
	local craftIndex = FHH_UICraftIndexForSpell(listItem.id, FHH_UISelectedRank);
	DoCraft(craftIndex);
end
