_G['HHSpells'] = {}
local HHSpells = _G['HHSpells']
local PetSpells = _G['PetSpells']
local CurrentPet = _G['CurrentPet']

HHSpells.knownSpells = {}

--/run HHSpells:scanCraftFrame()
function HHSpells:scanCraftFrame()
    self.knownSpells = PetSpells.getKnownSpells()
end

function HHSpells:saveKnownSpell(icon, rankNum, spellId)
    if self.knownSpells[icon] == nil then
        self.knownSpells[icon] = {}
    end
    if (rankNum and not self.knownSpells[icon][rankNum]) then
        self.knownSpells[icon][rankNum] = spellId
    end
end

function HHSpells:getKnownSpell(icon, rank)
    if not self.knownSpells or self.knownSpells == {} then
        self:scanCraftFrame()
        if not self.knownSpells then
            --@debug@
            print('Unable to scan craft frame')
            --@end-debug@
            return
        end
    end
    if not self.knownSpells[icon] then
        --@debug@
        print('Unknown spell: '..icon)
        --@end-debug@
        return
    end

    if not rank then
        return self.knownSpells[icon]
    else
        return self.knownSpells[icon][rank]
    end
end

---Does the hunter know the spell with the given icon?
function HHSpells:hunterKnowSpell(icon)
    return self:getKnownSpell(icon) ~= nil
end

--/dump HHSpells:isSpellKnown('ability_hunter_pet_boar', 1)
function HHSpells:isSpellKnown(icon, rank)
    if rank == nil then
        rank = 1
    end
    return self:getKnownSpell(icon, rank)
end

---Save spells known by the current pet
function HHSpells:saveCurrentPetSpells()
    local spells = CurrentPet.spells()
    for spellId, spellInfo in pairs(spells) do
        self:saveKnownSpell(spellInfo['icon'], spellInfo['rank'], spellId)
    end
end

function HHSpells:buildSpellList(passive)
    local listItem = {};
    if passive == true then
        listItem.name = _G.SPELL_PASSIVE
    else
        listItem.name = _G.ACTIVE_PETS
        passive = false
    end
    listItem.header = 1;
    listItem.expanded = not FHH_UICollapsedHeaders[listItem.name];
    table.insert(FHH_UIListItems, listItem);

    for spellName, spellId in GFWTable.PairsByKeys(_G['HH_SpellNamesToId']) do
        local spell = _G['PetSpellProperties'][spellId]
        if (spell['passive'] == passive) then
            listItem = FHH_GenerateListItem(spellName, spell['icon']);
            if (listItem) then
                table.insert(FHH_UIListItems, listItem);
            end
        end
    end
end

--/dump HHSpells:getHighestKnownRank("ability_physical_taunt")
function HHSpells:getHighestKnownRank(icon)
    local highest = 0
    if self:getKnownSpell(icon) == nil then
        return
    end
    for rank, _ in pairs(self:getKnownSpell(icon)) do
        highest = math.max(highest, rank)
    end
    return highest
end