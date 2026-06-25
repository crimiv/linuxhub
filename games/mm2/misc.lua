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
            utils.Notify({ Title = "Error", Content = "Local player not found", Duration = 2 })
            return
        end
        if not selectedPlayerName or selectedPlayerName == "No other players" then
            utils.Notify({ Title = "Error", Content = "No valid player selected", Duration = 2 })
            return
        end
        local targetPlayer = game.Players:FindFirstChild(selectedPlayerName)
        if not targetPlayer then
            utils.Notify({ Title = "Error", Content = "Selected player not found", Duration = 2 })
            return
        end
        local targetCharacter = targetPlayer.Character
        if not targetCharacter then
            utils.Notify({ Title = "Error", Content = "Selected player has no character", Duration = 2 })
            return
        end
        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            utils.Notify({ Title = "Error", Content = "Selected player has no HumanoidRootPart", Duration = 2 })
            return
        end
        local localCharacter = localPlayer.Character
        if not localCharacter then
            utils.Notify({ Title = "Error", Content = "Your character not found", Duration = 2 })
            return
        end
        local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
        if not localRoot then
            utils.Notify({ Title = "Error", Content = "Your HumanoidRootPart not found", Duration = 2 })
            return
        end
        localRoot.CFrame = targetRoot.CFrame
        utils.Notify({ Title = "Misc", Content = "Teleported to " .. targetPlayer.Name, Duration = 2 })
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
        utils.Notify({ Title = "Error", Content = "Failed to send chat message", Duration = 2 })
    end
end

MiscTab:Button({
    Title = "Expose Murderer",
    Callback = function()
        local murderer = AppleHub.GetCurrentMurderer()
        if murderer then
            SendChatMessage("Murderer is " .. murderer.Name)
            utils.Notify({ Title = "Expose", Content = "Murderer exposed in chat", Duration = 2 })
        else
            utils.Notify({ Title = "Expose", Content = "No murderer found", Duration = 2 })
        end
    end
})

MiscTab:Button({
    Title = "Expose Sheriff",
    Callback = function()
        local sheriff = AppleHub.GetCurrentSheriff()
        if sheriff then
            SendChatMessage("Sheriff is " .. sheriff.Name)
            utils.Notify({ Title = "Expose", Content = "Sheriff exposed in chat", Duration = 2 })
        else
            utils.Notify({ Title = "Expose", Content = "No sheriff found", Duration = 2 })
        end
    end
})

MiscTab:Button({
    Title = "Teleport to Murderer",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        if not localPlayer then
            utils.Notify({ Title = "Error", Content = "Local player not found", Duration = 2 })
            return
        end
        local murderer = AppleHub.GetCurrentMurderer()
        if not murderer then
            utils.Notify({ Title = "Error", Content = "No murderer found", Duration = 2 })
            return
        end
        local targetCharacter = murderer.Character
        if not targetCharacter then
            utils.Notify({ Title = "Error", Content = "Murderer has no character", Duration = 2 })
            return
        end
        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            utils.Notify({ Title = "Error", Content = "Murderer has no HumanoidRootPart", Duration = 2 })
            return
        end
        local localCharacter = localPlayer.Character
        if not localCharacter then
            utils.Notify({ Title = "Error", Content = "Your character not found", Duration = 2 })
            return
        end
        local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
        if not localRoot then
            utils.Notify({ Title = "Error", Content = "Your HumanoidRootPart not found", Duration = 2 })
            return
        end
        localRoot.CFrame = targetRoot.CFrame
        utils.Notify({ Title = "Misc", Content = "Teleported to murderer", Duration = 2 })
    end
})

MiscTab:Button({
    Title = "Teleport to Sheriff",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        if not localPlayer then
            utils.Notify({ Title = "Error", Content = "Local player not found", Duration = 2 })
            return
        end
        local sheriff = AppleHub.GetCurrentSheriff()
        if not sheriff then
            utils.Notify({ Title = "Error", Content = "No sheriff found", Duration = 2 })
            return
        end
        local targetCharacter = sheriff.Character
        if not targetCharacter then
            utils.Notify({ Title = "Error", Content = "Sheriff has no character", Duration = 2 })
            return
        end
        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not targetRoot then
            utils.Notify({ Title = "Error", Content = "Sheriff has no HumanoidRootPart", Duration = 2 })
            return
        end
        local localCharacter = localPlayer.Character
        if not localCharacter then
            utils.Notify({ Title = "Error", Content = "Your character not found", Duration = 2 })
            return
        end
        local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
        if not localRoot then
            utils.Notify({ Title = "Error", Content = "Your HumanoidRootPart not found", Duration = 2 })
            return
        end
        localRoot.CFrame = targetRoot.CFrame
        utils.Notify({ Title = "Misc", Content = "Teleported to sheriff", Duration = 2 })
    end
})

game.Players.PlayerAdded:Connect(CreatePlayerDropdown)
game.Players.PlayerRemoving:Connect(CreatePlayerDropdown)