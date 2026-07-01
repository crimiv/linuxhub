local BASE_URL = "https://raw.githubusercontent.com/crimiv/linuxhub/main/"

local function readLocalFile(path)
    local candidates = {
        path,
        "./" .. path,
        "../" .. path,
    }

    if not path:match("^vendor/") then
        table.insert(candidates, "vendor/" .. path)
        table.insert(candidates, "./vendor/" .. path)
    end

    if not path:match("^shared/") then
        table.insert(candidates, "shared/" .. path)
        table.insert(candidates, "./shared/" .. path)
    end

    for _, candidate in ipairs(candidates) do
        if type(readfile) == "function" and type(isfile) == "function" then
            local ok, content = pcall(readfile, candidate)
            if ok and type(content) == "string" then
                return content
            end
        end

        local ok, file = pcall(function()
            return io.open(candidate, "r")
        end)
        if ok and file then
            local content = file:read("*a")
            file:close()
            return content
        end
    end
    return nil
end

local function Fetch(url, opts)
    opts = opts or {}
    local function fallbackLocal()
        if opts.resourcePath then
            return readLocalFile(opts.resourcePath)
        end
        return nil
    end

    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if not success or type(response) ~= "string" then
        local fallback = fallbackLocal()
        if fallback then
            return fallback
        end
        error("Failed to fetch URL: " .. tostring(url) .. " (" .. tostring(response) .. ")")
    end

    local normalized = response:gsub("^%s+", "")
    if normalized:find("^<") or normalized:find("404: Not Found") or normalized:find("403: Forbidden") or normalized:find("Bad Request") or normalized:find("429") or normalized:find("Too Many Requests") or normalized:find("rate limit") then
        local fallback = fallbackLocal()
        if fallback then
            return fallback
        end
        error("Invalid fetch response from " .. tostring(url))
    end
    return response
end

local function LoadScript(name)
    local script = Fetch(BASE_URL .. name, { resourcePath = name })
    local fn, err = loadstring(script)
    if not fn then
        error("Failed to compile " .. tostring(name) .. ": " .. tostring(err))
    end
    return fn()
end

local Network = LoadScript("shared/network.lua")
LinuxHub = LinuxHub or {}
LinuxHub.Network = Network

-- Always run adonisbypass; use Network loader so vendor fallback/cache applies.
do
    local ok, err = pcall(function()
        if LinuxHub and LinuxHub.Network and LinuxHub.Network.LoadRelative then
            LinuxHub.Network.LoadRelative(BASE_URL, "shared/adonisbypass.lua")
        else
            local bypassScript = Fetch(BASE_URL .. "shared/adonisbypass.lua")
            local bypassFn, bypassErr = loadstring(bypassScript)
            if not bypassFn then
                error("Failed to compile bypass script: " .. tostring(bypassErr))
            end
            bypassFn()
        end
    end)
    if not ok then
        warn("Adonis bypass load failed: " .. tostring(err))
    end
end

local version = "1.0.0"
LINUXHUB_VERSION = version

local gamesList = Fetch(BASE_URL .. "games.lua", { resourcePath = "games.lua" })
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
