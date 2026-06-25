local WindUI = LinuxHub.WindUI
local utils = LinuxHub.Utils
local config = LinuxHub.Config

local CombatTab = LinuxHub.Window:Tab({ Title = "Combat" })

local Config = {
    Enabled = LinuxHub.Toggles.silentAimEnabled or false,
    Distance = 30,
    TargetMode = "cursor",
}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local targetPosition = nil

local function updateTarget()
    if _G.LINUXHUB_UPDATING then
        targetPosition = nil
        return
    end
    if not Config.Enabled then
        targetPosition = nil
        return
    end

    local referencePos

    if Config.TargetMode == "cursor" then
        referencePos = UserInputService:GetMouseLocation()
    else
        referencePos = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    end

    if not referencePos then
        return
    end

    local closestPart = nil
    local minScreenDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local char = player.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local targetPart = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
                    if targetPart then
                        local worldDist = (targetPart.Position - camera.CFrame.Position).Magnitude
                        if worldDist <= Config.Distance then
                            local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                            if onScreen then
                                local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                                local screenDist = (screenVec - referencePos).Magnitude
                                if screenDist < minScreenDist then
                                    minScreenDist = screenDist
                                    closestPart = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if closestPart then
        targetPosition = closestPart.Position
    else
        targetPosition = nil
    end
end

local oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    if _G.LINUXHUB_UPDATING then return oldNamecall(self, ...) end
    local method = getnamecallmethod()
    if Config.Enabled and targetPosition and self == Workspace and method == "Raycast" then
        local args = { ... }
        if typeof(args[1]) == "Vector3" then
            local origin = args[1]
            local newDir = (targetPosition - origin).Unit * Config.Distance
            args[2] = newDir
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end))

RunService.RenderStepped:Connect(updateTarget)

CombatTab:Toggle({
    Title = "Silent Aim",
    Value = Config.Enabled,
    Callback = function(state)
        Config.Enabled = state
        LinuxHub.Toggles.silentAimEnabled = state
        if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
        WindUI:Notify({
            Title = "Silent Aim",
            Content = Config.Enabled and "Enabled" or "Disabled",
            Duration = 2,
        })
    end
})

LinuxHub.DisableAll = function()
    Config.Enabled = false
    LinuxHub.Toggles.silentAimEnabled = false
    if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
    targetPosition = nil
end