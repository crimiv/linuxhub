local WindUI = AppleHub.WindUI
local utils = AppleHub.Utils
local config = AppleHub.Config

local CombatTab = AppleHub.Window:Tab({ Title = "Combat" })

local roundTimer = workspace:FindFirstChild("RoundTimerPart")

local function IsPlayerAlive()
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return false end
    local character = localPlayer.Character
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    return humanoid.Health > 0
end

local function IsRoundActive()
    if not roundTimer then return true end
    local time = roundTimer:GetAttribute("Time") or -1
    return time > 0
end

local function IsInLobby()
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return false end
    local character = localPlayer.Character
    if not character then return false end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    local lobby = workspace:FindFirstChild("RegularLobby")
    if not lobby then return false end
    return rootPart:IsDescendantOf(lobby)
end

local autoShootEnabled = AppleHub.Toggles.autoShootEnabled or false
local AUTO_SHOOT_COOLDOWN = config.cooldowns.autoShoot
local lastAutoShootTime = 0

local function ShootAtMurderer(silent)
    if _G.APPLE_HUB_UPDATING then return end
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then
        if not silent then utils.Notify({ Title = "Error", Content = "Local player not found", Duration = 2 }) end
        return
    end
    local murderer = AppleHub.GetCurrentMurderer()
    if not murderer then
        if not silent then utils.Notify({ Title = "Error", Content = "No murderer found", Duration = 2 }) end
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
        if not silent then utils.Notify({ Title = "Error", Content = "You don't have a gun", Duration = 2 }) end
        return
    end
    local character = localPlayer.Character
    if not character then
        if not silent then utils.Notify({ Title = "Error", Content = "Character not found", Duration = 2 }) end
        return
    end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        if not silent then utils.Notify({ Title = "Error", Content = "HumanoidRootPart not found", Duration = 2 }) end
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
        if not silent then utils.Notify({ Title = "Error", Content = "Murderer has no valid character", Duration = 2 }) end
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
        if not silent then utils.Notify({ Title = "Error", Content = "Shoot remote not found", Duration = 2 }) end
        rootPart.CFrame = originalCFrame
        return
    end
    rootPart.CFrame = originalCFrame
    if not silent then
        utils.Notify({ Title = "Combat", Content = "Shot fired at murderer!", Duration = 2 })
    end
end

game:GetService("RunService").Heartbeat:Connect(function()
    if _G.APPLE_HUB_UPDATING then return end
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
    Value = autoShootEnabled,
    Callback = function(state)
        autoShootEnabled = state
        AppleHub.Toggles.autoShootEnabled = state
        if AppleHub.SaveSettings then AppleHub.SaveSettings() end
        utils.Notify({
            Title = "Auto Shoot",
            Content = autoShootEnabled and "Enabled" or "Disabled",
            Duration = 2,
        })
        if autoShootEnabled then
            lastAutoShootTime = tick()
        end
    end
})

CombatTab:Button({
    Title = "Kill All",
    Callback = function()
        if _G.APPLE_HUB_UPDATING then return end
        local localPlayer = game.Players.LocalPlayer
        if not localPlayer then
            utils.Notify({ Title = "Error", Content = "Local player not found", Duration = 2 })
            return
        end
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
        if not knife then
            utils.Notify({ Title = "Error", Content = "You are not the murderer (no knife found)", Duration = 2 })
            return
        end
        local handleTouched = knife:FindFirstChild("Events") and knife.Events:FindFirstChild("HandleTouched")
        if not handleTouched or not handleTouched:IsA("RemoteEvent") then
            utils.Notify({ Title = "Error", Content = "HandleTouched remote not found", Duration = 2 })
            return
        end
        local killed = 0
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    handleTouched:FireServer(rootPart)
                    killed = killed + 1
                end
            end
        end
        if killed > 0 then
            utils.Notify({ Title = "Kill All", Content = "Killed " .. killed .. " players!", Duration = 2 })
        else
            utils.Notify({ Title = "Kill All", Content = "No valid players to kill", Duration = 2 })
        end
        if AppleHub.SaveSettings then AppleHub.SaveSettings() end
    end
})

CombatTab:Button({
    Title = "Kill All Except Sheriff",
    Callback = function()
        if _G.APPLE_HUB_UPDATING then return end
        local localPlayer = game.Players.LocalPlayer
        if not localPlayer then
            utils.Notify({ Title = "Error", Content = "Local player not found", Duration = 2 })
            return
        end
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
        if not knife then
            utils.Notify({ Title = "Error", Content = "You are not the murderer (no knife found)", Duration = 2 })
            return
        end
        local handleTouched = knife:FindFirstChild("Events") and knife.Events:FindFirstChild("HandleTouched")
        if not handleTouched or not handleTouched:IsA("RemoteEvent") then
            utils.Notify({ Title = "Error", Content = "HandleTouched remote not found", Duration = 2 })
            return
        end
        local sheriff = AppleHub.GetCurrentSheriff()
        local killed = 0
        for _, player in pairs(game.Players:GetPlayers()) do
            if player == localPlayer then continue end
            if sheriff and player == sheriff then continue end
            if player.Character then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    handleTouched:FireServer(rootPart)
                    killed = killed + 1
                end
            end
        end
        if killed > 0 then
            utils.Notify({ Title = "Kill All Except Sheriff", Content = "Killed " .. killed .. " players!", Duration = 2 })
        else
            utils.Notify({ Title = "Kill All Except Sheriff", Content = "No valid players to kill", Duration = 2 })
        end
        if AppleHub.SaveSettings then AppleHub.SaveSettings() end
    end
})

local autoKillAllEnabled = AppleHub.Toggles.autoKillAllEnabled or false
local AUTO_KILL_ALL_COOLDOWN = config.cooldowns.autoKillAll
local lastAutoKillAllTime = 0

local function KillAll()
    if _G.APPLE_HUB_UPDATING then return end
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
    if _G.APPLE_HUB_UPDATING then return end
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
    Value = autoKillAllEnabled,
    Callback = function(state)
        autoKillAllEnabled = state
        AppleHub.Toggles.autoKillAllEnabled = state
        if AppleHub.SaveSettings then AppleHub.SaveSettings() end
        utils.Notify({
            Title = "Auto Kill All",
            Content = autoKillAllEnabled and "Enabled" or "Disabled",
            Duration = 2,
        })
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
    if _G.APPLE_HUB_UPDATING then return end
    if not gunDrop or isTeleporting then return end
    if IsInLobby() then
        utils.Notify({ Title = "TP to Gun", Content = "Cannot teleport from lobby", Duration = 2 })
        return
    end
    if not IsPlayerAlive() or not IsRoundActive() then
        utils.Notify({ Title = "TP to Gun", Content = "You are dead or round inactive", Duration = 2 })
        return
    end
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
        if _G.APPLE_HUB_UPDATING then return end
        local localPlayer = game.Players.LocalPlayer
        if not localPlayer then
            utils.Notify({ Title = "Error", Content = "Local player not found", Duration = 2 })
            return
        end
        if IsInLobby() then
            utils.Notify({ Title = "TP to Gun", Content = "Cannot teleport from lobby", Duration = 2 })
            return
        end
        if not IsPlayerAlive() or not IsRoundActive() then
            utils.Notify({ Title = "TP to Gun", Content = "You are dead or round inactive", Duration = 2 })
            return
        end
        if utils.PlayerHasTool(localPlayer, "Knife") then
            utils.Notify({ Title = "TP to Gun", Content = "You are the murderer! Cannot teleport to GunDrop.", Duration = 2 })
            return
        end
        local gunDrop = GetClosestGunDrop()
        if not gunDrop then
            utils.Notify({ Title = "TP to Gun", Content = "No GunDrop found", Duration = 2 })
            return
        end
        TeleportToGunDrop(gunDrop)
        utils.Notify({ Title = "TP to Gun", Content = "Teleported and returned after collecting gun", Duration = 2 })
    end
})

local autoGunTPEnabled = AppleHub.Toggles.autoGunTPEnabled or false
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
    if _G.APPLE_HUB_UPDATING then return end
    if not autoGunTPEnabled or isTeleporting then return end
    if IsInLobby() then return end
    if not IsPlayerAlive() or not IsRoundActive() then return end
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
        if _G.APPLE_HUB_UPDATING then return end
        if not autoGunTPEnabled then return end
        local now = tick()
        if now - gunTPLastCheck < 0.5 then return end
        gunTPLastCheck = now
        TryTeleportToGun()
    end)
    local map = currentMap and workspace:FindFirstChild(currentMap)
    if map then
        mapChildAddedConnection = map.ChildAdded:Connect(function(child)
            if _G.APPLE_HUB_UPDATING then return end
            if child.Name == "GunDrop" then
                TryTeleportToGun()
            end
        end)
    end
    currentSheriff = nil
    for player, role in pairs(AppleHub.playerRoles) do
        if role == "sheriff" then
            currentSheriff = player
            break
        end
    end
    if currentSheriff then
        local function onSheriffCharacterRemoved()
            if _G.APPLE_HUB_UPDATING then return end
            task.wait(0.1)
            TryTeleportToGun()
        end
        if currentSheriff.Character then
            sheriffCharacterRemovedConnection = currentSheriff.Character:WaitForChild("Humanoid").Died:Connect(onSheriffCharacterRemoved)
        end
        sheriffPlayerRemovingConnection = currentSheriff.AncestryChanged:Connect(function()
            if _G.APPLE_HUB_UPDATING then return end
            if not currentSheriff.Parent then
                task.wait(0.1)
                TryTeleportToGun()
            end
        end)
    end
end

CombatTab:Toggle({
    Title = "Auto TP to Gun",
    Value = autoGunTPEnabled,
    Callback = function(state)
        autoGunTPEnabled = state
        AppleHub.Toggles.autoGunTPEnabled = state
        if AppleHub.SaveSettings then AppleHub.SaveSettings() end
        utils.Notify({
            Title = "Auto TP to Gun",
            Content = autoGunTPEnabled and "Enabled" or "Disabled",
            Duration = 2,
        })
        if state then
            SetupAutoGunTP()
        else
            CleanupAutoGunTP()
        end
    end
})

AppleHub.DisableAll = function()
    autoShootEnabled = false
    AppleHub.Toggles.autoShootEnabled = false
    autoKillAllEnabled = false
    AppleHub.Toggles.autoKillAllEnabled = false
    autoGunTPEnabled = false
    AppleHub.Toggles.autoGunTPEnabled = false
    if AppleHub.SaveSettings then AppleHub.SaveSettings() end
    CleanupAutoGunTP()
end