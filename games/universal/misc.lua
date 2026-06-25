local WindUI = AppleHub.WindUI

local MiscTab = AppleHub.Window:Tab({ Title = "Misc" })

local antiFlingEnabled = AppleHub.Toggles.antiFlingEnabled or false
local antiFlingConnections = {}

local function CleanupAntiFling()
    for _, conn in ipairs(antiFlingConnections) do
        pcall(function() conn:Disconnect() end)
    end
    antiFlingConnections = {}
end

local function SetupAntiFling()
    CleanupAntiFling()
    if not antiFlingEnabled then return end

    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end

    local function GetCharacter()
        return localPlayer.Character
    end

    local function GetHumanoidRootPart()
        local char = GetCharacter()
        if char then
            return char:FindFirstChild("HumanoidRootPart")
        end
        return nil
    end

    local function GetHumanoid()
        local char = GetCharacter()
        if char then
            return char:FindFirstChildOfClass("Humanoid")
        end
        return nil
    end

    local lastResetTime = 0

    local function ResetVelocity()
        local now = tick()
        if now - lastResetTime < 0.05 then return end
        lastResetTime = now

        local rootPart = GetHumanoidRootPart()
        if rootPart then
            rootPart.Velocity = Vector3.new(0, 0, 0)
            rootPart.RotVelocity = Vector3.new(0, 0, 0)
            rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end

        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.PlatformStand = false
        end
    end

    local function RemoveBodyVelocityParts()
        local char = GetCharacter()
        if not char then return end
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("BodyVelocity") or child:IsA("BodyAngularVelocity") or child:IsA("BodyForce") or child:IsA("BodyThrust") or child:IsA("RocketPropulsion") then
                child:Destroy()
            end
        end
    end

    local lastPos = nil
    local flingDetected = false

    local function DetectAndCounterFling()
        local rootPart = GetHumanoidRootPart()
        if not rootPart then return end

        local currentPos = rootPart.Position
        local velocity = rootPart.Velocity

        if lastPos then
            local dist = (currentPos - lastPos).Magnitude
            local velMag = velocity.Magnitude

            if dist > 30 or velMag > 150 then
                flingDetected = true
                ResetVelocity()
                RemoveBodyVelocityParts()
                if rootPart then
                    rootPart.CFrame = CFrame.new(lastPos or currentPos)
                end
                flingDetected = false
                lastPos = rootPart.Position
                return
            end
        end

        if flingDetected then
            flingDetected = false
        end

        lastPos = currentPos
    end

    local heartbeatConn = game:GetService("RunService").Heartbeat:Connect(function()
        if _G.APPLE_HUB_UPDATING then return end
        if not antiFlingEnabled then return end
        pcall(DetectAndCounterFling)
    end)
    table.insert(antiFlingConnections, heartbeatConn)

    local steppedConn = game:GetService("RunService").Stepped:Connect(function()
        if _G.APPLE_HUB_UPDATING then return end
        if not antiFlingEnabled then return end
        pcall(RemoveBodyVelocityParts)
    end)
    table.insert(antiFlingConnections, steppedConn)

    local function OnCharacterAdded(char)
        task.wait(0.1)
        lastPos = nil
        flingDetected = false
        pcall(function()
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.Velocity = Vector3.new(0, 0, 0)
                rootPart.RotVelocity = Vector3.new(0, 0, 0)
                rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
            RemoveBodyVelocityParts()
        end)
    end

    if localPlayer.Character then
        OnCharacterAdded(localPlayer.Character)
    end

    local charAddedConn = localPlayer.CharacterAdded:Connect(OnCharacterAdded)
    table.insert(antiFlingConnections, charAddedConn)

    local humanoid = GetHumanoid()
    if humanoid then
        local stateChangeConn = humanoid.StateChanged:Connect(function(oldState, newState)
            if _G.APPLE_HUB_UPDATING then return end
            if not antiFlingEnabled then return end
            if newState == Enum.HumanoidStateType.FallingDown or newState == Enum.HumanoidStateType.Physics then
                pcall(function()
                    ResetVelocity()
                    local rootPart = GetHumanoidRootPart()
                    if rootPart and lastPos then
                        rootPart.CFrame = CFrame.new(lastPos)
                    end
                end)
            end
        end)
        table.insert(antiFlingConnections, stateChangeConn)
    end

    local function OnHumanoidAdded(char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local stateChangeConn2 = hum.StateChanged:Connect(function(oldState, newState)
                if _G.APPLE_HUB_UPDATING then return end
                if not antiFlingEnabled then return end
                if newState == Enum.HumanoidStateType.FallingDown or newState == Enum.HumanoidStateType.Physics then
                    pcall(function()
                        ResetVelocity()
                        local rootPart = GetHumanoidRootPart()
                        if rootPart and lastPos then
                            rootPart.CFrame = CFrame.new(lastPos)
                        end
                    end)
                end
            end)
            table.insert(antiFlingConnections, stateChangeConn2)
        end
    end

    if localPlayer.Character then
        OnHumanoidAdded(localPlayer.Character)
    end

    local charAddedConn2 = localPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        OnHumanoidAdded(char)
    end)
    table.insert(antiFlingConnections, charAddedConn2)
end

local function ToggleAntiFling(state)
    antiFlingEnabled = state
    AppleHub.Toggles.antiFlingEnabled = state
    if AppleHub.SaveSettings then AppleHub.SaveSettings() end
    if state then
        SetupAntiFling()
        WindUI:Notify({ Title = "Anti-Fling", Content = "Enabled", Duration = 2 })
    else
        CleanupAntiFling()
        WindUI:Notify({ Title = "Anti-Fling", Content = "Disabled", Duration = 2 })
    end
end

MiscTab:Toggle({
    Title = "Anti-Fling",
    Value = antiFlingEnabled,
    Callback = function(state)
        ToggleAntiFling(state)
    end
})

local walkFlingEnabled = AppleHub.Toggles.walkFlingEnabled or false
local walkFlingSpeed = AppleHub.Toggles.walkFlingSpeed or 500
local defaultWalkSpeed = 16
local walkFlingConnections = {}

local function CleanupWalkFling()
    for _, conn in ipairs(walkFlingConnections) do
        pcall(function() conn:Disconnect() end)
    end
    walkFlingConnections = {}
    local localPlayer = game.Players.LocalPlayer
    if localPlayer and localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = defaultWalkSpeed
        end
    end
end

local function SetupWalkFling()
    CleanupWalkFling()
    if not walkFlingEnabled then return end

    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end

    local function ApplySpeed()
        local char = localPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = walkFlingSpeed
            end
        end
    end

    local function OnCharacterAdded(char)
        task.wait(0.1)
        ApplySpeed()
    end

    if localPlayer.Character then
        ApplySpeed()
    end

    local conn1 = localPlayer.CharacterAdded:Connect(OnCharacterAdded)
    table.insert(walkFlingConnections, conn1)

    local conn2 = game:GetService("RunService").Heartbeat:Connect(function()
        if _G.APPLE_HUB_UPDATING then return end
        if not walkFlingEnabled then return end
        pcall(ApplySpeed)
    end)
    table.insert(walkFlingConnections, conn2)
end

local function ToggleWalkFling(state)
    walkFlingEnabled = state
    AppleHub.Toggles.walkFlingEnabled = state
    if AppleHub.SaveSettings then AppleHub.SaveSettings() end
    if state then
        SetupWalkFling()
        WindUI:Notify({ Title = "WalkFling", Content = "Enabled (" .. walkFlingSpeed .. " speed)", Duration = 2 })
    else
        CleanupWalkFling()
        WindUI:Notify({ Title = "WalkFling", Content = "Disabled", Duration = 2 })
    end
end

MiscTab:Toggle({
    Title = "WalkFling",
    Value = walkFlingEnabled,
    Callback = function(state)
        ToggleWalkFling(state)
    end
})

MiscTab:Slider({
    Title = "WalkFling Speed",
    Desc = "WalkSpeed when WalkFling is enabled",
    Min = 100,
    Max = 1000,
    Default = walkFlingSpeed,
    Callback = function(value)
        walkFlingSpeed = value
        AppleHub.Toggles.walkFlingSpeed = value
        if AppleHub.SaveSettings then AppleHub.SaveSettings() end
        if walkFlingEnabled then
            SetupWalkFling()
            WindUI:Notify({ Title = "WalkFling", Content = "Speed set to " .. value, Duration = 2 })
        end
    end
})

AppleHub.DisableAll = function()
    if antiFlingEnabled then
        antiFlingEnabled = false
        AppleHub.Toggles.antiFlingEnabled = false
        if AppleHub.SaveSettings then AppleHub.SaveSettings() end
        CleanupAntiFling()
    end
    if walkFlingEnabled then
        walkFlingEnabled = false
        AppleHub.Toggles.walkFlingEnabled = false
        if AppleHub.SaveSettings then AppleHub.SaveSettings() end
        CleanupWalkFling()
    end
end