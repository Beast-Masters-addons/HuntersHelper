local addonName = ...
---@type HuntersHelper
local addon = _G.LibStub("AceAddon-3.0"):GetAddon(addonName)

---@class HuntersHelperConfig
local config = addon:NewModule("HuntersHelperConfig")

local AceConfig = _G.LibStub("AceConfig-3.0")
local AceConfigDialog = _G.LibStub("AceConfigDialog-3.0")
---@type HuntersHelperLDB
local ldb


local L = _G.LibStub("AceLocale-3.0"):GetLocale(addonName)

local titleText = addon.name .. " " .. addon.version;

local defaults = {
    profile = {
        beastTooltip = true,
        onlyHunter = true,
        showMinimapButton = true,
        minimapPos = 0, --243 ved klokke
        show_known = false,
        show_gui_tooltips = true,
    }
}

local options = {
    type = "group",
    name = titleText,
    get = function(info)
        local key = info[#info]
        return _G['HuntersHelperDB'][key]
    end,
    set = function(info, value)
        local key = info[#info]
        _G['HuntersHelperDB'][key] = value
        ldb:updateCount()
    end,
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
            disabled = function()
                if config:get("beastTooltip") == false then
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
            order = 11,
            set = function(arg, state)
                print('Set button', arg, state)
                _G['HuntersHelperDB'].showMinimapButton = state
                if config:get("showMinimapButton") then
                    print('Toggle show button on')
                    ldb.icon:Show(addon.name)
                else
                    ldb.icon:Hide(addon.name)
                end
            end,
        },
        minimapPos = {
            type = "range",
            name = L['minimap_button_position'],
            min = 0,
            max = 360,
            step = 1,
            order = 12,
            width = "double",
            set = function(_, value)
                ldb.icon:SetButtonToPosition(addon.name, value)
            end
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

---Open config window
function config.show()
    _G.Settings.OpenToCategory(addon.name)
end

function config.reset()
    _G['HuntersHelperDB'] = defaults['profile']
end

---Called at event ADDON_LOADED
function config:OnInitialize()
    self.optionsFrames = {}
    if _G['HuntersHelperDB'] == nil then
        self.reset()
    end
end

function config:OnEnable()
    -- Register the config
    AceConfig:RegisterOptionsTable(addon.name, options, { "/hhconf" })
    self.optionsFrames.general = AceConfigDialog:AddToBlizOptions(addon.name)--, nil, nil, "general")
    ldb = addon:GetModule("HuntersHelperLDB")
end

---Get configuration parameter
function config:get(key)
    return _G['HuntersHelperDB'][key]
end

function config:set(key, value)
    _G['HuntersHelperDB'][key] = value
end