local WindUI = LinuxHub.WindUI
local config = LinuxHub.Config

local SettingsTab = LinuxHub.Window:Tab({ Title = "Settings" })

local themes = config.themes or {"Silver", "Dark", "Light", "Neon"}
local currentTheme = LinuxHub.CurrentTheme or "Silver"

SettingsTab:Dropdown({
    Title = "Theme",
    Values = themes,
    Default = currentTheme,
    Callback = function(value)
        currentTheme = value
        LinuxHub.CurrentTheme = value
        WindUI:SetTheme(value)
        if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
        WindUI:Notify({ Title = "Theme", Content = "Switched to " .. value, Duration = 2 })
    end
})