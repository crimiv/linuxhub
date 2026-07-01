local WindUI = LinuxHub.WindUI
local utils = LinuxHub.Utils
local config = LinuxHub.Config

local VisualTab = LinuxHub.Window:Tab({ Title = "Visual" })

local espEnabled = LinuxHub.Toggles.espEnabled or false
local skeletonEnabled = LinuxHub.Toggles.skeletonEnabled or false
local gunESPEnabled = LinuxHub.Toggles.gunESPEnabled == nil and true or LinuxHub.Toggles.gunESPEnabled
local playerHighlightInstances = {}
local gunDropHighlightInstances = {}
local skeletonLines = {}

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

local function ClearPlayerHighlights()
    for _, highlight in pairs(playerHighlightInstances) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    playerHighlightInstances = {}
end

local function ClearGunDropHighlights()
    for _, highlight in pairs(gunDropHighlightInstances) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    gunDropHighlightInstances = {}
end

local function ClearESP()
    ClearPlayerHighlights()
    ClearGunDropHighlights()
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

local function UpdatePlayerHighlights()
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then
        ClearPlayerHighlights()
        return
    end

    for player, highlight in pairs(playerHighlightInstances) do
        if not player or player == localPlayer or not player.Character then
            if highlight and highlight.Parent then
                highlight:Destroy()
            end
            playerHighlightInstances[player] = nil
        end
    end

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer then
            local roleColor = GetPlayerRoleColor(player)
            local highlight = playerHighlightInstances[player]
            if roleColor and player.Character then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = workspace
                    playerHighlightInstances[player] = highlight
                end
                highlight.Adornee = player.Character
                highlight.FillColor = roleColor
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = roleColor
                highlight.OutlineTransparency = 0.2
                highlight.Enabled = true
            elseif highlight then
                highlight:Destroy()
                playerHighlightInstances[player] = nil
            end
        end
    end
end

local function UpdateGunDropHighlights()
    if not gunESPEnabled then
        ClearGunDropHighlights()
        return
    end

    local activeDrops = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "GunDrop" then
            activeDrops[obj] = true
            local highlight = gunDropHighlightInstances[obj]
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.FillColor = Color3.new(1, 0.8, 0)
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.FillTransparency = 0.3
                highlight.OutlineTransparency = 0.15
                highlight.Parent = workspace
                gunDropHighlightInstances[obj] = highlight
            end
            highlight.Adornee = obj
            highlight.Enabled = true
        end
    end

    for obj, highlight in pairs(gunDropHighlightInstances) do
        if not activeDrops[obj] and highlight and highlight.Parent then
            highlight:Destroy()
            gunDropHighlightInstances[obj] = nil
        end
    end
end

local function UpdateESP()
    if _G.LINUXHUB_UPDATING then
        ClearESP()
        ClearSkeleton()
        return
    end

    if espEnabled then
        UpdatePlayerHighlights()
    else
        ClearPlayerHighlights()
    end

    UpdateGunDropHighlights()

    if skeletonEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                UpdateSkeleton(player)
            end
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

if espEnabled or skeletonEnabled or gunESPEnabled then
    UpdateESP()
end

game.Players.PlayerAdded:Connect(function(player)
    if _G.LINUXHUB_UPDATING then return end
    player.CharacterAdded:Connect(function()
        if _G.LINUXHUB_UPDATING then return end
        task.wait(0.5)
        UpdateESP()
    end)
end)

game.Players.PlayerRemoving:Connect(function(player)
    if _G.LINUXHUB_UPDATING then return end
    if playerHighlightInstances[player] then
        playerHighlightInstances[player]:Destroy()
        playerHighlightInstances[player] = nil
    end
    if skeletonLines[player] then
        for _, line in pairs(skeletonLines[player]) do
            line:Remove()
        end
        skeletonLines[player] = nil
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if _G.LINUXHUB_UPDATING then return end
    UpdateESP()
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
            ClearPlayerHighlights()
        else
            UpdateESP()
        end
    end
})

VisualTab:Toggle({
    Title = "Dropped Gun ESP",
    Value = gunESPEnabled,
    Callback = function(state)
        gunESPEnabled = state
        LinuxHub.Toggles.gunESPEnabled = state
        if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
        WindUI:Notify({
            Title = "Dropped Gun ESP",
            Content = gunESPEnabled and "Enabled" or "Disabled",
            Duration = 2,
        })
        if not gunESPEnabled then
            ClearGunDropHighlights()
        else
            UpdateGunDropHighlights()
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
    gunESPEnabled = false
    LinuxHub.Toggles.espEnabled = false
    LinuxHub.Toggles.skeletonEnabled = false
    LinuxHub.Toggles.gunESPEnabled = false
    if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
    ClearESP()
    ClearSkeleton()
end
