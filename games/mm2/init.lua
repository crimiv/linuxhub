local BASE_URL = "https://raw.githubusercontent.com/crimiv/applehub/main/"

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

AppleHub = AppleHub or {}
AppleHub.WindUI = WindUI
AppleHub.Utils = utils
AppleHub.Config = config
AppleHub.Toggles = AppleHub.Toggles or {}

local version = APPLE_HUB_VERSION or "1.0.0"

local Window = WindUI:CreateWindow({
    Title = "Apple Hub v" .. version,
    Author = "by coolio",
    Folder = "AppleHub",
    Icon = "https://raw.githubusercontent.com/crimiv/applehub/refs/heads/main/icon/applehub.png",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Silver",
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

AppleHub.Window = Window

task.spawn(function()
    local success, remoteVersion = pcall(function()
        return game:HttpGet(BASE_URL .. "version.txt")
    end)
    if success then
        remoteVersion = remoteVersion:gsub("%s+", "")
        if remoteVersion and remoteVersion ~= version then
            WindUI:Notify({
                Title = "Update Available",
                Content = "New version " .. remoteVersion .. " is available. Reloading...",
                Duration = 3,
            })
            task.wait(1)
            loadstring(game:HttpGet(BASE_URL .. "main.lua"))()
        end
    end
end)

LoadScript("games/mm2/esp.lua")
LoadScript("games/mm2/combat.lua")
LoadScript("games/mm2/troll.lua")
LoadScript("games/mm2/misc.lua")
LoadScript("games/mm2/settings.lua")

if _G.APPLE_HUB_STATES then
    for key, value in pairs(_G.APPLE_HUB_STATES) do
        AppleHub.Toggles[key] = value
    end
    _G.APPLE_HUB_STATES = nil
end