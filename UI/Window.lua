local Addon = Learnable

local learnableWindow
local queryHeaderText
local classHeaderText
local classIconTexture
local startLevelInput
local endLevelInput
local nameFilterInput
local unlearnedOnlyCheck
local scrollChild
local headerRow
local rows = {}

local function ReRenderCurrentRange()
    local startLevel = tonumber(startLevelInput:GetText()) or UnitLevel("player")
    local endLevel = tonumber(endLevelInput:GetText()) or startLevel
    startLevel = Addon.ClampLevel(startLevel)
    endLevel = Addon.ClampLevel(endLevel)
    if startLevel > endLevel then
        startLevel, endLevel = endLevel, startLevel
    end
    Addon.ShowSpellRange(startLevel, endLevel)
end

local function ApplyNameFilter()
    Addon.spellNameFilter = (nameFilterInput and nameFilterInput:GetText()) or ""
    ReRenderCurrentRange()
end

local function GetClassHeader()
    local localizedClassName, classToken = UnitClass("player")
    return localizedClassName, classToken
end

local function GetClassIconInfo(classToken)
    if not classToken or not Addon.CLASS_ICON_COORDS[classToken] then
        return nil
    end
    local t = Addon.CLASS_ICON_COORDS[classToken]
    return Addon.CLASS_ICON_TEXTURE, t[1], t[2], t[3], t[4]
end

local function EnsureResultRow(index)
    local row = rows[index]
    if not row then
        row = CreateFrame("Frame", nil, scrollChild)
        row:SetSize(680, 24)

        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(18, 18)
        row.icon:SetPoint("LEFT", 4, 0)

        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.text:SetPoint("LEFT", 82, 0)
        row.text:SetJustifyH("LEFT")
        row.text:SetWidth(588)

        row:EnableMouse(true)
        row:SetScript("OnEnter", function(self)
            if not self.spellId then
                return
            end
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            if GameTooltip.SetSpellByID then
                GameTooltip:SetSpellByID(self.spellId)
            else
                GameTooltip:SetHyperlink("spell:" .. self.spellId)
            end
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        rows[index] = row
    end
    return row
end

function Addon.EnsureWindow()
    if learnableWindow then
        return
    end

    learnableWindow = CreateFrame("Frame", "LearnableWindow", UIParent, "BasicFrameTemplateWithInset")
    learnableWindow:SetSize(760, 520)
    learnableWindow:SetPoint("CENTER")
    learnableWindow:SetFrameStrata("DIALOG")
    learnableWindow:SetToplevel(true)
    learnableWindow:SetMovable(true)
    learnableWindow:EnableMouse(true)
    learnableWindow:RegisterForDrag("LeftButton")
    learnableWindow:SetScript("OnDragStart", learnableWindow.StartMoving)
    learnableWindow:SetScript("OnDragStop", learnableWindow.StopMovingOrSizing)
    learnableWindow:Hide()

    local specialFrames = rawget(_G, "UISpecialFrames")
    if specialFrames then
        local found = false
        for i = 1, #specialFrames, 1 do
            if specialFrames[i] == "LearnableWindow" then
                found = true
                break
            end
        end
        if not found then
            table.insert(specialFrames, "LearnableWindow")
        end
    end

    learnableWindow.TitleText:SetText("Learnable")

    classIconTexture = learnableWindow:CreateTexture(nil, "ARTWORK")
    classIconTexture:SetSize(24, 24)
    classIconTexture:SetPoint("TOPLEFT", 18, -36)

    classHeaderText = learnableWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    classHeaderText:SetPoint("LEFT", classIconTexture, "RIGHT", 8, 0)
    classHeaderText:SetText("")

    queryHeaderText = learnableWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    queryHeaderText:SetPoint("TOPLEFT", 18, -64)
    queryHeaderText:SetText("")

    local resetButton = CreateFrame("Button", nil, learnableWindow, "UIPanelButtonTemplate")
    resetButton:SetSize(60, 20)
    resetButton:SetPoint("LEFT", queryHeaderText, "RIGHT", 8, 0)
    resetButton:SetText("Reset")
    resetButton:SetScript("OnClick", function()
        nameFilterInput:SetText("")
        startLevelInput:SetText("1")
        endLevelInput:SetText(tostring(Addon.MAX_LEVEL))
        ApplyNameFilter()
    end)

    local startLabel = learnableWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    startLabel:SetPoint("TOPLEFT", 18, -90)
    startLabel:SetText("Start level:")

    startLevelInput = CreateFrame("EditBox", nil, learnableWindow, "InputBoxTemplate")
    startLevelInput:SetSize(50, 24)
    startLevelInput:SetPoint("LEFT", startLabel, "RIGHT", 8, 0)
    startLevelInput:SetAutoFocus(false)
    startLevelInput:SetNumeric(true)
    startLevelInput:SetMaxLetters(2)

    local endLabel = learnableWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    endLabel:SetPoint("LEFT", startLevelInput, "RIGHT", 20, 0)
    endLabel:SetText("End level:")

    endLevelInput = CreateFrame("EditBox", nil, learnableWindow, "InputBoxTemplate")
    endLevelInput:SetSize(50, 24)
    endLevelInput:SetPoint("LEFT", endLabel, "RIGHT", 8, 0)
    endLevelInput:SetAutoFocus(false)
    endLevelInput:SetNumeric(true)
    endLevelInput:SetMaxLetters(2)

    local filterLabel = learnableWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    filterLabel:SetPoint("LEFT", endLevelInput, "RIGHT", 20, 0)
    filterLabel:SetText("Filter:")

    nameFilterInput = CreateFrame("EditBox", nil, learnableWindow, "InputBoxTemplate")
    nameFilterInput:SetSize(260, 24)
    nameFilterInput:SetPoint("LEFT", filterLabel, "RIGHT", 8, 0)
    nameFilterInput:SetAutoFocus(false)
    nameFilterInput:SetMaxLetters(64)
    nameFilterInput:SetText(Addon.spellNameFilter or "")

    startLevelInput:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        ApplyNameFilter()
    end)
    endLevelInput:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        ApplyNameFilter()
    end)
    nameFilterInput:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        ApplyNameFilter()
    end)
    nameFilterInput:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    unlearnedOnlyCheck = CreateFrame("CheckButton", nil, learnableWindow, "UICheckButtonTemplate")
    unlearnedOnlyCheck:SetPoint("TOPLEFT", 14, -116)
    unlearnedOnlyCheck:SetChecked(Addon.showUnlearnedOnly)
    unlearnedOnlyCheck.text:SetText("Unlearned only")
    unlearnedOnlyCheck:SetScript("OnClick", function(self)
        Addon.showUnlearnedOnly = self:GetChecked() and true or false
        ReRenderCurrentRange()
    end)

    local filterButton = CreateFrame("Button", nil, learnableWindow, "UIPanelButtonTemplate")
    filterButton:SetSize(80, 24)
    filterButton:SetPoint("TOPLEFT", 140, -118)
    filterButton:SetText("Search")
    filterButton:SetScript("OnClick", ApplyNameFilter)

    local scrollFrame = CreateFrame("ScrollFrame", nil, learnableWindow, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 18, -152)
    scrollFrame:SetPoint("BOTTOMRIGHT", -36, 16)

    scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(1, 1)
    scrollFrame:SetScrollChild(scrollChild)

    headerRow = CreateFrame("Frame", nil, scrollChild)
    headerRow:SetSize(680, 20)
    headerRow:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 6, -6)

    headerRow.iconText = headerRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    headerRow.iconText:SetPoint("LEFT", 4, 0)
    headerRow.iconText:SetText("")

    headerRow.levelText = headerRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    headerRow.levelText:SetPoint("LEFT", 34, 0)
    headerRow.levelText:SetText("Level")

    headerRow.spellText = headerRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    headerRow.spellText:SetPoint("LEFT", 82, 0)
    headerRow.spellText:SetText("Ability")
end

function Addon.RenderSpellResults(startLevel, endLevel, spellEntries)
    Addon.EnsureWindow()

    local currentLevel = UnitLevel("player")

    local className, classToken = GetClassHeader()
    local texture, left, right, top, bottom = GetClassIconInfo(classToken)
    if texture then
        classIconTexture:SetTexture(texture)
        classIconTexture:SetTexCoord(left, right, top, bottom)
        classIconTexture:Show()
    else
        classIconTexture:Hide()
    end
    classHeaderText:SetText(className or "Unknown")

    local filterText = Addon.spellNameFilter
    if filterText and filterText ~= "" then
        local lowered = filterText:lower()
        local filtered = {}
        for i = 1, #spellEntries, 1 do
            local entry = spellEntries[i]
            if entry.name and entry.name:lower():find(lowered, 1, true) then
                table.insert(filtered, entry)
            end
        end
        spellEntries = filtered
    end

    local rangeLabel
    if startLevel == endLevel then
        rangeLabel = "Results for level " .. startLevel
    else
        rangeLabel = "Results for levels " .. startLevel .. "-" .. endLevel
    end
    if filterText and filterText ~= "" then
        rangeLabel = rangeLabel .. " matching '" .. filterText .. "'"
    end
    queryHeaderText:SetText(rangeLabel)

    startLevelInput:SetText(tostring(startLevel))
    endLevelInput:SetText(tostring(endLevel))
    if unlearnedOnlyCheck then
        unlearnedOnlyCheck:SetChecked(Addon.showUnlearnedOnly)
    end
    if nameFilterInput and nameFilterInput:GetText() ~= (filterText or "") then
        nameFilterInput:SetText(filterText or "")
    end

    for i = 1, #rows, 1 do
        rows[i]:Hide()
    end

    if #spellEntries == 0 then
        local row = EnsureResultRow(1)
        row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 6, -30)
        row:SetSize(680, 24)
        row.spellId = nil
        row.icon:Hide()
        row.levelText = row.levelText or row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.levelText:SetPoint("LEFT", 34, 0)
        row.levelText:SetWidth(40)
        row.levelText:SetJustifyH("CENTER")
        row.levelText:SetText("")
        row.levelText:SetTextColor(1, 1, 1, 1)
        row.text:ClearAllPoints()
        row.text:SetPoint("LEFT", 82, 0)
        row.text:SetTextColor(1, 1, 1, 1)
        if filterText and filterText ~= "" then
            row.text:SetText("No learnable spells in this range matching '" .. filterText .. "'.")
        else
            row.text:SetText("No learnable spells in this range.")
        end
        row:Show()
        scrollChild:SetHeight(54)
        learnableWindow:Show()
        return
    end

    for i = 1, #spellEntries, 1 do
        local entry = spellEntries[i]
        local row = EnsureResultRow(i)
        row.levelText = row.levelText or row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.levelText:SetPoint("LEFT", 34, 0)
        row.levelText:SetWidth(40)
        row.levelText:SetJustifyH("CENTER")

        row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 6, -30 - ((i - 1) * 24))
        row.spellId = entry.spellId
        row.icon:Show()
        row.icon:SetPoint("LEFT", 4, 0)
        row.levelText:SetText(tostring(entry.level))
        row.text:ClearAllPoints()
        row.text:SetPoint("LEFT", 82, 0)
        row.text:SetWidth(588)
        row.icon:SetTexture(entry.icon)
        if entry.rank and entry.rank ~= "" then
            row.text:SetText(entry.name .. " (" .. entry.rank .. ")")
        else
            row.text:SetText(entry.name)
        end
        local ar, ag, ab, aa = 1, 1, 1, 1
        local lr, lg, lb, la = 1, 1, 1, 1
        if entry.level > currentLevel then
            ar, ag, ab = 1, 0.25, 0.25
            lr, lg, lb = ar, ag, ab
        elseif entry.level == currentLevel then
            lr, lg, lb, la = 1, 0.82, 0, 1
        end
        row.levelText:SetTextColor(lr, lg, lb, la)
        row.text:SetTextColor(ar, ag, ab, aa)
        row:Show()
    end

    scrollChild:SetHeight((#spellEntries * 24) + 36)
    learnableWindow:Show()
end
