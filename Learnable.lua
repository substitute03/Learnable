SLASH_LEARNABLE1 = "/learnable"

SlashCmdList["LEARNABLE"] = function(arg1)
    local level = tonumber(arg1)
    PrintSpells(level)
end

function OnLevelUpEventHandler(self, event, ...)
    local playerLevel = ...
    PrintSpells(playerLevel)
end

function PrintSpells(level)
    local _, playerClass = UnitClass("player") -- The 2nd return value is the locale-independent, uppercase class name of the current player.
    local _, playerRace = UnitRace("player") -- The 2nd return value is the locale-independent, uppercase race name of the current player.
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
    end

    if #learnableSpellsIds > 0 then
        print(" ")
        print("[Learnable] Spells available to train at level " .. level .. ":")
        print("====================")
        for i = 1, #learnableSpellsIds, 1 do
            local spellName = GetSpellInfo(learnableSpellsIds[i])
            print("- ", spellName)
        end
        print("====================")
    else
        print("No new learnable spells for a ", playerClass, " at level ", level, ".")
    end

    for i = 1, #learnableSpellsIds, 1 do
        table.remove(learnableSpellsIds, i)
    end
end

local levelUpFrame = CreateFrame("FRAME")
levelUpFrame.RegisterEvent(levelUpFrame, "PLAYER_LEVEL_UP")
levelUpFrame.SetScript(levelUpFrame, "OnEvent", OnLevelUpEventHandler)
