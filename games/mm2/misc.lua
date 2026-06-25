local WindUI = AppleHub.WindUI
local utils = AppleHub.Utils

local MiscTab = AppleHub.Window:Tab({ Title = "Misc" })

local selectedPlayerName = nil
local playerDropdown = nil

local function GetPlayerNames()
    local names = {}
    local localPlayer = game.Players.LocalPlayer
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= localPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

local function CreatePlayerDropdown()
    if playerDropdown then
        playerDropdown:Destroy()
        playerDropdown = nil
    end
    local playerNames = GetPlayerNames()
    if #playerNames == 0 then
        playerNames = {"No other players"}
        selectedPlayerName = nil
    else
        selectedPlayerName = playerNames[1]
    end
    playerDropdown = MiscTab:Dropdown({
        Title = "Select Player",
        Values = playerNames,
        Default = playerNames[1] or "No other players",
        Callback = function(value)
            selectedPlayerName = value
        end
    })
end

CreatePlayerDropdown()

MiscTab:Button({
    Title = "Teleport to Selected Player",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        if not localPlayer then
            WindUI:Notify({ Title = "Error", Content = "Local player not found", Duration = 2 })
            return
        end
        if not selectedPlayerName or selectedPlayerName == "No other players" then
            WindUI:Notify({ Title = "Error", Content = "No valid player selected", Duration = 2 })
            return
        end
        local targetPlayer = game.Players:FindFirstChild(selectedPlayerName)
        if not targetPlayer then
            WindUI:Notify({ Title = "Error", Content = "Selected player not found", Duration = 2 })
            return
        end
        local targetCharacter = targetPlayer.Character
        if not targetCharacter then
            WindUI:Notify({ Title = "Error", Content = "Selected player has no character", Duration = 2 })
            return
        end
        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            WindUI:Notify({ Title = "Error", Content = "Selected player has no HumanoidRootPart", Duration = 2 })
            return
        end
        local localCharacter = localPlayer.Character
        if not localCharacter then
            WindUI:Notify({ Title = "Error", Content = "Your character not found", Duration = 2 })
            return
        end
        local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
        if not localRoot then
            WindUI:Notify({ Title = "Error", Content = "Your HumanoidRootPart not found", Duration = 2 })
            return
        end
        localRoot.CFrame = targetRoot.CFrame
        WindUI:Notify({ Title = "Misc", Content = "Teleported to " .. targetPlayer.Name, Duration = 2 })
    end
})

local function SendChatMessage(message)
    local success, result = pcall(function()
        local TextChatService = game:GetService("TextChatService")
        local generalChatChannel = TextChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
        generalChatChannel:SendAsync(message)
        return true
    end)
    if not success then
        WindUI:Notify({ Title = "Error", Content = "Failed to send chat message", Duration = 2 })
    end
end

MiscTab:Button({
    Title = "Expose Murderer",
    Callback = function()
        local murderer = AppleHub.GetCurrentMurderer()
        if murderer then
            SendChatMessage("Murderer is " .. murderer.Name)
            WindUI:Notify({ Title = "Expose", Content = "Murderer exposed in chat", Duration = 2 })
        else
            WindUI:Notify({ Title = "Expose", Content = "No murderer found", Duration = 2 })
        end
    end
})

MiscTab:Button({
    Title = "Expose Sheriff",
    Callback = function()
        local sheriff = AppleHub.GetCurrentSheriff()
        if sheriff then
            SendChatMessage("Sheriff is " .. sheriff.Name)
            WindUI:Notify({ Title = "Expose", Content = "Sheriff exposed in chat", Duration = 2 })
        else
            WindUI:Notify({ Title = "Expose", Content = "No sheriff found", Duration = 2 })
        end
    end
})

MiscTab:Button({
    Title = "Teleport to Murderer",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        if not localPlayer then
            WindUI:Notify({ Title = "Error", Content = "Local player not found", Duration = 2 })
            return
        end
        local murderer = AppleHub.GetCurrentMurderer()
        if not murderer then
            WindUI:Notify({ Title = "Error", Content = "No murderer found", Duration = 2 })
            return
        end
        local targetCharacter = murderer.Character
        if not targetCharacter then
            WindUI:Notify({ Title = "Error", Content = "Murderer has no character", Duration = 2 })
            return
        end
        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            WindUI:Notify({ Title = "Error", Content = "Murderer has no HumanoidRootPart", Duration = 2 })
            return
        end
        local localCharacter = localPlayer.Character
        if not localCharacter then
            WindUI:Notify({ Title = "Error", Content = "Your character not found", Duration = 2 })
            return
        end
        local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
        if not localRoot then
            WindUI:Notify({ Title = "Error", Content = "Your HumanoidRootPart not found", Duration = 2 })
            return
        end
        localRoot.CFrame = targetRoot.CFrame
        WindUI:Notify({ Title = "Misc", Content = "Teleported to murderer", Duration = 2 })
    end
})

MiscTab:Button({
    Title = "Teleport to Sheriff",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        if not localPlayer then
            WindUI:Notify({ Title = "Error", Content = "Local player not found", Duration = 2 })
            return
        end
        local sheriff = AppleHub.GetCurrentSheriff()
        if not sheriff then
            WindUI:Notify({ Title = "Error", Content = "No sheriff found", Duration = 2 })
            return
        end
        local targetCharacter = sheriff.Character
        if not targetCharacter then
            WindUI:Notify({ Title = "Error", Content = "Sheriff has no character", Duration = 2 })
            return
        end
        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            WindUI:Notify({ Title = "Error", Content = "Sheriff has no HumanoidRootPart", Duration = 2 })
            return
        end
        local localCharacter = localPlayer.Character
        if not localCharacter then
            WindUI:Notify({ Title = "Error", Content = "Your character not found", Duration = 2 })
            return
        end
        local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
        if not localRoot then
            WindUI:Notify({ Title = "Error", Content = "Your HumanoidRootPart not found", Duration = 2 })
            return
        end
        localRoot.CFrame = targetRoot.CFrame
        WindUI:Notify({ Title = "Misc", Content = "Teleported to sheriff", Duration = 2 })
    end
})

MiscTab:Button({
    Title = "Server Hop",
    Callback = function()
        local placeId = game.PlaceId
        if not placeId then
            WindUI:Notify({ Title = "Error", Content = "Could not get PlaceId", Duration = 2 })
            return
        end

        local HttpService = game:GetService("HttpService")
        local TeleportService = game:GetService("TeleportService")
        local currentJobId = game.JobId
        local minPlayers = 5
        local maxRetries = 5
        local attempts = 0
        local candidates = nil

        local function fetchServers()
            local success, result = pcall(function()
                return game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=100")
            end)
            if not success then
                return nil
            end
            local decoded
            pcall(function()
                decoded = HttpService:JSONDecode(result)
            end)
            if not decoded or not decoded.data then
                return nil
            end
            local servers = {}
            for _, server in ipairs(decoded.data) do
                if server.id ~= currentJobId and server.playing >= minPlayers then
                    table.insert(servers, server.id)
                end
            end
            return servers
        end

        candidates = fetchServers()
        if not candidates then
            WindUI:Notify({ Title = "Error", Content = "Failed to fetch server list", Duration = 2 })
            return
        end

        if #candidates == 0 then
            WindUI:Notify({ Title = "Server Hop", Content = "No suitable servers found", Duration = 2 })
            return
        end

        while attempts < maxRetries do
            attempts = attempts + 1
            local idx = math.random(1, #candidates)
            local targetServer = candidates[idx]
            table.remove(candidates, idx)

            local success, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId, targetServer, game.Players.LocalPlayer)
            end)

            if success then
                WindUI:Notify({ Title = "Server Hop", Content = "Teleporting to new server...", Duration = 2 })
                return
            else
                local errStr = tostring(err)
                if errStr:find("772") or errStr:lower():find("full") then
                    if #candidates == 0 then
                        WindUI:Notify({ Title = "Server Hop", Content = "All servers are full. Try again later.", Duration = 3 })
                        return
                    end
                    WindUI:Notify({ Title = "Server Hop", Content = "Server full, trying another... (" .. attempts .. "/" .. maxRetries .. ")", Duration = 2 })
                else
                    WindUI:Notify({ Title = "Error", Content = "Failed to teleport: " .. errStr, Duration = 3 })
                    return
                end
            end
        end

        WindUI:Notify({ Title = "Server Hop", Content = "Max retries reached. Try again later.", Duration = 3 })
    end
})

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

game.Players.PlayerAdded:Connect(CreatePlayerDropdown)
game.Players.PlayerRemoving:Connect(CreatePlayerDropdown)