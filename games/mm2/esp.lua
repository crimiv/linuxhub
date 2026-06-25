local WindUI = AppleHub.WindUI
local utils = AppleHub.Utils
local config = AppleHub.Config

local VisualTab = AppleHub.Window:Tab({ Title = "Visual" })

local espEnabled = false
local highlightInstances = {}
local playerRoles = {}

local function GetPlayerRoleColor(player)
    if not player then return nil end
    local role = playerRoles[player]
    if role == "murderer" then
        return config.colors.murderer
    elseif role == "sheriff" then
        return config.colors.sheriff
    else
        if utils.PlayerHasTool(player, "Knife") then
            return config.colors.murderer
        elseif utils.PlayerHasTool(player, "Gun") then
            return config.colors.sheriff
        else
            return config.colors.innocent
        end
    end
end

local function UpdateESP()
    for _, highlight in pairs(highlightInstances) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    highlightInstances = {}
    if not espEnabled then return end
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end
    for _, player in pairs(game.Players:GetPlayers()) do
        if player == localPlayer then continue end
        if not player.Character then continue end
        local roleColor = GetPlayerRoleColor(player)
        if not roleColor then continue end
        local highlight = Instance.new("Highlight")
        highlight.Adornee = player.Character
        highlight.FillColor = roleColor
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = roleColor
        highlight.OutlineTransparency = 0.2
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = player.Character
        highlightInstances[player] = highlight
    end
end

local function AssignFallbackRoles()
    for _, player in pairs(game.Players:GetPlayers()) do
        if not playerRoles[player] then
            if utils.PlayerHasTool(player, "Knife") then
                playerRoles[player] = "murderer"
            elseif utils.PlayerHasTool(player, "Gun") then
                playerRoles[player] = "sheriff"
            else
                playerRoles[player] = "innocent"
            end
        end
    end
end

local function GetCurrentMurderer()
    for player, role in pairs(playerRoles) do
        if role == "murderer" then return player end
    end
    for _, player in pairs(game.Players:GetPlayers()) do
        if utils.PlayerHasTool(player, "Knife") then return player end
    end
    return nil
end

local function GetCurrentSheriff()
    for player, role in pairs(playerRoles) do
        if role == "sheriff" then return player end
    end
    for _, player in pairs(game.Players:GetPlayers()) do
        if utils.PlayerHasTool(player, "Gun") then return player end
    end
    return nil
end

local replicatedStorage = game:GetService("ReplicatedStorage")
local remotes = replicatedStorage:FindFirstChild("Remotes")
local extras = remotes and remotes:FindFirstChild("Extras")
local setMurdererRemote = extras and extras:FindFirstChild("SetMurderer")
local setSheriffRemote = extras and extras:FindFirstChild("SetSheriff")

if setMurdererRemote and setMurdererRemote:IsA("RemoteEvent") then
    setMurdererRemote.OnClientEvent:Connect(function(...)
        local player = utils.GetPlayerFromArg(...)
        if player then
            playerRoles[player] = "murderer"
            if espEnabled then UpdateESP() end
        end
    end)
end

if setSheriffRemote and setSheriffRemote:IsA("RemoteEvent") then
    setSheriffRemote.OnClientEvent:Connect(function(...)
        local player = utils.GetPlayerFromArg(...)
        if player then
            playerRoles[player] = "sheriff"
            if espEnabled then UpdateESP() end
        end
    end)
end

local roundTimer = workspace:FindFirstChild("RoundTimerPart")
if roundTimer then
    roundTimer:GetAttributeChangedSignal("Time"):Connect(function()
        local time = roundTimer:GetAttribute("Time") or -1
        if time <= 0 then
            for player, _ in pairs(playerRoles) do
                playerRoles[player] = "innocent"
            end
            if espEnabled then UpdateESP() end
        end
    end)
end

AssignFallbackRoles()
if espEnabled then UpdateESP() end

game.Players.PlayerAdded:Connect(function(player)
    if not playerRoles[player] then
        if utils.PlayerHasTool(player, "Knife") then
            playerRoles[player] = "murderer"
        elseif utils.PlayerHasTool(player, "Gun") then
            playerRoles[player] = "sheriff"
        else
            playerRoles[player] = "innocent"
        end
    end
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if not playerRoles[player] then
            if utils.PlayerHasTool(player, "Knife") then
                playerRoles[player] = "murderer"
            elseif utils.PlayerHasTool(player, "Gun") then
                playerRoles[player] = "sheriff"
            else
                playerRoles[player] = "innocent"
            end
        end
        UpdateESP()
    end)
end)

game.Players.PlayerRemoving:Connect(function(player)
    if highlightInstances[player] then
        highlightInstances[player]:Destroy()
        highlightInstances[player] = nil
    end
    playerRoles[player] = nil
end)

game:GetService("RunService").Heartbeat:Connect(function()
    if espEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if not playerRoles[player] then
                if utils.PlayerHasTool(player, "Knife") then
                    playerRoles[player] = "murderer"
                elseif utils.PlayerHasTool(player, "Gun") then
                    playerRoles[player] = "sheriff"
                else
                    playerRoles[player] = "innocent"
                end
            end
        end
        UpdateESP()
    end
end)

VisualTab:Toggle({
    Title = "ESP",
    Value = false,
    Callback = function(state)
        espEnabled = state
        WindUI:Notify({
            Title = "ESP",
            Content = espEnabled and "ESP Enabled" or "ESP Disabled",
            Duration = 2,
        })
        if not espEnabled then
            for _, highlight in pairs(highlightInstances) do
                if highlight and highlight.Parent then
                    highlight:Destroy()
                end
            end
            highlightInstances = {}
        else
            UpdateESP()
        end
    end
})

AppleHub.GetCurrentMurderer = GetCurrentMurderer
AppleHub.GetCurrentSheriff = GetCurrentSheriff
AppleHub.playerRoles = playerRoles