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

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local function ShowUpdateAnimation()
    local player = Players.LocalPlayer
    if not player then
        return
    end
    local playerGui = player:FindFirstChild("PlayerGui")
    if not playerGui then
        return
    end
    local gui = Instance.new("ScreenGui")
    gui.Name = "SilverHubUpdateGui"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Position = UDim2.new(0.5, 0.5, 0.5, 0)
    frame.Size = UDim2.new(0, 420, 0, 160)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 36)
    title.Position = UDim2.new(0, 0, 0, 12)
    title.BackgroundTransparency = 1
    title.Text = "Silver Hub is updating"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Parent = frame

    local body = Instance.new("TextLabel")
    body.Size = UDim2.new(1, 0, 0, 22)
    body.Position = UDim2.new(0, 0, 0, 56)
    body.BackgroundTransparency = 1
    body.Text = "Please wait while the hub reloads"
    body.TextColor3 = Color3.fromRGB(200, 200, 200)
    body.Font = Enum.Font.Gotham
    body.TextScaled = true
    body.Parent = frame

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0.9, 0, 0, 18)
    barBg.Position = UDim2.new(0.05, 0, 0, 100)
    barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    barBg.BorderSizePixel = 0
    barBg.Parent = frame

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(161, 161, 170)
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg

    local tween = TweenService:Create(barFill, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
    tween:Play()
    tween.Completed:Wait()
    gui:Destroy()
end

local function PerformUpdate(newVersion)
    _G.APPLE_HUB_UPDATING = true
    if AppleHub then
        AppleHub.Toggles = AppleHub.Toggles or {}
        _G.APPLE_HUB_STATES = AppleHub.Toggles
        if AppleHub.Window then
            pcall(function()
                AppleHub.Window:Close()
            end)
        end
        if AppleHub.DisableAll then
            pcall(AppleHub.DisableAll)
        end
    end
    ShowUpdateAnimation()
    _G.APPLE_HUB_UPDATING = false
    loadstring(game:HttpGet(BASE_URL .. "main.lua"))()
end

task.spawn(function()
    while true do
        task.wait(5)
        if _G.APPLE_HUB_UPDATING then
            break
        end
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