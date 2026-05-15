local Addon = Learnable

-- Spell IDs learned via class quests (not default trainer purchase). All others show as Trainer.
Addon.SPELL_SOURCE_QUEST_IDS = {
    -- Druid
    [5487] = true, -- Bear Form
    [1066] = true, -- Aquatic Form
    [40120] = true, -- Swift Flight Form (epic flight quest line)
    -- Warrior
    [71] = true, -- Defensive Stance
    [2458] = true, -- Berserker Stance
    [20616] = true, -- Intercept (rank 1, class quest)
    -- Paladin
    [7328] = true, -- Redemption (rank 1, class quest)
    [13819] = true, -- Summon Warhorse
    [23214] = true, -- Summon Charger
    -- Hunter
    [1515] = true, -- Tame Beast
}

-- Quest spells missing from Abilities.lua level tables: [classToken][level] = { spellId, ... }
Addon.SPELL_QUEST_EXTRAS = {
    DRUID = {
        [10] = { 5487 },
        [16] = { 1066 },
    },
    WARRIOR = {
        [10] = { 71 },
        [30] = { 2458 },
    },
}

function Addon.GetSpellSource(spellId)
    if spellId and Addon.SPELL_SOURCE_QUEST_IDS[spellId] then
        return "Quest"
    end
    return "Trainer"
end

function Addon.GetQuestExtraSpellIdsForClassLevel(classToken, level)
    local byLevel = Addon.SPELL_QUEST_EXTRAS[classToken]
    if not byLevel then
        return nil
    end
    return byLevel[level]
end

function Addon.AppendQuestExtraSpellIds(spellIds, classToken, level)
    local extras = Addon.GetQuestExtraSpellIdsForClassLevel(classToken, level)
    if not extras then
        return
    end
    local seen = {}
    for i = 1, #spellIds do
        seen[spellIds[i]] = true
    end
    for i = 1, #extras do
        local spellId = extras[i]
        if not seen[spellId] then
            seen[spellId] = true
            table.insert(spellIds, spellId)
        end
    end
end
