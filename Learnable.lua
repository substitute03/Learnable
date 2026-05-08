SLASH_LEARNABLE1 = "/learnable"
SLASH_LEARNABLE2 = "/learn"
local pendingRankRetryByLevel = {}
local pendingRankRetryByRange = {}
local C_HEADER = "|cffFFD100"
local C_DIV = "|cff666666"
local C_LEVEL = "|cff87CEFA"
local C_NAME = "|cffFFFFFF"
local C_RANK = "|cff33FF99"
local C_RESET = "|r"
local BULLET = "•"
local DIVIDER = C_DIV .. "------------------------------" .. C_RESET

SlashCmdList["LEARNABLE"] = function(arg1)
    local input = (arg1 or ""):lower():match("^%s*(.-)%s*$")
    local playerLevel = UnitLevel("player")

    if input == "" then
        PrintSpells(playerLevel)
        return
    end

    local nextRange = input:match("^next%s+(%d+)$")
    if input == "next" or nextRange then
        local levelsToShow = tonumber(nextRange) or 1
        if levelsToShow < 1 then
            levelsToShow = 1
        end

        local startLevel = playerLevel + 1
        local endLevel = math.min(70, playerLevel + levelsToShow)
        if startLevel > 70 then
            print("[Learnable] You are already at max level.")
            return
        end

        if levelsToShow == 1 then
            PrintSpells(startLevel)
        else
            PrintSpellRange(startLevel, endLevel)
        end
        return
    end

    local level = tonumber(input)
    if level == nil then
        print(C_HEADER .. "[Learnable] Usage: /learn[able] [level|next [range]]" .. C_RESET)
        return
    end

    PrintSpells(level)
end

function OnLevelUpEventHandler(self, event, ...)
    local playerLevel = ...
    PrintSpells(playerLevel)
end

function GetLearnableSpellIdsForLevel(level)
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

function PrintSpellRange(startLevel, endLevel, isRetry)
    local _, playerClass = UnitClass("player")
    local spellLines = {}
    local hasPendingSpellData = false
    local rangeKey = startLevel .. "-" .. endLevel

    for level = startLevel, endLevel, 1 do
        local learnableSpellsIds = GetLearnableSpellIdsForLevel(level)
        for i = 1, #learnableSpellsIds, 1 do
            local spellId = learnableSpellsIds[i]
            local spellInfo = C_Spell.GetSpellInfo(spellId)
            local spellName = spellInfo and spellInfo.name
            local spellRank = C_Spell.GetSpellSubtext and C_Spell.GetSpellSubtext(spellId) or nil
            if (spellRank == nil or spellRank == "") and C_Spell.RequestLoadSpellData then
                C_Spell.RequestLoadSpellData(spellId)
                hasPendingSpellData = true
            end
            if spellRank and spellRank ~= "" then
                table.insert(spellLines, BULLET .. " " .. C_LEVEL .. level .. C_RESET .. " - " .. C_NAME .. spellName .. C_RESET .. " " .. C_RANK .. "(" .. spellRank .. ")" .. C_RESET)
            else
                table.insert(spellLines, BULLET .. " " .. C_LEVEL .. level .. C_RESET .. " - " .. C_NAME .. spellName .. C_RESET)
            end
        end
    end

    if hasPendingSpellData and not isRetry and not pendingRankRetryByRange[rangeKey] then
        pendingRankRetryByRange[rangeKey] = true
        C_Timer.After(0.2, function()
            pendingRankRetryByRange[rangeKey] = nil
            PrintSpellRange(startLevel, endLevel, true)
        end)
        return
    end

    if #spellLines > 0 then
        print(" ")
        print(C_HEADER .. "[Learnable] Spells available to train at levels " .. startLevel .. "-" .. endLevel .. ":" .. C_RESET)
        print(DIVIDER)
        for i = 1, #spellLines, 1 do
            print(spellLines[i])
        end
        print(DIVIDER)
    else
        print(C_HEADER .. "[Learnable]No new learnable spells for a " .. playerClass .. " between levels " .. startLevel .. "-" .. endLevel .. "." .. C_RESET)
    end
end

function PrintSpells(level, isRetry)
    local _, playerClass = UnitClass("player")
    local learnableSpellsIds = GetLearnableSpellIdsForLevel(level)

    if #learnableSpellsIds > 0 then
        local spellLines = {}
        local hasPendingSpellData = false
        for i = 1, #learnableSpellsIds, 1 do
            local spellId = learnableSpellsIds[i]
            local spellInfo = C_Spell.GetSpellInfo(spellId)
            local spellName = spellInfo and spellInfo.name
            local spellRank = C_Spell.GetSpellSubtext and C_Spell.GetSpellSubtext(spellId) or nil
            if (spellRank == nil or spellRank == "") and C_Spell.RequestLoadSpellData then
                C_Spell.RequestLoadSpellData(spellId)
                hasPendingSpellData = true
            end
            if spellRank and spellRank ~= "" then
                table.insert(spellLines, BULLET .. " " .. C_NAME .. spellName .. C_RESET .. " " .. C_RANK .. "(" .. spellRank .. ")" .. C_RESET)
            else
                table.insert(spellLines, BULLET .. " " .. C_NAME .. spellName .. C_RESET)
            end
        end
        if hasPendingSpellData and not isRetry and not pendingRankRetryByLevel[level] then
            pendingRankRetryByLevel[level] = true
            C_Timer.After(0.2, function()
                pendingRankRetryByLevel[level] = nil
                PrintSpells(level, true)
            end)
            return
        end
        print(" ")
        print(C_HEADER .. "[Learnable] Spells available to train at level " .. level .. ":" .. C_RESET)
        print(DIVIDER)
        for i = 1, #spellLines, 1 do
            print(spellLines[i])
        end
        print(DIVIDER)
    else
        print(C_HEADER .. "No new learnable spells for a " .. playerClass .. " at level " .. level .. "." .. C_RESET)
    end
end

local levelUpFrame = CreateFrame("FRAME")
levelUpFrame.RegisterEvent(levelUpFrame, "PLAYER_LEVEL_UP")
levelUpFrame.SetScript(levelUpFrame, "OnEvent", OnLevelUpEventHandler)
