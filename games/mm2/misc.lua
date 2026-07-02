local WindUI = BanditHub.WindUI
local utils = BanditHub.Utils

local MiscTab = BanditHub.Window:Tab({ Title = "Misc" })

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
        local murderer = BanditHub.GetCurrentMurderer()
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
        local sheriff = BanditHub.GetCurrentSheriff()
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
        local murderer = BanditHub.GetCurrentMurderer()
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
        local sheriff = BanditHub.GetCurrentSheriff()
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
        -- Keep trying until we find a server that's not too small.
        -- (This is client-side retries; the actual availability is server-dependent.)
        local maxAttempts = 30
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

        -- If we didn't fetch any suitable servers, keep refetching until we either
        -- find one that meets the minPlayers threshold or we hit maxAttempts.
        while attempts < maxAttempts do
            if not candidates or #candidates == 0 then
                candidates = fetchServers()
                if candidates and #candidates > 0 then
                    -- continue with teleport attempts
                else
                    attempts = attempts + 1
                    task.wait(1)
                    continue
                end
            end
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
                    WindUI:Notify({ Title = "Server Hop", Content = "Server full, trying another... (" .. attempts .. "/" .. maxAttempts .. ")", Duration = 2 })
                else
                    WindUI:Notify({ Title = "Error", Content = "Failed to teleport: " .. errStr, Duration = 3 })
                    return
                end
            end
        end

        WindUI:Notify({ Title = "Server Hop", Content = "Max retries reached. Try again later.", Duration = 3 })
    end
})

MiscTab:Button({
    Title = "Rejoin Server",
    Callback = function()
        local placeId = game.PlaceId
        local jobId = game.JobId
        if not placeId or not jobId then
            WindUI:Notify({ Title = "Error", Content = "Could not get PlaceId or JobId", Duration = 2 })
            return
        end
        
        local TeleportService = game:GetService("TeleportService")
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId, game.Players.LocalPlayer)
        end)
        
        if success then
            WindUI:Notify({ Title = "Rejoin", Content = "Rejoining server...", Duration = 2 })
        else
            WindUI:Notify({ Title = "Error", Content = "Failed to rejoin: " .. tostring(err), Duration = 3 })
        end
    end
})

local antiFlingEnabled = BanditHub.Toggles.antiFlingEnabled or false
local antiFlingHeartbeat = nil

local function AntiFlingLoop()
    if not antiFlingEnabled then return end
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end
    local localChar = localPlayer.Character
    if not localChar then return end

    for _, player in ipairs(game.Players:GetPlayers()) do
        if player == localPlayer then continue end
        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            pcall(function()
                root.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0, 0, 0, 0)
                root.Velocity = Vector3.new(0, 0, 0)
                root.RotVelocity = Vector3.new(0, 0, 0)
                root.CanCollide = false
            end)
        end
    end

    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    if localRoot then
        if localRoot.Velocity.Magnitude > 150 then
            localRoot.Velocity = Vector3.new(0, 0, 0)
            localRoot.RotVelocity = Vector3.new(0, 0, 0)
        end
        for _, child in ipairs(localChar:GetDescendants()) do
            if child:IsA("BodyVelocity") or child:IsA("BodyAngularVelocity") or child:IsA("BodyForce") or child:IsA("BodyGyro") or child:IsA("BodyPosition") or child:IsA("BodyThrust") then
                child:Destroy()
            end
        end
    end
end

local function SetupAntiFling()
    if antiFlingHeartbeat then
        antiFlingHeartbeat:Disconnect()
        antiFlingHeartbeat = nil
    end
    if antiFlingEnabled then
        antiFlingHeartbeat = game:GetService("RunService").Heartbeat:Connect(AntiFlingLoop)
    end
end

MiscTab:Toggle({
    Title = "Anti-Fling",
    Value = antiFlingEnabled,
    Callback = function(state)
        antiFlingEnabled = state
        BanditHub.Toggles.antiFlingEnabled = state
        if BanditHub.SaveSettings then BanditHub.SaveSettings() end
        WindUI:Notify({
            Title = "Anti-Fling",
            Content = antiFlingEnabled and "Enabled" or "Disabled",
            Duration = 2,
        })
        SetupAntiFling()
    end
})

game.Players.PlayerAdded:Connect(CreatePlayerDropdown)
game.Players.PlayerRemoving:Connect(CreatePlayerDropdown)

BanditHub.DisableAll = function()
    antiFlingEnabled = false
    BanditHub.Toggles.antiFlingEnabled = false
    if BanditHub.SaveSettings then BanditHub.SaveSettings() end
    if antiFlingHeartbeat then
        antiFlingHeartbeat:Disconnect()
        antiFlingHeartbeat = nil
    end
end