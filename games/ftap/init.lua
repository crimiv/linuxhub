local BASE_URL = "https://raw.githubusercontent.com/crimiv/applehub/main/"

local function LoadScript(name)
    local script = game:HttpGet(BASE_URL .. name)
    local fn, err = loadstring(script)
    if not fn then error(err) end
    return fn()
end

local function CheckExecutor()
    local missing = {}
    if not hookmetamethod then table.insert(missing, "hookmetamethod") end
    if not getnamecallmethod then table.insert(missing, "getnamecallmethod") end
    if not newcclosure then table.insert(missing, "newcclosure") end
    if #missing > 0 then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Executor Incompatible",
            Text = "Missing functions: " .. table.concat(missing, ", ") .. ". Silent Aim will not work.",
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

AppleHub = AppleHub or {}
AppleHub.WindUI = WindUI
AppleHub.Utils = utils
AppleHub.Config = config
AppleHub.Toggles = AppleHub.Toggles or {}
AppleHub.SettingsFile = "AppleHub/Settings.json"

local function SaveSettings()
    local success, result = pcall(function()
        if not makefolder then return end
        makefolder("AppleHub")
        if not writefile then return end
        local data = {
            toggles = AppleHub.Toggles,
            theme = AppleHub.CurrentTheme or "Dark",
        }
        writefile(AppleHub.SettingsFile, game:GetService("HttpService"):JSONEncode(data))
    end)
end

local function LoadSettings()
    local success, result = pcall(function()
        if not isfile then return end
        if isfile(AppleHub.SettingsFile) then
            local data = game:GetService("HttpService"):JSONDecode(readfile(AppleHub.SettingsFile))
            if data and data.toggles then
                for key, value in pairs(data.toggles) do
                    AppleHub.Toggles[key] = value
                end
            end
            if data and data.theme then
                AppleHub.CurrentTheme = data.theme
            end
        end
    end)
end

LoadSettings()

local version = APPLE_HUB_VERSION or "1.0.0"

local Window = WindUI:CreateWindow({
    Title = "Apple Hub v" .. version,
    Author = "by coolio",
    Folder = "AppleHub",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = AppleHub.CurrentTheme or "Dark",
    Resizable = true,
    SideBarWidth = 200,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function() end,
    },
})

Window:SetToggleKey(Enum.KeyCode.K)

AppleHub.Window = Window
AppleHub.SaveSettings = SaveSettings
AppleHub.LoadSettings = LoadSettings

LoadScript("games/ftap/aimbot.lua")

if _G.APPLE_HUB_STATES then
    for key, value in pairs(_G.APPLE_HUB_STATES) do
        AppleHub.Toggles[key] = value
    end
    _G.APPLE_HUB_STATES = nil
end

if AppleHub.RestoreStates then
    AppleHub.RestoreStates()
end

SaveSettings()