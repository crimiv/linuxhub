local function Fetch(url)
    return game:HttpGet(url)
end

local BASE_URL = "https://raw.githubusercontent.com/crimiv/applehub/main/"

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

APPLE_HUB_VERSION = version

local function PerformUpdate(newVersion)
    _G.APPLE_HUB_UPDATING = true
    if AppleHub and AppleHub.Window then
        AppleHub.Toggles = AppleHub.Toggles or {}
        _G.APPLE_HUB_STATES = AppleHub.Toggles
        AppleHub.Window:Close()
    end
    local WindUI = AppleHub and AppleHub.WindUI
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
    loadstring(game:HttpGet(BASE_URL .. "main.lua"))()
end

task.spawn(function()
    while true do
        task.wait(5)
        if _G.APPLE_HUB_UPDATING then break end
        local success, newVersion = pcall(function()
            local raw = game:HttpGet(BASE_URL .. "version.txt")
            return raw:gsub("%s+", "")
        end)
        if success and newVersion and newVersion ~= APPLE_HUB_VERSION then
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