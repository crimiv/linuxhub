local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local WindUI = LinuxHub.WindUI
local utils = LinuxHub.Utils
local config = LinuxHub.Config

local FarmTab = LinuxHub.Window:Tab({ Title = "Auto Farm" })

local scene = Workspace:FindFirstChild("Scene")
local beach = scene and scene:FindFirstChild("Beach")
local beachballs = beach and beach:FindFirstChild("Beachballs")
local goalsFolder = beach and beach:FindFirstChild("Goals")

local function getPosition(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        for _, part in ipairs(obj:GetDescendants()) do
            if part:IsA("BasePart") then return part.Position end
        end
    end
    return nil
end

local autoFarmEnabled = LinuxHub.Toggles.autoFarmEnabled or false
local loopTask = nil
local childAddedConn = nil
local isRunning = false

local function refreshPairs()
    local balls = {}
    local goals = {}
    if beachballs then
        for _, child in ipairs(beachballs:GetChildren()) do
            if string.find(string.lower(child.Name), "ball") then
                table.insert(balls, child)
            end
        end
    end
    if goalsFolder then
        for _, child in ipairs(goalsFolder:GetChildren()) do
            if string.find(string.lower(child.Name), "goal") then
                table.insert(goals, child)
            end
        end
    end
    table.sort(balls, function(a, b) return a.Name < b.Name end)
    table.sort(goals, function(a, b) return a.Name < b.Name end)
    local pairs = {}
    local count = math.min(#balls, #goals)
    for i = 1, count do
        table.insert(pairs, { ball = balls[i], goal = goals[i] })
    end
    return pairs
end

local function RideAndScore(ball, goalPos)
    if not ball or not goalPos then return false end
    local character = LocalPlayer.Character
    if not character then return false end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    local ballPos = getPosition(ball)
    if not ballPos then return false end
    if (ballPos - goalPos).Magnitude < 2 then return true end
    local tweenInfo1 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween1 = TweenService:Create(rootPart, tweenInfo1, { CFrame = CFrame.new(ballPos) })
    tween1:Play()
    tween1.Completed:Wait()
    local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    if ball:IsA("BasePart") then
        local tweenBall = TweenService:Create(ball, tweenInfo2, { CFrame = CFrame.new(goalPos) })
        local tweenPlayer = TweenService:Create(rootPart, tweenInfo2, { CFrame = CFrame.new(goalPos) })
        tweenBall:Play()
        tweenPlayer:Play()
        tweenBall.Completed:Wait()
    else
        if ball.PrimaryPart then
            local tweenBall = TweenService:Create(ball.PrimaryPart, tweenInfo2, { CFrame = CFrame.new(goalPos) })
            local tweenPlayer = TweenService:Create(rootPart, tweenInfo2, { CFrame = CFrame.new(goalPos) })
            tweenBall:Play()
            tweenPlayer:Play()
            tweenBall.Completed:Wait()
        else
            for _, part in ipairs(ball:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CFrame = CFrame.new(goalPos)
                end
            end
            local tweenPlayer = TweenService:Create(rootPart, tweenInfo2, { CFrame = CFrame.new(goalPos) })
            tweenPlayer:Play()
            tweenPlayer.Completed:Wait()
        end
    end
    return true
end

local function ScoreAll()
    local pairs = refreshPairs()
    for _, pair in ipairs(pairs) do
        if pair.ball and pair.goal then
            local goalPos = getPosition(pair.goal)
            if goalPos then
                RideAndScore(pair.ball, goalPos)
            end
        end
    end
end

local function ScoreBallByObject(ball)
    local pairs = refreshPairs()
    for _, pair in ipairs(pairs) do
        if pair.ball == ball then
            local goalPos = getPosition(pair.goal)
            if goalPos then
                task.wait(0.3)
                RideAndScore(ball, goalPos)
            end
            break
        end
    end
end

local function startAutoFarm()
    if isRunning then return end
    isRunning = true
    autoFarmEnabled = true
    LinuxHub.Toggles.autoFarmEnabled = true
    if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
    pcall(ScoreAll)
    loopTask = task.spawn(function()
        while isRunning do
            pcall(ScoreAll)
            task.wait(1)
        end
    end)
    if beachballs then
        childAddedConn = beachballs.ChildAdded:Connect(function(child)
            if isRunning and string.find(string.lower(child.Name), "ball") then
                ScoreBallByObject(child)
            end
        end)
    end
    WindUI:Notify({ Title = "Auto Farm", Content = "Enabled", Duration = 2 })
end

local function stopAutoFarm()
    isRunning = false
    autoFarmEnabled = false
    LinuxHub.Toggles.autoFarmEnabled = false
    if loopTask then task.cancel(loopTask); loopTask = nil end
    if childAddedConn then childAddedConn:Disconnect(); childAddedConn = nil end
    if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
    WindUI:Notify({ Title = "Auto Farm", Content = "Disabled", Duration = 2 })
end

FarmTab:Toggle({
    Title = "Auto Score Balls",
    Value = autoFarmEnabled,
    Callback = function(state)
        if state then startAutoFarm() else stopAutoFarm() end
    end
})

local freezeDemonKingEnabled = LinuxHub.Toggles.freezeDemonKingEnabled or false
local demonKingHeartbeatConn = nil
local isFrozen = false
local originalWalkSpeed = 16
local originalJumpPower = 50

local function getDemonKingCFrame()
    local npc = Workspace:FindFirstChild("NPC")
    if not npc then return nil end
    local demonKing = npc:FindFirstChild("DemonKing")
    if not demonKing then return nil end
    local demonKingModel = demonKing:FindFirstChild("DemonKing")
    if demonKingModel then
        local pos = getPosition(demonKingModel)
        if pos then return CFrame.new(pos) end
    end
    local pos = getPosition(demonKing)
    if pos then return CFrame.new(pos) end
    return nil
end

local function freezePlayerInsideDemonKing()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    local targetCFrame = getDemonKingCFrame()
    if not targetCFrame then return end

    rootPart.CFrame = targetCFrame
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
end

local function startFreezeDemonKing()
    if isFrozen then return end
    isFrozen = true
    freezeDemonKingEnabled = true
    LinuxHub.Toggles.freezeDemonKingEnabled = true

    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            originalWalkSpeed = humanoid.WalkSpeed
            originalJumpPower = humanoid.JumpPower
        end
    end

    demonKingHeartbeatConn = RunService.Heartbeat:Connect(function()
        if isFrozen then
            pcall(freezePlayerInsideDemonKing)
        end
    end)

    if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
    WindUI:Notify({ Title = "Freeze inside Demon King", Content = "Enabled", Duration = 2 })
end

local function stopFreezeDemonKing()
    isFrozen = false
    freezeDemonKingEnabled = false
    LinuxHub.Toggles.freezeDemonKingEnabled = false

    if demonKingHeartbeatConn then
        demonKingHeartbeatConn:Disconnect()
        demonKingHeartbeatConn = nil
    end

    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = originalWalkSpeed
            humanoid.JumpPower = originalJumpPower
        end
    end

    if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
    WindUI:Notify({ Title = "Freeze inside Demon King", Content = "Disabled", Duration = 2 })
end

FarmTab:Toggle({
    Title = "Freeze inside Demon King",
    Value = freezeDemonKingEnabled,
    Callback = function(state)
        if state then startFreezeDemonKing() else stopFreezeDemonKing() end
    end
})

LinuxHub.DisableAll = LinuxHub.DisableAll or function() end
local oldDisable = LinuxHub.DisableAll
LinuxHub.DisableAll = function()
    stopAutoFarm()
    stopFreezeDemonKing()
    oldDisable()
end
