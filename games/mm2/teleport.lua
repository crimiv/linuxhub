local WindUI = LinuxHub.WindUI

local TeleportTab = LinuxHub.Window:Tab({ Title = "Teleport" })

local function TeleportToLobby()
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then
        WindUI:Notify({ Title = "Error", Content = "Local player not found", Duration = 2 })
        return
    end
    local character = localPlayer.Character
    if not character then
        WindUI:Notify({ Title = "Error", Content = "Character not found", Duration = 2 })
        return
    end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        WindUI:Notify({ Title = "Error", Content = "HumanoidRootPart not found", Duration = 2 })
        return
    end
    local lobby = workspace:FindFirstChild("RegularLobby")
    if not lobby then
        WindUI:Notify({ Title = "Error", Content = "RegularLobby not found", Duration = 2 })
        return
    end
    local parts = lobby:GetDescendants()
    for _, part in ipairs(parts) do
        if part:IsA("BasePart") then
            rootPart.CFrame = part.CFrame
            WindUI:Notify({ Title = "Teleport", Content = "Teleported to lobby", Duration = 2 })
            return
        end
    end
    WindUI:Notify({ Title = "Error", Content = "No BasePart found in lobby", Duration = 2 })
end

local function TeleportToCurrentMap()
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then
        WindUI:Notify({ Title = "Error", Content = "Local player not found", Duration = 2 })
        return
    end
    local character = localPlayer.Character
    if not character then
        WindUI:Notify({ Title = "Error", Content = "Character not found", Duration = 2 })
        return
    end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        WindUI:Notify({ Title = "Error", Content = "HumanoidRootPart not found", Duration = 2 })
        return
    end
    local currentMapContainer = nil
    if currentMap then
        local map = workspace:FindFirstChild(currentMap)
        if map then
            currentMapContainer = map:FindFirstChild("CoinContainer")
            if not currentMapContainer then
                currentMapContainer = map
            end
        end
    end
    if not currentMapContainer then
        local mapNames = {"House2", "BioLab", "Office3", "Hospital3", "Factory", "MilBase", "Bank2", "Hotel2", "Mansion2", "PoliceStation", "ResearchFacility", "Workplace"}
        for _, name in ipairs(mapNames) do
            local map = workspace:FindFirstChild(name)
            if map then
                local coinContainer = map:FindFirstChild("CoinContainer")
                if coinContainer then
                    currentMapContainer = coinContainer
                    break
                else
                    currentMapContainer = map
                end
            end
        end
    end
    if not currentMapContainer then
        WindUI:Notify({ Title = "Error", Content = "Could not find current map", Duration = 2 })
        return
    end
    local targetPart = nil
    if currentMapContainer:IsA("BasePart") then
        targetPart = currentMapContainer
    else
        local parts = currentMapContainer:GetDescendants()
        for _, part in ipairs(parts) do
            if part:IsA("BasePart") then
                targetPart = part
                break
            end
        end
        if not targetPart then
            local children = currentMapContainer:GetChildren()
            for _, child in ipairs(children) do
                if child:IsA("BasePart") then
                    targetPart = child
                    break
                end
            end
        end
    end
    if not targetPart then
        WindUI:Notify({ Title = "Error", Content = "No BasePart found in map", Duration = 2 })
        return
    end
    rootPart.CFrame = targetPart.CFrame
    WindUI:Notify({ Title = "Teleport", Content = "Teleported to current map", Duration = 2 })
end

TeleportTab:Button({
    Title = "Teleport to Lobby",
    Callback = function()
        TeleportToLobby()
    end
})

TeleportTab:Button({
    Title = "Teleport to Current Map",
    Callback = function()
        TeleportToCurrentMap()
    end
})