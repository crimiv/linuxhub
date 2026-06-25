local WindUI = SilverHub.WindUI
local utils = SilverHub.Utils
local config = SilverHub.Config

local CombatTab = SilverHub.Window:Tab({ Title = "Combat" })

local autoShootEnabled = false
local AUTO_SHOOT_COOLDOWN = config.cooldowns.autoShoot
local lastAutoShootTime = 0

local function ShootAtMurderer(silent)
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then
        if not silent then return end
        return
    end
    local murderer = SilverHub.GetCurrentMurderer()
    if not murderer then
        if not silent then return end
        return
    end
    local gun = nil
    local backpack = localPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Gun" then
                gun = tool
                break
            end
        end
    end
    if not gun and localPlayer.Character then
        for _, tool in ipairs(localPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Gun" then
                gun = tool
                break
            end
        end
    end
    if not gun then
        if not silent then return end
        return
    end
    local character = localPlayer.Character
    if not character then
        if not silent then return end
        return
    end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        if not silent then return end
        return
    end
    local targetPos = nil
    if murderer.Character then
        local head = murderer.Character:FindFirstChild("Head")
        if head then
            targetPos = head.Position
        else
            local root = murderer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                targetPos = root.Position + Vector3.new(0, 1.5, 0)
            end
        end
    end
    if not targetPos then
        if not silent then return end
        return
    end
    local originalCFrame = rootPart.CFrame
    local teleportOffset = Vector3.new(0, 0, 1.5)
    local teleportCFrame = CFrame.new(targetPos + teleportOffset)
    rootPart.CFrame = teleportCFrame
    local originCFrame = rootPart.CFrame * CFrame.new(0, 0.5, -2)
    local targetCFrame = CFrame.new(targetPos)
    local shootRemote = gun:FindFirstChild("Shoot")
    if shootRemote and shootRemote:IsA("RemoteEvent") then
        shootRemote:FireServer(originCFrame, targetCFrame)
    else
        if not silent then return end
        rootPart.CFrame = originalCFrame
        return
    end
    rootPart.CFrame = originalCFrame
end

game:GetService("RunService").Heartbeat:Connect(function()
    if autoShootEnabled then
        local now = tick()
        if now - lastAutoShootTime >= AUTO_SHOOT_COOLDOWN then
            lastAutoShootTime = now
            pcall(function() ShootAtMurderer(true) end)
        end
    end
end)

CombatTab:Button({
    Title = "Shoot Murderer",
    Callback = function()
        ShootAtMurderer(false)
    end
})

CombatTab:Toggle({
    Title = "Auto Shoot Murderer",
    Value = false,
    Callback = function(state)
        autoShootEnabled = state
        if autoShootEnabled then
            lastAutoShootTime = tick()
        end
    end
})

CombatTab:Button({
    Title = "Kill All",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        if not localPlayer then return end
        local knife = nil
        local backpack = localPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.Name == "Knife" then
                    knife = tool
                    break
                end
            end
        end
        if not knife and localPlayer.Character then
            for _, tool in ipairs(localPlayer.Character:GetChildren()) do
                if tool:IsA("Tool") and tool.Name == "Knife" then
                    knife = tool
                    break
                end
            end
        end
        if not knife then return end
        local handleTouched = knife:FindFirstChild("Events") and knife.Events:FindFirstChild("HandleTouched")
        if not handleTouched or not handleTouched:IsA("RemoteEvent") then return end
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    handleTouched:FireServer(rootPart)
                end
            end
        end
    end
})

local autoKillAllEnabled = false
local AUTO_KILL_ALL_COOLDOWN = config.cooldowns.autoKillAll
local lastAutoKillAllTime = 0

local function KillAll()
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end
    local knife = nil
    local backpack = localPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Knife" then
                knife = tool
                break
            end
        end
    end
    if not knife and localPlayer.Character then
        for _, tool in ipairs(localPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Knife" then
                knife = tool
                break
            end
        end
    end
    if not knife then return end
    local handleTouched = knife:FindFirstChild("Events") and knife.Events:FindFirstChild("HandleTouched")
    if not handleTouched or not handleTouched:IsA("RemoteEvent") then return end
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                handleTouched:FireServer(rootPart)
            end
        end
    end
end

game:GetService("RunService").Heartbeat:Connect(function()
    if autoKillAllEnabled then
        local now = tick()
        if now - lastAutoKillAllTime >= AUTO_KILL_ALL_COOLDOWN then
            lastAutoKillAllTime = now
            pcall(KillAll)
        end
    end
end)

CombatTab:Toggle({
    Title = "Auto Kill All",
    Value = false,
    Callback = function(state)
        autoKillAllEnabled = state
        if autoKillAllEnabled then
            lastAutoKillAllTime = tick()
        end
    end
})

local function GetAllGunDrops()
    local gunDrops = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "GunDrop" then
            table.insert(gunDrops, obj)
        end
    end
    return gunDrops
end

local function GetClosestGunDrop()
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return nil end
    local character = localPlayer.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    local pos = rootPart.Position
    local gunDrops = GetAllGunDrops()
    local closest = nil
    local closestDist = math.huge
    for _, gd in ipairs(gunDrops) do
        local gdPos
        if gd:IsA("BasePart") then
            gdPos = gd.Position
        elseif gd:IsA("Model") then
            local primary = gd.PrimaryPart
            if primary then
                gdPos = primary.Position
            else
                local parts = gd:GetDescendants()
                for _, part in ipairs(parts) do
                    if part:IsA("BasePart") then
                        gdPos = part.Position
                        break
                    end
                end
            end
        end
        if gdPos then
            local dist = (pos - gdPos).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = gd
            end
        end
    end
    return closest
end

local isTeleporting = false

local function TeleportToGunDrop(gunDrop)
    if not gunDrop or isTeleporting then return end
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end
    local character = localPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local targetCFrame
    if gunDrop:IsA("BasePart") then
        targetCFrame = gunDrop.CFrame
    elseif gunDrop:IsA("Model") then
        local primary = gunDrop.PrimaryPart
        if primary then
            targetCFrame = primary.CFrame
        else
            local parts = gunDrop:GetDescendants()
            for _, part in ipairs(parts) do
                if part:IsA("BasePart") then
                    targetCFrame = part.CFrame
                    break
                end
            end
        end
    end
    if not targetCFrame then return end
    isTeleporting = true
    local originalCFrame = rootPart.CFrame
    rootPart.CFrame = targetCFrame
    local collected = false
    local con1, con2
    local function checkGun()
        if localPlayer.Backpack and localPlayer.Backpack:FindFirstChild("Gun") then
            collected = true
        elseif character and character:FindFirstChild("Gun") then
            collected = true
        end
        if collected then
            if con1 then con1:Disconnect() end
            if con2 then con2:Disconnect() end
        end
    end
    con1 = localPlayer.Backpack.ChildAdded:Connect(checkGun)
    con2 = character.ChildAdded:Connect(checkGun)
    checkGun()
    task.wait(1)
    con1:Disconnect()
    con2:Disconnect()
    rootPart.CFrame = originalCFrame
    isTeleporting = false
end

CombatTab:Button({
    Title = "TP to Gun",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        if not localPlayer then return end
        if utils.PlayerHasTool(localPlayer, "Knife") then return end
        local gunDrop = GetClosestGunDrop()
        if not gunDrop then return end
        TeleportToGunDrop(gunDrop)
    end
})

local autoGunTPEnabled = false
local gunTPTimer = nil
local gunTPLastCheck = 0
local currentSheriff = nil
local mapChildAddedConnection = nil
local sheriffCharacterRemovedConnection = nil
local sheriffPlayerRemovingConnection = nil

local function CleanupAutoGunTP()
    if gunTPTimer then
        gunTPTimer:Disconnect()
        gunTPTimer = nil
    end
    if mapChildAddedConnection then
        mapChildAddedConnection:Disconnect()
        mapChildAddedConnection = nil
    end
    if sheriffCharacterRemovedConnection then
        sheriffCharacterRemovedConnection:Disconnect()
        sheriffCharacterRemovedConnection = nil
    end
    if sheriffPlayerRemovingConnection then
        sheriffPlayerRemovingConnection:Disconnect()
        sheriffPlayerRemovingConnection = nil
    end
end

local function TryTeleportToGun()
    if not autoGunTPEnabled or isTeleporting then return end
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end
    if utils.PlayerHasTool(localPlayer, "Knife") then return end
    local gd = GetClosestGunDrop()
    if gd then
        TeleportToGunDrop(gd)
    end
end

local function SetupAutoGunTP()
    CleanupAutoGunTP()
    if not autoGunTPEnabled then return end
    TryTeleportToGun()
    gunTPLastCheck = 0
    gunTPTimer = game:GetService("RunService").Stepped:Connect(function()
        if not autoGunTPEnabled then return end
        local now = tick()
        if now - gunTPLastCheck < 0.5 then return end
        gunTPLastCheck = now
        TryTeleportToGun()
    end)
    local map = currentMap and workspace:FindFirstChild(currentMap)
    if map then
        mapChildAddedConnection = map.ChildAdded:Connect(function(child)
            if child.Name == "GunDrop" then
                TryTeleportToGun()
            end
        end)
    end
    currentSheriff = nil
    for player, role in pairs(SilverHub.playerRoles) do
        if role == "sheriff" then
            currentSheriff = player
            break
        end
    end
    if currentSheriff then
        local function onSheriffCharacterRemoved()
            task.wait(0.1)
            TryTeleportToGun()
        end
        if currentSheriff.Character then
            sheriffCharacterRemovedConnection = currentSheriff.Character:WaitForChild("Humanoid").Died:Connect(onSheriffCharacterRemoved)
        end
        sheriffPlayerRemovingConnection = currentSheriff.AncestryChanged:Connect(function()
            if not currentSheriff.Parent then
                task.wait(0.1)
                TryTeleportToGun()
            end
        end)
    end
end

CombatTab:Toggle({
    Title = "Auto TP to Gun",
    Value = false,
    Callback = function(state)
        autoGunTPEnabled = state
        if state then
            SetupAutoGunTP()
        else
            CleanupAutoGunTP()
        end
    end
})
