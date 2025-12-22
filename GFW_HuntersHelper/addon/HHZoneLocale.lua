_G['HHZoneLocale'] = {}
local HHZoneLocale = _G['HHZoneLocale']

HHZoneLocale.babble = _G.LibStub("LibBabble-SubZone-3.0") -- where Module is what you want.
HHZoneLocale.babble_table = HHZoneLocale.babble:GetLookupTable()
HHZoneLocale.babble_table_reverse = HHZoneLocale.babble:GetReverseLookupTable()

function HHZoneLocale.unlocalize(zoneName)
    local key = HHZoneLocale.babble_table_reverse[zoneName]
    if (key) then
        return key;
    else
        return zoneName;
    end
end

function HHZoneLocale.localize(zoneName)
    local key = HHZoneLocale.babble_table[zoneName]
    if (key) then
        return key;
    else
        return zoneName;
    end
end

function HHZoneLocale.zoneIdFromName(zoneName)
    assert(_G['ZonesNameToId'][zoneName], ("Zone ID for %s not found"):format(zoneName))
    return _G['ZonesNameToId'][zoneName]
end