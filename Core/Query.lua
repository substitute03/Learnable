local Addon = Learnable

function Addon.ClampLevel(level)
    if level < 1 then
        return 1
    end
    if level > Addon.MAX_LEVEL then
        return Addon.MAX_LEVEL
    end
    return level
end

function Addon.GetLearnableSpellIdsForLevel(level)
    local _, playerClass = UnitClass("player")
    local _, playerRace = UnitRace("player")
    local _, playerFaction = UnitFactionGroup("player")
    local learnableSpellsIds = {}

    if playerClass == "MAGE" then
        for key, spellId in pairs(MAGE[level]) do
            table.insert(learnableSpellsIds, spellId)
        end
        if playerFaction == "Horde" then
            for key, spellId in pairs(MAGE_HORDE[level]) do
                table.insert(learnableSpellsIds, spellId)
            end
        end
        if playerFaction == "Alliance" then
            for key, spellId in pairs(MAGE_ALLIANCE[level]) do
                table.insert(learnableSpellsIds, spellId)
            end
        end
    elseif playerClass == "HUNTER" then
        for key, spellId in pairs(HUNTER[level]) do
            table.insert(learnableSpellsIds, spellId)
        end
    elseif playerClass == "PALADIN" then
        for key, spellId in pairs(PALADIN[level]) do
            table.insert(learnableSpellsIds, spellId)
        end
        if playerRace == "BloodElf" then
            for key, spellId in pairs(PALADIN_BLOODELF[level]) do
                table.insert(learnableSpellsIds, spellId)
            end
        end
        if playerRace == "Human" or playerRace == "Dwarf" or playerRace == "Draenei" then
            for key, spellId in pairs(PALADIN_HUMAN_DWARF_DRAENEI[level]) do
                table.insert(learnableSpellsIds, spellId)
            end
        end
    elseif playerClass == "PRIEST" then
        for key, spellId in pairs(PRIEST[level]) do
            table.insert(learnableSpellsIds, spellId)
        end
        if playerRace == "Scourge" then
            for key, spellId in pairs(PRIEST_SCOURGE[level]) do
                table.insert(learnableSpellsIds, spellId)
            end
        end
        if playerRace == "Draenei" then
            for key, spellId in pairs(PRIEST_DRAENEI[level]) do
                table.insert(learnableSpellsIds, spellId)
            end
        end
        if playerRace == "Dwarf" then
            for key, spellId in pairs(PRIEST_DWARF[level]) do
                table.insert(learnableSpellsIds, spellId)
            end
        end
        if playerRace == "Troll" then
            for key, spellId in pairs(PRIEST_TROLL[level]) do
                table.insert(learnableSpellsIds, spellId)
            end
        end
        if playerRace == "Human" then
            for key, spellId in pairs(PRIEST_HUMAN[level]) do
                table.insert(learnableSpellsIds, spellId)
            end
        end
        if playerRace == "BloodElf" then
            for key, spellId in pairs(PRIEST_BLOODELF[level]) do
                table.insert(learnableSpellsIds, spellId)
            end
        end
        if playerRace == "NightElf" then
            for key, spellId in pairs(PRIEST_NIGHTELF[level]) do
                table.insert(learnableSpellsIds, spellId)
            end
        end
    elseif playerClass == "WARLOCK" then
        for key, spellId in pairs(WARLOCK[level]) do
            table.insert(learnableSpellsIds, spellId)
        end
    elseif playerClass == "ROGUE" then
        for key, spellId in pairs(ROGUE[level]) do
            table.insert(learnableSpellsIds, spellId)
        end
    elseif playerClass == "SHAMAN" then
        for key, spellId in pairs(SHAMAN[level]) do
            table.insert(learnableSpellsIds, spellId)
        end
        if playerFaction == "Horde" then
            for key, spellId in pairs(SHAMAN_HORDE[level]) do
                table.insert(learnableSpellsIds, spellId)
            end
        end
        if playerFaction == "Alliance" then
            for key, spellId in pairs(SHAMAN_ALLIANCE[level]) do
                table.insert(learnableSpellsIds, spellId)
            end
        end
    elseif playerClass == "WARRIOR" then
        for key, spellId in pairs(WARRIOR[level]) do
            table.insert(learnableSpellsIds, spellId)
        end
    elseif playerClass == "DRUID" then
        for key, spellId in pairs(DRUID[level]) do
            table.insert(learnableSpellsIds, spellId)
        end
    end
    return learnableSpellsIds
end

function Addon.BuildSpellEntries(startLevel, endLevel)
    local spellEntries = {}
    local hasPendingSpellData = false

    for level = startLevel, endLevel, 1 do
        local learnableSpellsIds = Addon.GetLearnableSpellIdsForLevel(level)
        for i = 1, #learnableSpellsIds, 1 do
            local spellId = learnableSpellsIds[i]
            local isKnown = Addon.IsSpellEffectivelyKnown(spellId)
            if not (Addon.showUnlearnedOnly and isKnown) then
                local spellInfo = C_Spell.GetSpellInfo(spellId)
                local spellName = (spellInfo and spellInfo.name) or ("Spell ID " .. spellId)
                local spellIcon = (spellInfo and spellInfo.iconID) or 136243
                local spellRank = C_Spell.GetSpellSubtext and C_Spell.GetSpellSubtext(spellId) or nil
                if (spellRank == nil or spellRank == "") and C_Spell.RequestLoadSpellData then
                    C_Spell.RequestLoadSpellData(spellId)
                    hasPendingSpellData = true
                end
                table.insert(spellEntries, {
                    level = level,
                    spellId = spellId,
                    name = spellName,
                    rank = spellRank,
                    icon = spellIcon,
                })
            end
        end
    end

    return spellEntries, hasPendingSpellData
end
