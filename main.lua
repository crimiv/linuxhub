local BASE_URL = "https://raw.githubusercontent.com/crimiv/linuxhub/main/"

local function Fetch(url)
    local response = game:HttpGet(url)
    if type(response) ~= "string" then
        error("Failed to fetch URL: " .. tostring(url))
    end
    local normalized = response:gsub("^%s+", "")
    if normalized:find("^<") or normalized:find("404: Not Found") or normalized:find("403: Forbidden") or normalized:find("Bad Request") then
        error("Invalid fetch response from " .. tostring(url))
    end
    return response
end

local function LoadScript(name)
    local script = Fetch(BASE_URL .. name)
    local fn, err = loadstring(script)
    if not fn then
        error("Failed to compile " .. tostring(name) .. ": " .. tostring(err))
    end
    return fn()
end

local Network = LoadScript("shared/network.lua")
LinuxHub = LinuxHub or {}
LinuxHub.Network = Network

local bypassScript = Fetch(BASE_URL .. "shared/adonisbypass.lua")
local bypassFn, bypassErr = loadstring(bypassScript)
if not bypassFn then
    error("Failed to compile bypass script: " .. tostring(bypassErr))
end
if bypassFn then
    bypassFn()
end

local version = "1.0.0"
LINUXHUB_VERSION = version

local gamesList = Fetch(BASE_URL .. "games.lua")
local gamesFn, gamesErr = loadstring(gamesList)
if not gamesFn then
    error("Failed to compile games list: " .. tostring(gamesErr))
end
local games = gamesFn()

local placeId = game.PlaceId or game.GameId
local gameEntry = games[placeId]
if not gameEntry then
    LoadScript("games/universal/init.lua")
    return
end

LoadScript(gameEntry)
