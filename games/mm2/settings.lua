local WindUI = AppleHub.WindUI
local config = AppleHub.Config

local SettingsTab = AppleHub.Window:Tab({ Title = "Settings" })

local themes = config.themes or {"Silver", "Dark", "Light", "Neon"}
local currentTheme = AppleHub.CurrentTheme or "Silver"

SettingsTab:Dropdown({
    Title = "Theme",
    Values = themes,
    Default = currentTheme,
    Callback = function(value)
        currentTheme = value
        AppleHub.CurrentTheme = value
        WindUI:SetTheme(value)
        if AppleHub.SaveSettings then AppleHub.SaveSettings() end
        WindUI:Notify({ Title = "Theme", Content = "Switched to " .. value, Duration = 2 })
    end
})