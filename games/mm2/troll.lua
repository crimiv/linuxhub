local WindUI = LinuxHub.WindUI
local utils = LinuxHub.Utils
local config = LinuxHub.Config

local TrollTab = LinuxHub.Window:Tab({ Title = "Troll" })

local function IsSeated(player)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and (hum.SeatPart or hum:GetState() == Enum.HumanoidStateType.Seated)
end

local function FlingPlayer(target, silent)
    if _G.LINUXHUB_UPDATING then return false end
    if not target or target == game.Players.LocalPlayer then
        if not silent then WindUI:Notify({ Title = "Fling", Content = "Invalid target", Duration = 2 }) end
        return false
    end
    local localPlayer = game.Players.LocalPlayer
    local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tChar = target.Character
    local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
    local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
    if not hrp or not tHrp or not tHum or tHum.Health <= 0 then
        if not silent then WindUI:Notify({ Title = "Fling", Content = "Target invalid or dead", Duration = 2 }) end
        return false
    end
    if IsSeated(target) then
        if not silent then WindUI:Notify({ Title = "Fling", Content = "Target is seated", Duration = 2 }) end
        return false
    end
    local originalFPDH = workspace.FallenPartsDestroyHeight
    workspace.FallenPartsDestroyHeight = 0/0
    local oldPos = hrp.CFrame
    local targetStartPos = tHrp.Position
    local launched = false
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, 1000000, 0)
    bv.MaxForce = Vector3.new(0, math.huge, 0)
    bv.Parent = hrp
    local bav = Instance.new("BodyAngularVelocity")
    bav.AngularVelocity = Vector3.new(1000000, 1000000, 1000000)
    bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bav.Parent = hrp
    local timeout = tick() + 3
    while tick() < timeout and not launched do
        if _G.LINUXHUB_UPDATING then break end
        if not target.Parent or tHum.Health <= 0 then break end
        hrp.CFrame = tHrp.CFrame
        if (tHrp.Position - targetStartPos).Magnitude > 60 or tHrp.Velocity.Magnitude > 180 then
            launched = true
            break
        end
        task.wait()
    end
    bv:Destroy()
    bav:Destroy()
    hrp.Velocity = Vector3.new(0,0,0)
    hrp.RotVelocity = Vector3.new(0,0,0)
    hrp.CFrame = oldPos
    workspace.FallenPartsDestroyHeight = originalFPDH
    if launched then
        if not silent then WindUI:Notify({ Title = "Fling", Content = "Flung " .. target.Name, Duration = 2 }) end
    else
        if not silent then WindUI:Notify({ Title = "Fling", Content = "Failed to fling " .. target.Name, Duration = 2 }) end
    end
    return launched
end

TrollTab:Button({
    Title = "Fling Murderer",
    Callback = function()
        if _G.LINUXHUB_UPDATING then return end
        local murderer = LinuxHub.GetCurrentMurderer()
        if murderer then
            FlingPlayer(murderer, false)
        else
            WindUI:Notify({ Title = "Fling", Content = "No murderer found", Duration = 2 })
        end
    end
})

TrollTab:Button({
    Title = "Fling Sheriff",
    Callback = function()
        if _G.LINUXHUB_UPDATING then return end
        local sheriff = LinuxHub.GetCurrentSheriff()
        if sheriff then
            FlingPlayer(sheriff, false)
        else
            WindUI:Notify({ Title = "Fling", Content = "No sheriff found", Duration = 2 })
        end
    end
})

local autoFlingMurdererEnabled = LinuxHub.Toggles.autoFlingMurdererEnabled or false
local autoFlingSheriffEnabled = LinuxHub.Toggles.autoFlingSheriffEnabled or false
local autoFlingMurdererCoroutine = nil
local autoFlingSheriffCoroutine = nil

TrollTab:Toggle({
    Title = "Auto Fling Murderer",
    Value = autoFlingMurdererEnabled,
    Callback = function(state)
        autoFlingMurdererEnabled = state
        LinuxHub.Toggles.autoFlingMurdererEnabled = state
        if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
        WindUI:Notify({
            Title = "Auto Fling Murderer",
            Content = autoFlingMurdererEnabled and "Enabled" or "Disabled",
            Duration = 2,
        })
        if autoFlingMurdererEnabled then
            if autoFlingMurdererCoroutine then
                autoFlingMurdererCoroutine = nil
            end
            autoFlingMurdererCoroutine = coroutine.create(function()
                while autoFlingMurdererEnabled do
                    if _G.LINUXHUB_UPDATING then break end
                    local target = LinuxHub.GetCurrentMurderer()
                    if target then
                        local launched = FlingPlayer(target, true)
                        if launched then
                            task.wait(0.5)
                        else
                            task.wait(0.1)
                        end
                    else
                        task.wait(0.5)
                    end
                end
            end)
            coroutine.resume(autoFlingMurdererCoroutine)
        else
            if autoFlingMurdererCoroutine then
                autoFlingMurdererCoroutine = nil
            end
        end
    end
})

TrollTab:Toggle({
    Title = "Auto Fling Sheriff",
    Value = autoFlingSheriffEnabled,
    Callback = function(state)
        autoFlingSheriffEnabled = state
        LinuxHub.Toggles.autoFlingSheriffEnabled = state
        if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
        WindUI:Notify({
            Title = "Auto Fling Sheriff",
            Content = autoFlingSheriffEnabled and "Enabled" or "Disabled",
            Duration = 2,
        })
        if autoFlingSheriffEnabled then
            if autoFlingSheriffCoroutine then
                autoFlingSheriffCoroutine = nil
            end
            autoFlingSheriffCoroutine = coroutine.create(function()
                while autoFlingSheriffEnabled do
                    if _G.LINUXHUB_UPDATING then break end
                    local target = LinuxHub.GetCurrentSheriff()
                    if target then
                        local launched = FlingPlayer(target, true)
                        if launched then
                            task.wait(0.5)
                        else
                            task.wait(0.1)
                        end
                    else
                        task.wait(0.5)
                    end
                end
            end)
            coroutine.resume(autoFlingSheriffCoroutine)
        else
            if autoFlingSheriffCoroutine then
                autoFlingSheriffCoroutine = nil
            end
        end
    end
})

local selectedFlingPlayer = nil
local flingDropdown = nil

local function GetPlayerNamesForFling()
    local names = {}
    local localPlayer = game.Players.LocalPlayer
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= localPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

local function CreateFlingDropdown()
    if flingDropdown then
        flingDropdown:Destroy()
        flingDropdown = nil
    end
    local playerNames = GetPlayerNamesForFling()
    if #playerNames == 0 then
        playerNames = {"No other players"}
        selectedFlingPlayer = nil
    else
        selectedFlingPlayer = playerNames[1]
    end
    flingDropdown = TrollTab:Dropdown({
        Title = "Select Player to Fling",
        Values = playerNames,
        Default = playerNames[1] or "No other players",
        Callback = function(value)
            selectedFlingPlayer = value
        end
    })
end

CreateFlingDropdown()

TrollTab:Button({
    Title = "Refresh Players",
    Callback = function()
        if _G.LINUXHUB_UPDATING then return end
        CreateFlingDropdown()
        WindUI:Notify({ Title = "Fling Player", Content = "Player list refreshed", Duration = 2 })
    end
})

TrollTab:Button({
    Title = "Fling Selected Player",
    Callback = function()
        if _G.LINUXHUB_UPDATING then return end
        if not selectedFlingPlayer or selectedFlingPlayer == "No other players" then
            WindUI:Notify({ Title = "Error", Content = "No valid player selected", Duration = 2 })
            return
        end
        local targetPlayer = game.Players:FindFirstChild(selectedFlingPlayer)
        if not targetPlayer then
            WindUI:Notify({ Title = "Error", Content = "Selected player not found", Duration = 2 })
            return
        end
        task.spawn(function()
            while targetPlayer and targetPlayer.Parent do
                if _G.LINUXHUB_UPDATING then break end
                local launched = FlingPlayer(targetPlayer, true)
                if launched then
                    break
                end
                task.wait(0.5)
            end
        end)
    end
})

local loopFlingSelectedEnabled = LinuxHub.Toggles.loopFlingSelectedEnabled or false
local loopFlingSelectedCoroutine = nil

TrollTab:Toggle({
    Title = "Loop Fling Selected Player",
    Value = loopFlingSelectedEnabled,
    Callback = function(state)
        loopFlingSelectedEnabled = state
        LinuxHub.Toggles.loopFlingSelectedEnabled = state
        if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
        WindUI:Notify({
            Title = "Loop Fling Selected Player",
            Content = loopFlingSelectedEnabled and "Enabled" or "Disabled",
            Duration = 2,
        })
        if loopFlingSelectedEnabled then
            if loopFlingSelectedCoroutine then
                loopFlingSelectedCoroutine = nil
            end
            loopFlingSelectedCoroutine = coroutine.create(function()
                while loopFlingSelectedEnabled do
                    if _G.LINUXHUB_UPDATING then break end
                    if selectedFlingPlayer and selectedFlingPlayer ~= "No other players" then
                        local targetPlayer = game.Players:FindFirstChild(selectedFlingPlayer)
                        if targetPlayer then
                            local launched = FlingPlayer(targetPlayer, true)
                            if launched then
                                task.wait(0.5)
                            else
                                task.wait(0.1)
                            end
                        else
                            task.wait(0.5)
                        end
                    else
                        task.wait(0.5)
                    end
                end
            end)
            coroutine.resume(loopFlingSelectedCoroutine)
        else
            if loopFlingSelectedCoroutine then
                loopFlingSelectedCoroutine = nil
            end
        end
    end
})

game.Players.PlayerAdded:Connect(CreateFlingDropdown)
game.Players.PlayerRemoving:Connect(CreateFlingDropdown)

LinuxHub.DisableAll = function()
    autoFlingMurdererEnabled = false
    LinuxHub.Toggles.autoFlingMurdererEnabled = false
    autoFlingSheriffEnabled = false
    LinuxHub.Toggles.autoFlingSheriffEnabled = false
    loopFlingSelectedEnabled = false
    LinuxHub.Toggles.loopFlingSelectedEnabled = false
    if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
    if autoFlingMurdererCoroutine then
        autoFlingMurdererCoroutine = nil
    end
    if autoFlingSheriffCoroutine then
        autoFlingSheriffCoroutine = nil
    end
    if loopFlingSelectedCoroutine then
        loopFlingSelectedCoroutine = nil
    end
end
