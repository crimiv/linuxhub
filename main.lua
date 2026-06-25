local function Fetch(url)
    return game:HttpGet(url)
end

local BASE_URL = "https://raw.githubusercontent.com/crimiv/applehub/main/"

local function LoadScript(name)
    local script = Fetch(BASE_URL .. name)
    assert(loadstring(script))()
end

local bypassScript = Fetch(BASE_URL .. "shared/adonisbypass.lua")
local bypassFn, err = loadstring(bypassScript)
if bypassFn then
    local bypass = bypassFn()
    if bypass and bypass.loaded then
    end
else
end

local gamesList = Fetch(BASE_URL .. "games.lua")
local games = assert(loadstring(gamesList))()

local placeId = game.PlaceId or game.GameId
local gameEntry = games[placeId]
if not gameEntry then
    LoadScript("games/universal/init.lua")
    return
end

LoadScript(gameEntry)