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

if not CheckExecutor() then
    return
end

local WindUI = LoadScript("shared/windui.lua")
local utils = LoadScript("shared/utils.lua")
local config = LoadScript("shared/config.lua")

SilverHub = SilverHub or {}
SilverHub.WindUI = WindUI
SilverHub.Utils = utils
SilverHub.Config = config

local version = config.version or "1.0.0"

local Window = WindUI:CreateWindow({
    Title = "Apple Hub v" .. version,
    Author = "by coolio",
    Folder = "SilverHub",
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

SilverHub.Window = Window

task.spawn(function()
    local success, remoteConfig = pcall(function()
        return game:HttpGet(BASE_URL .. "shared/config.lua")
    end)
    if success then
        local fn, err = loadstring(remoteConfig)
        if fn then
            local remote = fn()
            if remote and remote.version and remote.version ~= version then
                WindUI:Notify({
                    Title = "Update Available",
                    Content = "New version " .. remote.version .. " is available. Please reload the hub.",
                    Duration = 5,
                })
            end
        end
    end
end)

LoadScript("games/ftap/aimbot.lua")