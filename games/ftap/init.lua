local BASE_URL = "https://raw.githubusercontent.com/crimiv/bandithub/test/"

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

BanditHub = BanditHub or {}
BanditHub.WindUI = WindUI
BanditHub.Utils = utils
BanditHub.Config = config
BanditHub.Toggles = BanditHub.Toggles or {}
BanditHub.SettingsFile = "BanditHub/Settings.json"

local function SaveSettings()
    local success, result = pcall(function()
        if not makefolder then return end
        makefolder("BanditHub")
        if not writefile then return end
        local data = {
            toggles = BanditHub.Toggles,
            theme = BanditHub.CurrentTheme or "Bandit",
        }
        writefile(BanditHub.SettingsFile, game:GetService("HttpService"):JSONEncode(data))
    end)
end

local function LoadSettings()
    local success, result = pcall(function()
        if not isfile then return end
        if isfile(BanditHub.SettingsFile) then
            local data = game:GetService("HttpService"):JSONDecode(readfile(BanditHub.SettingsFile))
            if data and data.toggles then
                for key, value in pairs(data.toggles) do
                    BanditHub.Toggles[key] = value
                end
            end
            if data and data.theme then
                BanditHub.CurrentTheme = data.theme
            end
        end
    end)
end

LoadSettings()

local version = BANDITHUB_VERSION or "1.0.0"

if BanditHub.Window then
    pcall(function() BanditHub.Window:Close() end)
    BanditHub.Window = nil
end

local Window = WindUI:CreateWindow({
    Title = "Bandit Hub v" .. version,
    Author = "by coolio",
    Folder = "BanditHub",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = BanditHub.CurrentTheme or "Bandit",
    Resizable = true,
    SideBarWidth = 200,
    HideSearchBar = true,
    ScrollBarEnabled = false,
})

Window:SetToggleKey(Enum.KeyCode.K)

BanditHub.Window = Window
BanditHub.SaveSettings = SaveSettings
BanditHub.LoadSettings = LoadSettings

if BanditHub.CreateStatusTab then
    BanditHub.CreateStatusTab(Window)
end

LoadScript("games/ftap/aimbot.lua")

if _G.BANDITHUB_STATES then
    for key, value in pairs(_G.BANDITHUB_STATES) do
        BanditHub.Toggles[key] = value
    end
    _G.BANDITHUB_STATES = nil
end

if BanditHub.RestoreStates then
    BanditHub.RestoreStates()
end

SaveSettings()
