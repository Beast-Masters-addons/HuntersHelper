local addonName = ...
---@type HuntersHelper
local addon = _G.LibStub("AceAddon-3.0"):GetAddon(addonName)
---@type HuntersHelperConfig
local options = addon:GetModule('HuntersHelperConfig')

---@class HuntersHelperLDB
local ldb = addon:NewModule("HuntersHelperLDB", "AceEvent-3.0")

function ldb:OnInitialize()
    self.ldb = _G.LibStub:GetLibrary("LibDataBroker-1.1")

    ---LDB data object
    self.obj = self.ldb:NewDataObject(addon.name, {
        type = "data source",
        text = "0",
        icon = "Interface\\Icons\\Ability_Hunter_BeastCall02"
    })

    self.obj.OnTooltipShow = self.OnTooltipShow
    self.obj.OnClick = self.OnClick

    self.icon = _G.LibStub("LibDBIcon-1.0")
    self.icon:Register(addon.name, self.obj, _G['HuntersHelperDB'])

    local button = self.icon:GetMinimapButton(addon.name)
    self.fontstring = button:CreateFontString("HH_MinimapCount", "ARTWORK", "GameFontGreen")
    self.fontstring:SetPoint("CENTER")
end

---setText
---@param text string
---@param color ColorMixin
function ldb:setText(text, color)
    if color then
        self.obj.text = color:WrapTextInColorCode(text)
    else
        self.obj.text = text
    end
    self.fontstring:SetText(text)
end

function ldb:updateCount()
    local zoneCritters = FHH_CurrentZoneLearnableBeasts();
    local count = GFWTable.Count(zoneCritters)
    if count > 0 then
        --FHH_MinimapFrame_Icon:SetVertexColor(0.5,0.5,0.5);
        self:setText(count)
        self.fontstring:Show()
    else
        --FHH_MinimapFrame_Icon:SetVertexColor(1,1,1);
        self.fontstring:Hide()
    end
end

function ldb:ZONE_CHANGED_NEW_AREA()
    self:updateCount()
end

function ldb:OnEnable()
    self:updateCount()
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")--, ldb.updateCount)
    self.icon:Show(addon.name)
end

function ldb:OnTooltipShow()
    self:AddLine(addon.name .. " " .. addon.version)
    local zoneCritters = FHH_CurrentZoneLearnableBeasts();
    local zoneCrittersCount = GFWTable.Count(zoneCritters)
    local color;
    if (zoneCrittersCount > 0) then
        color = HIGHLIGHT_FONT_COLOR;
        self:AddLine(FHH_NUM_BEASTS_IN_ZONE:format(zoneCrittersCount), color.r, color.g, color.b);
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
                self:AddDoubleLine(beastString, FHH_SpellDescription(spellName, rank, true),
                        color.r, color.g, color.b, spellColor.r, spellColor.g, spellColor.b);
                beastString = " ";
            end
        end
    else
        color = GRAY_FONT_COLOR;
        self:AddLine(format(FHH_NUM_BEASTS_IN_ZONE, 0), color.r, color.g, color.b);
    end
end

function ldb:OnClick(button)
    if button == "LeftButton" then
        FHH_ShowUI()
    elseif button == "RightButton" then
        options.show()
    end
end