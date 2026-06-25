local WindUI = AppleHub.WindUI

local MiscTab = AppleHub.Window:Tab({ Title = "Misc" })

local antiFlingEnabled = AppleHub.Toggles.antiFlingEnabled or false
local antiFlingVelocityThreshold = 150
local antiFlingConnection = nil

local function DestroyFlingBodyMovers(character)
    if not character then return end
    for _, child in ipairs(character:GetDescendants()) do
        if child:IsA("BodyVelocity") or child:IsA("BodyAngularVelocity") or child:IsA("BodyForce") or child:IsA("BodyGyro") or child:IsA("BodyPosition") or child:IsA("BodyThrust") then
            child:Destroy()
        end
    end
end

local function AntiFlingLoop()
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end
    local character = localPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    DestroyFlingBodyMovers(character)

    local velocity = rootPart.Velocity
    if velocity.Magnitude > antiFlingVelocityThreshold then
        rootPart.Velocity = Vector3.new(0, 0, 0)
        rootPart.RotVelocity = Vector3.new(0, 0, 0)
    end
end

local function SetupAntiFling()
    if antiFlingConnection then
        antiFlingConnection:Disconnect()
        antiFlingConnection = nil
    end
    if antiFlingEnabled then
        antiFlingConnection = game:GetService("RunService").Heartbeat:Connect(AntiFlingLoop)
    end
end

MiscTab:Toggle({
    Title = "Anti-Fling",
    Value = antiFlingEnabled,
    Callback = function(state)
        antiFlingEnabled = state
        AppleHub.Toggles.antiFlingEnabled = state
        if AppleHub.SaveSettings then AppleHub.SaveSettings() end
        WindUI:Notify({
            Title = "Anti-Fling",
            Content = antiFlingEnabled and "Enabled" or "Disabled",
            Duration = 2,
        })
        SetupAntiFling()
    end
})

AppleHub.DisableAll = function()
    antiFlingEnabled = false
    AppleHub.Toggles.antiFlingEnabled = false
    if AppleHub.SaveSettings then AppleHub.SaveSettings() end
    if antiFlingConnection then
        antiFlingConnection:Disconnect()
        antiFlingConnection = nil
    end
end