local Addon = Learnable

function Addon.HandleSlashCommand(arg1)
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

    if input == "" then
        Addon.ShowSpellRange(playerLevel, Addon.MAX_LEVEL)
        return
    end

    if input == "all" then
        Addon.ShowSpellRange(1, Addon.MAX_LEVEL)
        return
    end

    local nextRange = input:match("^next%s+(%d+)$")
    if input == "next" or nextRange then
        local levelsToShow = tonumber(nextRange) or 1
        if levelsToShow < 1 then
            levelsToShow = 1
        end

        local startLevel = playerLevel + 1
        local endLevel = math.min(Addon.MAX_LEVEL, playerLevel + levelsToShow)
        if startLevel > Addon.MAX_LEVEL then
            Addon.ShowLevel(Addon.MAX_LEVEL)
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
