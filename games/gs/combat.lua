local WindUI = LinuxHub.WindUI
local utils = LinuxHub.Utils
local config = LinuxHub.Config

local CombatTab = LinuxHub.Window:Tab({ Title = "Combat" })

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AeroServices = ReplicatedStorage:WaitForChild("Aero"):WaitForChild("AeroRemoteServices"):WaitForChild("GameService")

local AttackStart = AeroServices:WaitForChild("WeaponAttackStart")
local AnimComplete = AeroServices:WaitForChild("WeaponAnimComplete")

local function SwingWeapon(silent)
    if _G.LINUXHUB_UPDATING then return end
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then
        if not silent then WindUI:Notify({ Title = "Error", Content = "Local player not found", Duration = 2 }) end
        return
    end
    local character = localPlayer.Character
    if not character then
        if not silent then WindUI:Notify({ Title = "Error", Content = "Character not found", Duration = 2 }) end
        return
    end
    AttackStart:FireServer()
    AnimComplete:FireServer()
    if typeof(getNil) == "function" then
        pcall(function()
            getNil("Event", "BindableEvent"):Fire()
        end)
    end
    if not silent then
        WindUI:Notify({ Title = "Swing", Content = "Weapon swung!", Duration = 2 })
    end
end

CombatTab:Button({
    Title = "Swing Weapon",
    Callback = function()
        SwingWeapon(false)
    end
})

local autoSwingEnabled = LinuxHub.Toggles.AutoSwing or false
local AUTO_SWING_COOLDOWN = config.cooldowns and config.cooldowns.autoSwing or 0.1
local lastAutoSwingTime = 0

local function AutoSwingLoop()
    if _G.LINUXHUB_UPDATING then return end
    if not autoSwingEnabled then return end
    local now = tick()
    if now - lastAutoSwingTime >= AUTO_SWING_COOLDOWN then
        lastAutoSwingTime = now
        pcall(function() SwingWeapon(true) end)
    end
end

game:GetService("RunService").Heartbeat:Connect(function()
    AutoSwingLoop()
end)

CombatTab:Toggle({
    Title = "Auto Swing",
    Value = autoSwingEnabled,
    Callback = function(state)
        autoSwingEnabled = state
        LinuxHub.Toggles.AutoSwing = state
        if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
        WindUI:Notify({
            Title = "Auto Swing",
            Content = autoSwingEnabled and "Enabled" or "Disabled",
            Duration = 2,
        })
        if autoSwingEnabled then
            lastAutoSwingTime = tick()
        end
    end
})

LinuxHub.DisableAll = function()
    autoSwingEnabled = false
    LinuxHub.Toggles.AutoSwing = false
    if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
end
