local Addon = Learnable

local learnableTab
local initialized
local TAB_OFFSET_Y = -17

local function GetFrameAnchorTarget(frame)
    if not frame or not frame.GetNumPoints then
        return nil
    end
    for i = 1, frame:GetNumPoints() do
        local point, relativeFrame, relativePoint = frame:GetPoint(i)
        if point == "TOPLEFT" and relativePoint == "BOTTOMLEFT" and relativeFrame then
            return relativeFrame
        end
    end
    return nil
end

local function IsBlizzardSkillLineTab(frame)
    local name = frame and frame.GetName and frame:GetName()
    return name and name:match("^SpellBookSkillLineTab%d+$") ~= nil
end

local function GetLastVisibleSkillLineTab()
    local lastTab
    for i = 1, 8 do
        local tab = _G["SpellBookSkillLineTab" .. i]
        if tab and tab:IsShown() then
            lastTab = tab
        end
    end
    return lastTab
end

local function IsCustomSideTab(frame)
    if not frame or frame == learnableTab or not frame:IsShown() then
        return false
    end
    local objectType = frame.GetObjectType and frame:GetObjectType()
    if objectType ~= "CheckButton" and objectType ~= "Button" then
        return false
    end
    local parent = frame:GetParent()
    if parent ~= SpellBookFrame and parent ~= _G.SpellBookSideTabsFrame then
        return false
    end
    return true
end

local function ForEachCustomSideTab(visit)
    local parents = { SpellBookFrame }
    if _G.SpellBookSideTabsFrame then
        parents[#parents + 1] = _G.SpellBookSideTabsFrame
    end
    for p = 1, #parents do
        local parent = parents[p]
        if parent and parent.GetChildren then
            for _, child in ipairs({ parent:GetChildren() }) do
                if IsCustomSideTab(child) then
                    visit(child)
                end
            end
        end
    end
end

local function GetTabsAnchoredBelow(anchorFrame)
    local below = {}
    if not anchorFrame then
        return below
    end

    local function consider(frame)
        if frame ~= learnableTab and frame:IsShown() and GetFrameAnchorTarget(frame) == anchorFrame then
            if IsBlizzardSkillLineTab(frame) or IsCustomSideTab(frame) then
                below[#below + 1] = frame
            end
        end
    end

    for i = 1, 8 do
        consider(_G["SpellBookSkillLineTab" .. i])
    end
    ForEachCustomSideTab(consider)
    return below
end

local function GetDeepestAnchoredTabBelow(anchorFrame)
    local deepest = anchorFrame
    local deepestBottom = anchorFrame:GetBottom() or math.huge

    local function walk(from)
        local belowTabs = GetTabsAnchoredBelow(from)
        for i = 1, #belowTabs do
            local tab = belowTabs[i]
            local bottom = tab:GetBottom() or math.huge
            if bottom <= deepestBottom then
                deepestBottom = bottom
                deepest = tab
                walk(tab)
            end
        end
    end

    walk(anchorFrame)
    return deepest
end

-- Start from the last Blizzard skill-line tab, then the lowest tab in that side stack.
local function GetBottomOfSideTabStack()
    local root = GetLastVisibleSkillLineTab() or _G.SpellBookSkillLineTab1
    if not root then
        return nil
    end
    return GetDeepestAnchoredTabBelow(root)
end

local function GetClassIconInfo(classToken)
    if not classToken or not Addon.CLASS_ICON_COORDS[classToken] then
        return nil
    end
    local t = Addon.CLASS_ICON_COORDS[classToken]
    return Addon.CLASS_ICON_TEXTURE, t[1], t[2], t[3], t[4]
end

local function ApplyClassIconToTab(tab)
    local _, classToken = UnitClass("player")
    local texture, ulx, uly, lrx, lry = GetClassIconInfo(classToken)
    if not texture then
        return
    end
    local normal = tab.GetNormalTexture and tab:GetNormalTexture()
    if normal then
        normal:SetTexture(texture)
        normal:SetTexCoord(ulx, uly, lrx, lry)
    end
end

local function IsPlayerSpellBookShown()
    if not SpellBookFrame or not SpellBookFrame:IsShown() then
        return false
    end
    local bookType = SpellBookFrame.bookType
    if bookType == nil then
        return true
    end
    local spellBookType = BOOKTYPE_SPELL or "spell"
    return bookType == spellBookType
end

local function UpdateTabVisibility()
    if not learnableTab then
        return
    end
    if IsPlayerSpellBookShown() then
        learnableTab:Show()
    else
        learnableTab:Hide()
    end
end

local function PositionLearnableTab()
    if not learnableTab then
        return
    end
    local anchorTab = GetBottomOfSideTabStack()
    if not anchorTab then
        return
    end
    learnableTab:ClearAllPoints()
    learnableTab:SetPoint("TOPLEFT", anchorTab, "BOTTOMLEFT", 0, TAB_OFFSET_Y)
end

local function RefreshLearnableTab()
    PositionLearnableTab()
    UpdateTabVisibility()
end

local function ScheduleRefreshLearnableTab()
    RefreshLearnableTab()
    if C_Timer and C_Timer.After then
        C_Timer.After(0, RefreshLearnableTab)
    end
end

local function PlayTabClickSound()
    if SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
    else
        pcall(PlaySound, "igMainMenuOption")
    end
end

local function CloseSpellBook()
    if not SpellBookFrame or not SpellBookFrame:IsShown() then
        return
    end
    if HideUIPanel then
        HideUIPanel(SpellBookFrame)
    else
        SpellBookFrame:Hide()
    end
end

local function PreventTabSelectionHighlight(tab)
    tab:SetChecked(false)
    local checkedTexture = tab.GetCheckedTexture and tab:GetCheckedTexture()
    if checkedTexture then
        checkedTexture:SetAlpha(0)
    end
    local disabledCheckedTexture = tab.GetDisabledCheckedTexture and tab:GetDisabledCheckedTexture()
    if disabledCheckedTexture then
        disabledCheckedTexture:SetAlpha(0)
    end
    tab:SetScript("OnMouseDown", function(self)
        self:SetChecked(false)
    end)
    tab:SetScript("OnMouseUp", function(self)
        self:SetChecked(false)
    end)
end

local function CreateLearnableSpellBookTab()
    if learnableTab or not SpellBookFrame then
        return
    end

    local tab = CreateFrame("CheckButton", "LearnableSpellBookTab", SpellBookFrame, "SpellBookSkillLineTabTemplate")
    tab:SetFrameStrata(SpellBookFrame:GetFrameStrata())
    tab:SetFrameLevel(SpellBookFrame:GetFrameLevel() + 2)
    ApplyClassIconToTab(tab)
    PreventTabSelectionHighlight(tab)

    tab:SetScript("OnClick", function(self)
        PlayTabClickSound()
        CloseSpellBook()
        if Addon.IsLearnableWindowShown() then
            Addon.HideLearnableWindow()
        else
            Addon.OpenLearnable()
        end
        self:SetChecked(false)
    end)
    tab:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Learnable", 1, 1, 1)
        GameTooltip:AddLine("Show learnable abilities", nil, nil, nil, true)
        GameTooltip:Show()
    end)
    tab:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    learnableTab = tab
    RefreshLearnableTab()
end

local function InitializeSpellBookTab()
    if initialized or not SpellBookFrame then
        return
    end
    initialized = true

    CreateLearnableSpellBookTab()

    if SpellBookFrame_UpdateSkillLineTabs then
        hooksecurefunc("SpellBookFrame_UpdateSkillLineTabs", ScheduleRefreshLearnableTab)
    end
    if SpellBookFrame_Update then
        hooksecurefunc("SpellBookFrame_Update", ScheduleRefreshLearnableTab)
    end

    SpellBookFrame:HookScript("OnShow", ScheduleRefreshLearnableTab)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function()
    InitializeSpellBookTab()
end)
