-- https://eu.battle.net/forums/en/wow/topic/3483869500#post-2

local addonName = "GFW_HuntersHelper"
local titleText = GetAddOnMetadata(addonName, "Title");
local version = GetAddOnMetadata(addonName, "Version");
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

HunterPetHelper = LibStub("AceAddon-3.0"):NewAddon(addonName)

titleText = titleText .. " " .. version;

local db
local defaults = {
	profile = {
		beastTooltip = true,
		onlyHunter = true,
		showMinimapButton = true,
		MinimapButtonPosition = -25,
		show_known = false,
		show_gui_tooltips = true,
	}
}

local function optionGet(info)
	return db[info[#info]]
end

local function optionSet(info, value)
	db[info[#info]] = value
	FHH_MinimapButtonCheck()
end

local options = {
	type = "group",
	name = titleText,
	get = optionGet,
	set = optionSet,
	args = {
		top_description = {
			type = "description",
			name = L['options_top_description'],
			order = 1,
		},
		general_header = {
			type = "header",
			name = L['options_beast_tooltip'],
			order = 2,
			width = "full",
		},
		beastTooltip = {
			name = L['options_show_tooltip'],
			desc = L['options_show_tooltip_desc'],
			type = "toggle",
			width = "double",
			order = 3
		},
		onlyHunter = {
			name = L['options_only_hunter'],
			type = "toggle",
			width = "double",
			order = 4,
			desc = L['options_only_hunter_desc'],
			disabled = function ()
				if db.beastTooltip == false then
					return true
				else
					return false
				end
			end
		},
		minimapButtonHeader = {
			type = "header",
			name = L['options_minimap_header'],
			order = 10,
			width = "full",
		},
		showMinimapButton = {
			name = L['options_minimap_button'],
			type = "toggle",
			width = "double",
			order = 11
		},
		MinimapButtonPosition  = {
			type = "range",
			name = L['minimap_button_position'],
			min = -180,
			max = 180,
			step = 1,
			order = 12,
			width = "double",
		},
		gui_header = {
			type = "header",
			name = L['options_gui_header'],
			order = 20,
			width = "full",
		},
		show_known = {
			type = "toggle",
			name = L['options_show_already_known'],
			order = 21,
			width = "full"
		},
		show_gui_tooltips = {
			type = "toggle",
			width = "full",
			order = 22,
			name = L['options_gui_show_tooltip'],
		}
	}
}

function HunterPetHelper:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("HuntersHelperSettings", defaults, "Default")
	db = self.db.profile
	_G['HuntersHelperDB'] = db

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("HunterPetHelper_options", options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("HunterPetHelper_options", "Hunters Helper")
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, options, {"petskills", "pet"})
end
