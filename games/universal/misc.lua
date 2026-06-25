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

local walkflingEnabled = AppleHub.Toggles.walkflingEnabled or false
local walkflingPower = AppleHub.Toggles.walkflingPower or 500000
local walkflingCooldown = 0.5
local walkflingLastFling = {}
local walkflingConnections = {}
local walkflingTouchConn = nil

local function CleanupWalkfling()
    if walkflingTouchConn then
        walkflingTouchConn:Disconnect()
        walkflingTouchConn = nil
    end
    for _, conn in ipairs(walkflingConnections) do
        pcall(function() conn:Disconnect() end)
    end
    walkflingConnections = {}
end

local function SetupWalkfling()
    CleanupWalkfling()
    if not walkflingEnabled then return end
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end
    local character = localPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    walkflingTouchConn = rootPart.Touched:Connect(function(hit)
        if not walkflingEnabled then return end
        local target = game.Players:GetPlayerFromCharacter(hit.Parent)
        if not target or target == localPlayer then return end
        local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end
        local now = tick()
        if walkflingLastFling[target] and now - walkflingLastFling[target] < walkflingCooldown then return end
        walkflingLastFling[target] = now
        local direction = (targetRoot.Position - rootPart.Position).Unit
        local velocity = direction * walkflingPower + Vector3.new(0, walkflingPower * 0.5, 0)
        targetRoot.AssemblyLinearVelocity = velocity
    end)

    local function OnCharacterAddedForWalkfling(char)
        task.wait(0.1)
        if walkflingEnabled then
            SetupWalkfling()
        end
    end

    local charAddedConn = localPlayer.CharacterAdded:Connect(OnCharacterAddedForWalkfling)
    table.insert(walkflingConnections, charAddedConn)
end

local function ToggleWalkfling(state)
    walkflingEnabled = state
    AppleHub.Toggles.walkflingEnabled = state
    if AppleHub.SaveSettings then AppleHub.SaveSettings() end
    if state then
        SetupWalkfling()
        WindUI:Notify({ Title = "Walkfling", Content = "Enabled", Duration = 2 })
    else
        CleanupWalkfling()
        WindUI:Notify({ Title = "Walkfling", Content = "Disabled", Duration = 2 })
    end
end

MiscTab:Toggle({
    Title = "Walkfling",
    Value = walkflingEnabled,
    Callback = function(state)
        ToggleWalkfling(state)
    end
})

MiscTab:Slider({
    Title = "Walkfling Power",
    Desc = "Velocity applied to players you touch",
    Min = 1000,
    Max = 1000000,
    Default = walkflingPower,
    Callback = function(value)
        walkflingPower = value
        AppleHub.Toggles.walkflingPower = value
        if AppleHub.SaveSettings then AppleHub.SaveSettings() end
    end
})

local originalDisableAll = AppleHub.DisableAll
AppleHub.DisableAll = function()
    if walkflingEnabled then
        walkflingEnabled = false
        AppleHub.Toggles.walkflingEnabled = false
        if AppleHub.SaveSettings then AppleHub.SaveSettings() end
        CleanupWalkfling()
    end
    if antiFlingEnabled then
        antiFlingEnabled = false
        AppleHub.Toggles.antiFlingEnabled = false
        if AppleHub.SaveSettings then AppleHub.SaveSettings() end
        CleanupAntiFling()
    end
    if originalDisableAll then
        originalDisableAll()
    end
end