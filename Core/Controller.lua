local Addon = Learnable

Addon.pendingRetryByQuery = {}

function Addon.ShowSpellRange(startLevel, endLevel, isRetry)
    startLevel = Addon.ClampLevel(startLevel)
    endLevel = Addon.ClampLevel(endLevel)
    if startLevel > endLevel then
        startLevel, endLevel = endLevel, startLevel
    end

    local rangeKey = startLevel .. "-" .. endLevel
    local spellEntries, hasPendingSpellData = Addon.BuildSpellEntries(startLevel, endLevel)
    if hasPendingSpellData and not isRetry and not Addon.pendingRetryByQuery[rangeKey] then
        Addon.pendingRetryByQuery[rangeKey] = true
        C_Timer.After(0.2, function()
            Addon.pendingRetryByQuery[rangeKey] = nil
            Addon.ShowSpellRange(startLevel, endLevel, true)
        end)
        return
    end

    Addon.RenderSpellResults(startLevel, endLevel, spellEntries)
end

function Addon.ShowLevel(level, isRetry)
    local normalizedLevel = Addon.ClampLevel(level)
    local levelKey = tostring(normalizedLevel)
    local spellEntries, hasPendingSpellData = Addon.BuildSpellEntries(normalizedLevel, normalizedLevel)
    if hasPendingSpellData and not isRetry and not Addon.pendingRetryByQuery[levelKey] then
        Addon.pendingRetryByQuery[levelKey] = true
        C_Timer.After(0.2, function()
            Addon.pendingRetryByQuery[levelKey] = nil
            Addon.ShowLevel(normalizedLevel, true)
        end)
        return
    end

    Addon.RenderSpellResults(normalizedLevel, normalizedLevel, spellEntries)
end
