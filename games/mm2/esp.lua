local WindUI = LinuxHub.WindUI
local utils = LinuxHub.Utils
local config = LinuxHub.Config

local VisualTab = LinuxHub.Window:Tab({ Title = "Visual" })

local espEnabled = LinuxHub.Toggles.espEnabled or false
local skeletonEnabled = LinuxHub.Toggles.skeletonEnabled or false
local highlightInstances = {}
local skeletonLines = {}
local espUpdateCooldown = 0

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

local function ClearSkeleton()
    for player, lines in pairs(skeletonLines) do
        for _, line in pairs(lines) do
            if line then line:Remove() end
        end
    end
    skeletonLines = {}
end

local function UpdateSkeleton(player)
    if not skeletonEnabled then
        local lines = skeletonLines[player]
        if lines then
            for _, line in pairs(lines) do
                line.Visible = false
            end
        end
        return
    end

    if not player or player == game.Players.LocalPlayer then return end
    local character = player.Character
    if not character then
        local lines = skeletonLines[player]
        if lines then
            for _, line in pairs(lines) do
                line.Visible = false
            end
        end
        return
    end

    local function getPart(name)
        return character:FindFirstChild(name)
    end

    local head = getPart("Head")
    local upperTorso = getPart("UpperTorso") or getPart("Torso")
    local lowerTorso = getPart("LowerTorso") or getPart("Torso")
    local root = getPart("HumanoidRootPart")

    local leftUpperArm = getPart("LeftUpperArm") or getPart("Left Arm")
    local leftLowerArm = getPart("LeftLowerArm") or getPart("Left Arm")
    local leftHand = getPart("LeftHand") or getPart("Left Arm")
    local rightUpperArm = getPart("RightUpperArm") or getPart("Right Arm")
    local rightLowerArm = getPart("RightLowerArm") or getPart("Right Arm")
    local rightHand = getPart("RightHand") or getPart("Right Arm")

    local leftUpperLeg = getPart("LeftUpperLeg") or getPart("Left Leg")
    local leftLowerLeg = getPart("LeftLowerLeg") or getPart("Left Leg")
    local leftFoot = getPart("LeftFoot") or getPart("Left Leg")
    local rightUpperLeg = getPart("RightUpperLeg") or getPart("Right Leg")
    local rightLowerLeg = getPart("RightLowerLeg") or getPart("Right Leg")
    local rightFoot = getPart("RightFoot") or getPart("Right Leg")

    if not (head and upperTorso and lowerTorso) then
        local lines = skeletonLines[player]
        if lines then
            for _, line in pairs(lines) do
                line.Visible = false
            end
        end
        return
    end

    if not skeletonLines[player] then
        skeletonLines[player] = {}
    end
    local lines = skeletonLines[player]

    local function getLine(name)
        if not lines[name] then
            lines[name] = Drawing.new("Line")
            lines[name].Thickness = 1.5
            lines[name].Transparency = 1
        end
        return lines[name]
    end

    local function drawBone(fromPart, toPart, lineName)
        local line = getLine(lineName)
        if not fromPart or not toPart then
            line.Visible = false
            return
        end

        local fromPos = fromPart.Position
        local toPos = toPart.Position

        local fromScreen, fromVisible = workspace.CurrentCamera:WorldToViewportPoint(fromPos)
        local toScreen, toVisible = workspace.CurrentCamera:WorldToViewportPoint(toPos)

        if fromVisible and toVisible and fromScreen.Z > 0 and toScreen.Z > 0 then
            local color = GetPlayerRoleColor(player) or Color3.new(1, 1, 1)
            line.From = Vector2.new(fromScreen.X, fromScreen.Y)
            line.To = Vector2.new(toScreen.X, toScreen.Y)
            line.Color = color
            line.Visible = true
        else
            line.Visible = false
        end
    end

    local bones = {
        {"Head_UpperTorso", head, upperTorso},
        {"UpperTorso_LowerTorso", upperTorso, lowerTorso},

        {"LeftShoulder", upperTorso, leftUpperArm},
        {"LeftUpperArm", leftUpperArm, leftLowerArm},
        {"LeftLowerArm", leftLowerArm, leftHand},

        {"RightShoulder", upperTorso, rightUpperArm},
        {"RightUpperArm", rightUpperArm, rightLowerArm},
        {"RightLowerArm", rightLowerArm, rightHand},

        {"LeftHip", lowerTorso, leftUpperLeg},
        {"LeftUpperLeg", leftUpperLeg, leftLowerLeg},
        {"LeftLowerLeg", leftLowerLeg, leftFoot},

        {"RightHip", lowerTorso, rightUpperLeg},
        {"RightUpperLeg", rightUpperLeg, rightLowerLeg},
        {"RightLowerLeg", rightLowerLeg, rightFoot},
    }

    for _, bone in ipairs(bones) do
        drawBone(bone[2], bone[3], bone[1])
    end

    for name, line in pairs(lines) do
        local found = false
        for _, bone in ipairs(bones) do
            if bone[1] == name then
                found = true
                break
            end
        end
        if not found then
            line.Visible = false
        end
    end
end

local function UpdateESP()
    if _G.LINUXHUB_UPDATING then
        ClearESP()
        ClearSkeleton()
        return
    end
    ClearESP()
    if not espEnabled then
        if skeletonEnabled then
            for _, player in pairs(game.Players:GetPlayers()) do
                UpdateSkeleton(player)
            end
        end
        return
    end
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

        if skeletonEnabled then
            UpdateSkeleton(player)
        end
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

local replicatedStorage = game:GetService("ReplicatedStorage")
local remotes = replicatedStorage:FindFirstChild("Remotes")
local extras = remotes and remotes:FindFirstChild("Extras")
local setMurdererRemote = extras and extras:FindFirstChild("SetMurderer")
local setSheriffRemote = extras and extras:FindFirstChild("SetSheriff")

if setMurdererRemote and setMurdererRemote:IsA("RemoteEvent") then
    setMurdererRemote.OnClientEvent:Connect(function(...)
        if _G.LINUXHUB_UPDATING then return end
    end)
end

if setSheriffRemote and setSheriffRemote:IsA("RemoteEvent") then
    setSheriffRemote.OnClientEvent:Connect(function(...)
        if _G.LINUXHUB_UPDATING then return end
    end)
end

local roundTimer = workspace:FindFirstChild("RoundTimerPart")
if roundTimer then
    roundTimer:GetAttributeChangedSignal("Time"):Connect(function()
        if _G.LINUXHUB_UPDATING then return end
    end)
end

if espEnabled then UpdateESP() end
if skeletonEnabled then
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            UpdateSkeleton(player)
        end
    end
end

game.Players.PlayerAdded:Connect(function(player)
    if _G.LINUXHUB_UPDATING then return end
    player.CharacterAdded:Connect(function()
        if _G.LINUXHUB_UPDATING then return end
        task.wait(0.5)
        UpdateESP()
        if skeletonEnabled then UpdateSkeleton(player) end
    end)
end)

game.Players.PlayerRemoving:Connect(function(player)
    if _G.LINUXHUB_UPDATING then return end
    if highlightInstances[player] then
        highlightInstances[player]:Destroy()
        highlightInstances[player] = nil
    end
    if skeletonLines[player] then
        for _, line in pairs(skeletonLines[player]) do
            line:Remove()
        end
        skeletonLines[player] = nil
    end
end)

game:GetService("RunService").Heartbeat:Connect(function()
    if _G.LINUXHUB_UPDATING then return end
    local now = tick()
    if espEnabled or skeletonEnabled then
        if now - espUpdateCooldown >= 0.3 then
            espUpdateCooldown = now
            if espEnabled then
                UpdateESP()
            end
            if skeletonEnabled then
                for _, player in pairs(game.Players:GetPlayers()) do
                    if player ~= game.Players.LocalPlayer then
                        UpdateSkeleton(player)
                    end
                end
            end
        end
    end
end)

VisualTab:Toggle({
    Title = "ESP Highlight",
    Value = espEnabled,
    Callback = function(state)
        espEnabled = state
        LinuxHub.Toggles.espEnabled = state
        if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
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
    Title = "Skeleton ESP",
    Value = skeletonEnabled,
    Callback = function(state)
        skeletonEnabled = state
        LinuxHub.Toggles.skeletonEnabled = state
        if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
        WindUI:Notify({
            Title = "Skeleton ESP",
            Content = skeletonEnabled and "Skeleton Enabled" or "Skeleton Disabled",
            Duration = 2,
        })
        if not skeletonEnabled then
            ClearSkeleton()
        else
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer then
                    UpdateSkeleton(player)
                end
            end
        end
    end
})

LinuxHub.GetCurrentMurderer = GetCurrentMurderer
LinuxHub.GetCurrentSheriff = GetCurrentSheriff

LinuxHub.DisableAll = function()
    espEnabled = false
    skeletonEnabled = false
    LinuxHub.Toggles.espEnabled = false
    LinuxHub.Toggles.skeletonEnabled = false
    if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
    ClearESP()
    ClearSkeleton()
end
