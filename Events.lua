local Addon = Learnable

local function OnLevelUpEventHandler(self, event, ...)
    local playerLevel = ...
    Addon.ShowLevel(playerLevel)
end

local levelUpFrame = CreateFrame("FRAME")
levelUpFrame:RegisterEvent("PLAYER_LEVEL_UP")
levelUpFrame:SetScript("OnEvent", OnLevelUpEventHandler)
