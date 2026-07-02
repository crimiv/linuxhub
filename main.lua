local function Fetch(url)
    return game:HttpGet(url)
end

local BASE_URL = "https://raw.githubusercontent.com/crimiv/bandithub/main/"

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

BANDITHUB_VERSION = version

local BANDITHUB_GEN = 0

local function GetCurrentToggles()
    if BanditHub and BanditHub.Toggles then
        return BanditHub.Toggles
    end
    return nil
end

local function HardCloseWindow()
    if BanditHub and BanditHub.Window then
        pcall(function()
            BanditHub.Window:Close()
        end)
        BanditHub.Window = nil
    end
end

local function HardDisableAll()
    if BanditHub and BanditHub.DisableAll then
        pcall(function()
            BanditHub.DisableAll()
        end)
    end
end

local function PerformUpdate(newVersion)
    -- Prevent “double hub” hot-reload: rebuild in-place instead of re-executing main.lua.
    BANDITHUB_GEN += 1
    _G.BANDITHUB_UPDATING = true

    _G.BANDITHUB_STATES = GetCurrentToggles()

    HardDisableAll()
    HardCloseWindow()

    local WindUI = BanditHub and BanditHub.WindUI
    if WindUI and WindUI.Notify then
        pcall(function()
            WindUI:Notify({
                Title = "Updating",
                Content = "Updating to v" .. newVersion .. "...",
                Duration = 3,
            })
        end)
    else
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Updating",
                Text = "Updating to v" .. newVersion .. "...",
                Duration = 3,
            })
        end)
    end

    task.wait(1)

    BANDITHUB_VERSION = newVersion
    _G.BANDITHUB_UPDATING = false

    local gamesList = Fetch(BASE_URL .. "games.lua")
    local games = assert(loadstring(gamesList))()

    local placeId = game.PlaceId or game.GameId
    local gameEntry = games[placeId]

    if not gameEntry then
        LoadScript("games/universal/init.lua")
        return
    end

    LoadScript(gameEntry)
end


task.spawn(function()
    -- Guard so only one updater loop runs.
    if _G.BANDITHUB_UPDATER_THREAD then return end
    _G.BANDITHUB_UPDATER_THREAD = true

    while true do
        task.wait(1)
        if _G.BANDITHUB_UPDATING then
            -- Wait for PerformUpdate to finish.
            continue
        end

        local success, newVersion = pcall(function()
            local raw = game:HttpGet(BASE_URL .. "version.txt")
            return raw:gsub("%s+", "")
        end)

        if success and newVersion and newVersion ~= BANDITHUB_VERSION then
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
