Learnable = Learnable or {}

local Addon = Learnable

function Addon.OpenLearnable(arg1)
    local input = (arg1 or ""):lower():match("^%s*(.-)%s*$")
    if input == "able" then
        input = ""
    else
        local trimmedInput = input:match("^able%s+(.+)$")
        if trimmedInput then
            input = trimmedInput
        end
    end
    local playerLevel = UnitLevel("player")
    local maxLevel = Addon.MAX_LEVEL or 70

    if input == "" then
        Addon.showUnlearnedOnly = true
        Addon.ShowSpellRange(1, maxLevel)
        return
    end

    if input == "all" then
        Addon.ShowSpellRange(1, maxLevel)
        return
    end

    local nextRange = input:match("^next%s+(%d+)$")
    if input == "next" or nextRange then
        local levelsToShow = tonumber(nextRange) or 1
        if levelsToShow < 1 then
            levelsToShow = 1
        end

        local startLevel = playerLevel + 1
        local endLevel = math.min(maxLevel, playerLevel + levelsToShow)
        if startLevel > maxLevel then
            Addon.ShowLevel(maxLevel)
            return
        end

        if levelsToShow == 1 then
            Addon.ShowLevel(startLevel)
        else
            Addon.ShowSpellRange(startLevel, endLevel)
        end
        return
    end

    local level = tonumber(input)
    if level == nil then
        print("[Learnable] Usage: /learn[able] [all|level|next [range]]")
        return
    end

    Addon.ShowLevel(level)
end

SLASH_LEARNABLE1 = "/learnable"
SLASH_LEARNABLE2 = "/learn"

SlashCmdList["LEARNABLE"] = function(arg1)
    Addon.OpenLearnable(arg1)
end
