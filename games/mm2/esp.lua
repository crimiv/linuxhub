local WindUI = BanditHub.WindUI
local utils = BanditHub.Utils
local config = BanditHub.Config

local VisualTab = BanditHub.Window:Tab({ Title = "Visual" })

local espEnabled = BanditHub.Toggles.espEnabled or false
local highlightInstances = {}
local espUpdateCooldown = 0

-- GunDrop highlight (Visual)
local gunHighlightEnabled = BanditHub.Toggles.gunHighlightEnabled or false
local gunHighlightInstances = {} -- [gunDropInstance] = Highlight
local gunHighlightUpdateCooldown = 0
local gunHighlightTimer = nil


local function GetPlayerRoleColor(player)
    if not player then return nil end
    if utils.PlayerHasTool(player, "Knife") then
        return config.colors.murderer
    elseif utils.PlayerHasTool(player, "Gun") then
        return config.colors.sheriff
    else
        return config.colors.innocent
    end
end

local function ClearESP()
    for _, highlight in pairs(highlightInstances) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    highlightInstances = {}
end

local function UpdateESP()
    if _G.BANDITHUB_UPDATING then
        ClearESP()
        return
    end
    if not espEnabled then return end

    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end

    for _, player in pairs(game.Players:GetPlayers()) do
        if player == localPlayer then continue end
        if not player.Character then continue end

        local roleColor = GetPlayerRoleColor(player)
        if not roleColor then continue end

        local highlight = highlightInstances[player]
        if not highlight or not highlight.Parent then
            highlight = Instance.new("Highlight")
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0.2
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = player.Character
            highlightInstances[player] = highlight
        end

        highlight.Adornee = player.Character
        highlight.FillColor = roleColor
        highlight.OutlineColor = roleColor
    end
end

local function GetCurrentMurderer()
    for _, player in pairs(game.Players:GetPlayers()) do
        if utils.PlayerHasTool(player, "Knife") then
            return player
        end
    end
    return nil
end

local function GetCurrentSheriff()
    for _, player in pairs(game.Players:GetPlayers()) do
        if utils.PlayerHasTool(player, "Gun") then
            return player
        end
    end
    return nil
end

local function GetGunDropParts()
    local parts = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "GunDrop" then
            table.insert(parts, obj)
        end
    end
    return parts
end

local function ClearGunDropsHighlight()
    for _, highlight in pairs(gunHighlightInstances) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    gunHighlightInstances = {}
end

local function UpdateGunDropsHighlight(force)
    if _G.BANDITHUB_UPDATING then
        ClearGunDropsHighlight()
        return
    end
    if not gunHighlightEnabled then
        if force then
            ClearGunDropsHighlight()
        end
        return
    end

    local now = tick()
    if not force and now - gunHighlightUpdateCooldown < 0.5 then
        return
    end
    gunHighlightUpdateCooldown = now

    local gunDrops = GetGunDropParts()
    local seen = {}

    for _, gd in ipairs(gunDrops) do
        local highlight = gunHighlightInstances[gd]
        if not highlight or not highlight.Parent then
            highlight = Instance.new("Highlight")
            highlight.FillTransparency = 0.2
            highlight.OutlineTransparency = 0.0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = workspace
            gunHighlightInstances[gd] = highlight
        end
        highlight.Adornee = gd
        highlight.FillColor = config.colors.sheriff or Color3.fromRGB(0, 255, 255)
        highlight.OutlineColor = config.colors.sheriff or Color3.fromRGB(0, 255, 255)
        seen[gd] = true
    end

    -- Cleanup highlights for gun drops that no longer exist
    for gd, highlight in pairs(gunHighlightInstances) do
        if not seen[gd] then
            if highlight then highlight:Destroy() end
            gunHighlightInstances[gd] = nil
        end
    end
end

local replicatedStorage = game:GetService("ReplicatedStorage")
local remotes = replicatedStorage:FindFirstChild("Remotes")
local extras = remotes and remotes:FindFirstChild("Extras")
local setMurdererRemote = extras and extras:FindFirstChild("SetMurderer")
local setSheriffRemote = extras and extras:FindFirstChild("SetSheriff")

if setMurdererRemote and setMurdererRemote:IsA("RemoteEvent") then
    setMurdererRemote.OnClientEvent:Connect(function(...)
        if _G.BANDITHUB_UPDATING then return end
    end)
end

if setSheriffRemote and setSheriffRemote:IsA("RemoteEvent") then
    setSheriffRemote.OnClientEvent:Connect(function(...)
        if _G.BANDITHUB_UPDATING then return end
    end)
end

local roundTimer = workspace:FindFirstChild("RoundTimerPart")
if roundTimer then
    roundTimer:GetAttributeChangedSignal("Time"):Connect(function()
        if _G.BANDITHUB_UPDATING then return end
    end)
end

if espEnabled then UpdateESP() end

game.Players.PlayerAdded:Connect(function(player)
    if _G.BANDITHUB_UPDATING then return end
    player.CharacterAdded:Connect(function()
        if _G.BANDITHUB_UPDATING then return end
        task.wait(0.5)
        UpdateESP()
    end)
end)

game.Players.PlayerRemoving:Connect(function(player)
    if _G.BANDITHUB_UPDATING then return end
    if highlightInstances[player] then
        highlightInstances[player]:Destroy()
        highlightInstances[player] = nil
    end
end)

game:GetService("RunService").Heartbeat:Connect(function()
    if _G.BANDITHUB_UPDATING then return end

    local now = tick()

    if espEnabled then
        if now - espUpdateCooldown >= 0.6 then
            espUpdateCooldown = now
            UpdateESP()
        end
    end

    if gunHighlightEnabled then
        UpdateGunDropsHighlight(false)
    end
end)

VisualTab:Toggle({
    Title = "ESP Highlight",
    Value = espEnabled,
    Callback = function(state)
        espEnabled = state
        BanditHub.Toggles.espEnabled = state
        if BanditHub.SaveSettings then BanditHub.SaveSettings() end
        WindUI:Notify({
            Title = "ESP Highlight",
            Content = espEnabled and "ESP Enabled" or "ESP Disabled",
            Duration = 2,
        })
        if not espEnabled then
            ClearESP()
        else
            UpdateESP()
        end
    end
})

VisualTab:Toggle({
    Title = "Gun Highlight",
    Value = gunHighlightEnabled,
    Callback = function(state)
        gunHighlightEnabled = state
        BanditHub.Toggles.gunHighlightEnabled = state
        if BanditHub.SaveSettings then BanditHub.SaveSettings() end

        WindUI:Notify({
            Title = "Gun Highlight",
            Content = gunHighlightEnabled and "Enabled" or "Disabled",
            Duration = 2,
        })

        if not gunHighlightEnabled then
            ClearGunDropsHighlight()
        else
            UpdateGunDropsHighlight(true)
        end
    end
})

BanditHub.GetCurrentMurderer = GetCurrentMurderer
BanditHub.GetCurrentSheriff = GetCurrentSheriff

BanditHub.DisableAll = function()
    espEnabled = false
    BanditHub.Toggles.espEnabled = false
    if BanditHub.SaveSettings then BanditHub.SaveSettings() end
    ClearESP()

    gunHighlightEnabled = false
    BanditHub.Toggles.gunHighlightEnabled = false
    ClearGunDropsHighlight()
end
