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
    local function GetCharacterMass(char)
        local mass = 0
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                local ok, m = pcall(function() return part:GetMass() end)
                if ok and type(m) == "number" then
                    mass = mass + m
                else
                    mass = mass + (part.Size.X * part.Size.Y * part.Size.Z)
                end
            end
        end
        return mass
    end

    local function ChooseFlingParams(localChar)
        local hum = localChar and localChar:FindFirstChildOfClass("Humanoid")
        local rig = hum and hum.RigType or Enum.HumanoidRigType.R15
        local mass = GetCharacterMass(localChar)
        local accessoryCount = 0
        for _, v in ipairs(localChar:GetChildren()) do
            if v:IsA("Accessory") then accessoryCount = accessoryCount + 1 end
        end
        -- Base velocity scales with mass and accessories (more accessories -> heavier)
        local velocity = 300 + (mass * 8) + (accessoryCount * 40)
        if rig == Enum.HumanoidRigType.R6 then
            velocity = velocity * 0.9
        else
            velocity = velocity * 1.1
        end
        local angular = math.clamp(200 + (mass * 30) + (accessoryCount * 20), 1000, 1000000)
        local maxForceY = math.max(1e5, mass * 8e3)
        return velocity, angular, maxForceY
    end

    local function OptimizeMovementParams(localChar, tHrp, targetStartPos)
        local mass = GetCharacterMass(localChar)
        local accessoryCount = 0
        for _, v in ipairs(localChar:GetChildren()) do
            if v:IsA("Accessory") then accessoryCount = accessoryCount + 1 end
        end
        local baseAmp = 1 + (accessoryCount * 0.5)
        local baseFreq = 6
        local candidates = {}
        for _, aScale in ipairs({0.7, 1, 1.4}) do
            for _, fScale in ipairs({0.7, 1, 1.4}) do
                table.insert(candidates, { amp = baseAmp * aScale, freq = baseFreq * fScale })
            end
        end
        local best = candidates[1]
        local bestScore = -math.huge
        local originalPos = hrp and hrp.CFrame
        for _, cand in ipairs(candidates) do
            local start = tick()
            local stop = start + 0.12
            local peak = 0
            while tick() < stop do
                local t = tick() - start
                local x = math.sin(t * cand.freq * 2) * cand.amp
                local y = math.abs(math.sin(t * cand.freq * 1.2)) * (2 + mass * 0.02)
                local z = math.cos(t * cand.freq * 1.4) * (cand.amp * 0.6)
                local ok = pcall(function()
                    if hrp and tHrp then
                        hrp.CFrame = tHrp.CFrame * CFrame.new(Vector3.new(x, y, z))
                    end
                end)
                if tHrp then
                    peak = math.max(peak, tHrp.Velocity.Magnitude, (tHrp.Position - targetStartPos).Magnitude)
                end
                task.wait(0.02)
            end
            if peak > bestScore then
                bestScore = peak
                best = cand
            end
        end
        if originalPos and hrp then hrp.CFrame = originalPos end
        return best
    end

    local function ChooseFlingMovement(localChar, bestParams)
        local hum = localChar and localChar:FindFirstChildOfClass("Humanoid")
        local rig = hum and hum.RigType or Enum.HumanoidRigType.R15
        local mass = GetCharacterMass(localChar)
        local accessoryCount = 0
        for _, v in ipairs(localChar:GetChildren()) do
            if v:IsA("Accessory") then accessoryCount = accessoryCount + 1 end
        end
        -- Tunable factors derived from avatar properties
        local massFactor = mass / 50
        local accessoryFactor = accessoryCount / 4
        local baseAmp = math.clamp(1 + accessoryFactor * 2 + massFactor * 1.5, 0.5, 14)
        local baseFreq = math.clamp(6 - massFactor * 1.2 - accessoryFactor * 0.6, 1.2, 14)
        local verticalScale = math.clamp(2 + massFactor * 3 + accessoryFactor * 1.2, 1, 30)
        -- Slight adjustments per rig
        if rig == Enum.HumanoidRigType.R6 then
            baseAmp = baseAmp * 1.15
            baseFreq = math.max(1.2, baseFreq * 1.05)
            verticalScale = verticalScale * 1.25
        else
            baseAmp = baseAmp * 1.0
            baseFreq = baseFreq * 1.0
        end

        -- Select movement pattern, tuned with computed amp/freq/verticalScale
        if accessoryCount >= 6 or mass > 120 then
            return function(startTime)
                local t = tick() - startTime
                local amp = baseAmp * 1.2
                local freq = baseFreq * 0.85
                local x = math.sin(t * freq * 2) * amp
                local y = math.abs(math.sin(t * freq * 1.2)) * verticalScale
                local z = math.cos(t * freq * 1.4) * (amp * 0.6)
                return Vector3.new(x, y, z)
            end
        end

        if rig == Enum.HumanoidRigType.R6 then
            return function(startTime)
                local t = tick() - startTime
                local freq = baseFreq * 2.0
                local y = math.sin(t * freq) * verticalScale * 1.2
                local x = math.sin(t * (freq * 0.8)) * (baseAmp * 0.6)
                return Vector3.new(x, y, 0)
            end
        end

        return function(startTime)
            local t = tick() - startTime
            local amp = baseAmp
            local freq = baseFreq
            local x = math.sin(t * freq * 1.3) * amp
            local y = math.abs(math.sin(t * freq * 0.95)) * verticalScale
            local z = math.cos(t * freq * 0.9) * (amp * 0.7)
            return Vector3.new(x, y, z)
        end
    end

    local originalFPDH = workspace.FallenPartsDestroyHeight
    workspace.FallenPartsDestroyHeight = 0/0
    local oldPos = hrp.CFrame
    local targetStartPos = tHrp.Position
    local launched = false
    local velocityY, angularMag, maxForceY = ChooseFlingParams(localPlayer.Character)
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, velocityY, 0)
    bv.MaxForce = Vector3.new(0, maxForceY, 0)
    bv.Parent = hrp
    local bav = Instance.new("BodyAngularVelocity")
    bav.AngularVelocity = Vector3.new(angularMag, angularMag, angularMag)
    bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bav.Parent = hrp
    local bestParams = OptimizeMovementParams(localPlayer.Character, tHrp, targetStartPos)
    local movementFunc = ChooseFlingMovement(localPlayer.Character, bestParams)
    local startTime = tick()
    local timeout = startTime + 3
    while tick() < timeout and not launched do
        if _G.LINUXHUB_UPDATING then break end
        if not target.Parent or tHum.Health <= 0 then break end
        local offset = Vector3.new(0,0,0)
        if movementFunc then
            local ok, off = pcall(function() return movementFunc(startTime) end)
            if ok and typeof(off) == "Vector3" then
                offset = off
            end
        end
        local insideOffset = Vector3.new(offset.X * 0.2, math.clamp(offset.Y * 0.4, -1.5, 1.5), offset.Z * 0.2)
        local roll = CFrame.Angles(math.rad(offset.X * 10), math.rad(offset.Y * 10), math.rad(offset.Z * 10))
        hrp.CFrame = tHrp.CFrame * CFrame.new(insideOffset) * roll
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