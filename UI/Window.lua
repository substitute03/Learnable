local Addon = Learnable

local learnableWindow
local queryHeaderText
local classHeaderText
local classIconTexture
local startLevelInput
local endLevelInput
local unlearnedOnlyCheck
local scrollChild
local rows = {}

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
        row.text:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
        row.text:SetJustifyH("LEFT")

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

    local searchButton = CreateFrame("Button", nil, learnableWindow, "UIPanelButtonTemplate")
    searchButton:SetSize(80, 24)
    searchButton:SetPoint("LEFT", endLevelInput, "RIGHT", 14, 0)
    searchButton:SetText("Search")
    searchButton:SetScript("OnClick", function()
        local startLevel = tonumber(startLevelInput:GetText()) or UnitLevel("player")
        local endLevel = tonumber(endLevelInput:GetText()) or startLevel
        startLevel = Addon.ClampLevel(startLevel)
        endLevel = Addon.ClampLevel(endLevel)
        if startLevel > endLevel then
            startLevel, endLevel = endLevel, startLevel
        end
        Addon.ShowSpellRange(startLevel, endLevel)
    end)

    local showAllButton = CreateFrame("Button", nil, learnableWindow, "UIPanelButtonTemplate")
    showAllButton:SetSize(80, 24)
    showAllButton:SetPoint("LEFT", searchButton, "RIGHT", 8, 0)
    showAllButton:SetText("Show all")
    showAllButton:SetScript("OnClick", function()
        Addon.ShowSpellRange(1, Addon.MAX_LEVEL)
    end)

    unlearnedOnlyCheck = CreateFrame("CheckButton", nil, learnableWindow, "UICheckButtonTemplate")
    unlearnedOnlyCheck:SetPoint("LEFT", showAllButton, "RIGHT", 8, 0)
    unlearnedOnlyCheck:SetChecked(Addon.showUnlearnedOnly)
    unlearnedOnlyCheck.text:SetText("Unlearned only")
    unlearnedOnlyCheck:SetScript("OnClick", function(self)
        Addon.showUnlearnedOnly = self:GetChecked() and true or false
        local startLevel = tonumber(startLevelInput:GetText()) or UnitLevel("player")
        local endLevel = tonumber(endLevelInput:GetText()) or startLevel
        startLevel = Addon.ClampLevel(startLevel)
        endLevel = Addon.ClampLevel(endLevel)
        if startLevel > endLevel then
            startLevel, endLevel = endLevel, startLevel
        end
        Addon.ShowSpellRange(startLevel, endLevel)
    end)

    local scrollFrame = CreateFrame("ScrollFrame", nil, learnableWindow, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 18, -124)
    scrollFrame:SetPoint("BOTTOMRIGHT", -36, 16)

    scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(1, 1)
    scrollFrame:SetScrollChild(scrollChild)
end

function Addon.RenderSpellResults(startLevel, endLevel, spellEntries)
    Addon.EnsureWindow()

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

    if startLevel == endLevel then
        queryHeaderText:SetText("Results for level " .. startLevel)
    else
        queryHeaderText:SetText("Results for levels " .. startLevel .. "-" .. endLevel)
    end

    startLevelInput:SetText(tostring(startLevel))
    endLevelInput:SetText(tostring(endLevel))
    if unlearnedOnlyCheck then
        unlearnedOnlyCheck:SetChecked(Addon.showUnlearnedOnly)
    end

    for i = 1, #rows, 1 do
        rows[i]:Hide()
    end

    if #spellEntries == 0 then
        local row = EnsureResultRow(1)
        row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 6, -6)
        row:SetSize(680, 24)
        row.spellId = nil
        row.icon:Hide()
        row.text:ClearAllPoints()
        row.text:SetPoint("LEFT", 0, 0)
        row.text:SetText("No learnable spells in this range.")
        row:Show()
        scrollChild:SetHeight(30)
        learnableWindow:Show()
        return
    end

    for i = 1, #spellEntries, 1 do
        local entry = spellEntries[i]
        local row = EnsureResultRow(i)

        row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 6, -6 - ((i - 1) * 24))
        row.spellId = entry.spellId
        row.icon:Show()
        row.text:ClearAllPoints()
        row.text:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
        row.icon:SetTexture(entry.icon)
        if entry.rank and entry.rank ~= "" then
            row.text:SetText(entry.level .. " - " .. entry.name .. " (" .. entry.rank .. ")")
        else
            row.text:SetText(entry.level .. " - " .. entry.name)
        end
        row:Show()
    end

    scrollChild:SetHeight((#spellEntries * 24) + 12)
    learnableWindow:Show()
end
