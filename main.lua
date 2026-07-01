local function Fetch(url)
    return game:HttpGet(url)
end

local BASE_URL = "https://raw.githubusercontent.com/crimiv/linuxhub/main/"

local function LoadScript(name)
    local script = Fetch(BASE_URL .. name)
    assert(loadstring(script))()
end

local bypassScript = Fetch(BASE_URL .. "shared/adonisbypass.lua")
local bypassFn = loadstring(bypassScript)
if bypassFn then
    bypassFn()
end

local version = Fetch(BASE_URL .. "version.txt")
if version then
    version = version:gsub("%s+", "")
else
    version = "1.0.0"
end

LINUXHUB_VERSION = version

local function PerformUpdate(newVersion)
    _G.LINUXHUB_UPDATING = true
    if LinuxHub then
        LinuxHub.Toggles = LinuxHub.Toggles or {}
        _G.LINUXHUB_STATES = LinuxHub.Toggles
        if LinuxHub.Window then
            LinuxHub.Window:Close()
        end
        if LinuxHub.DisableAll then
            LinuxHub.DisableAll()
        end
    end
    local WindUI = LinuxHub and LinuxHub.WindUI
    if WindUI then
        WindUI:Notify({
            Title = "Updating",
            Content = "Updating to v" .. newVersion .. "...",
            Duration = 3,
        })
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Updating",
            Text = "Updating to v" .. newVersion .. "...",
            Duration = 3,
        })
    end
    task.wait(1)
    _G.LINUXHUB_UPDATING = false
    loadstring(game:HttpGet(BASE_URL .. "main.lua"))()
end

task.spawn(function()
    while true do
        task.wait(1)
        if _G.LINUXHUB_UPDATING then break end
        local success, newVersion = pcall(function()
            local raw = game:HttpGet(BASE_URL .. "version.txt")
            return raw:gsub("%s+", "")
        end)
        if success and newVersion and newVersion ~= LINUXHUB_VERSION then
            PerformUpdate(newVersion)
            break
        end
    end
end)

local gamesList = Fetch(BASE_URL .. "games.lua")
local games = assert(loadstring(gamesList))()

local placeId = game.PlaceId or game.GameId
local gameEntry = games[placeId]
if not gameEntry then
    LoadScript("games/universal/init.lua")
    return
end

LoadScript(gameEntry)
