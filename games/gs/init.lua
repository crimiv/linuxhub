local BASE_URL = "https://raw.githubusercontent.com/crimiv/linuxhub/main/"

local function LoadScript(name)
    local script = game:HttpGet(BASE_URL .. name)
    local fn, err = loadstring(script)
    if not fn then error(err) end
    return fn()
end

local function CheckExecutor()
    local missing = {}
    if not game then table.insert(missing, "game") end
    if not Instance then table.insert(missing, "Instance") end
    if not task then table.insert(missing, "task") end
    if not pcall then table.insert(missing, "pcall") end
    if #missing > 0 then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Executor Incompatible",
            Text = "Missing essential functions: " .. table.concat(missing, ", "),
            Duration = 5,
        })
        return false
    end
    return true
end

if not CheckExecutor() then return end

local WindUI = LoadScript("shared/windui.lua")
local utils = LoadScript("shared/utils.lua")
local config = LoadScript("shared/config.lua")

LinuxHub = LinuxHub or {}
LinuxHub.WindUI = WindUI
LinuxHub.Utils = utils
LinuxHub.Config = config
LinuxHub.Toggles = LinuxHub.Toggles or {}
LinuxHub.SettingsFile = "LinuxHub/Settings.json"

local function SaveSettings()
    local success, result = pcall(function()
        if not makefolder then return end
        makefolder("LinuxHub")
        if not writefile then return end
        local data = {
            toggles = LinuxHub.Toggles,
            theme = LinuxHub.CurrentTheme or "Linux",
        }
        writefile(LinuxHub.SettingsFile, game:GetService("HttpService"):JSONEncode(data))
    end)
end

local function LoadSettings()
    local success, result = pcall(function()
        if not isfile then return end
        if isfile(LinuxHub.SettingsFile) then
            local data = game:GetService("HttpService"):JSONDecode(readfile(LinuxHub.SettingsFile))
            if data and data.toggles then
                for key, value in pairs(data.toggles) do
                    LinuxHub.Toggles[key] = value
                end
            end
            if data and data.theme then
                LinuxHub.CurrentTheme = data.theme
            end
        end
    end)
end

LoadSettings()

local version = LINUXHUB_VERSION or "1.0.0"

local Window = WindUI:CreateWindow({
    Title = "Linux Hub v" .. version,
    Author = "by coolio",
    Folder = "LinuxHub",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = LinuxHub.CurrentTheme or "Linux",
    Resizable = true,
    SideBarWidth = 200,
    HideSearchBar = true,
    ScrollBarEnabled = false,
})

Window:SetToggleKey(Enum.KeyCode.K)

LinuxHub.Window = Window
LinuxHub.SaveSettings = SaveSettings
LinuxHub.LoadSettings = LoadSettings

if LinuxHub.CreateStatusTab then
    LinuxHub.CreateStatusTab(Window)
end

LoadScript("games/gs/combat.lua")
LoadScript("games/gs/autofarm.lua")

if _G.LINUXHUB_STATES then
    for key, value in pairs(_G.LINUXHUB_STATES) do
        LinuxHub.Toggles[key] = value
    end
    _G.LINUXHUB_STATES = nil
end

if LinuxHub.RestoreStates then
    LinuxHub.RestoreStates()
end

SaveSettings()
