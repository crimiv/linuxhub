local WindUI = LinuxHub.WindUI

local MiscTab = LinuxHub.Window:Tab({ Title = "Misc" })

local antiFlingEnabled = LinuxHub.Toggles.antiFlingEnabled or false
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
        LinuxHub.Toggles.antiFlingEnabled = state
        if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
        WindUI:Notify({
            Title = "Anti-Fling",
            Content = antiFlingEnabled and "Enabled" or "Disabled",
            Duration = 2,
        })
        SetupAntiFling()
    end
})

local function LoadDex(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        WindUI:Notify({
            Title = "Error",
            Content = "Failed to load Dex. Check your connection.",
            Duration = 4,
        })
    else
        WindUI:Notify({
            Title = "Dex Loaded",
            Content = "Dex loaded successfully.",
            Duration = 3,
        })
    end
end

MiscTab:Button({
    Title = "Load Dex",
    Callback = function()
        LoadDex("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/DexByMoonMobile")
    end
})

local function LoadSimpleSpy(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGetAsync(url))()
    end)
    if not success then
        WindUI:Notify({
            Title = "Error",
            Content = "Failed to load Simple Spy. Check your connection.",
            Duration = 4,
        })
    else
        WindUI:Notify({
            Title = "Simple Spy Loaded",
            Content = "Simple Spy loaded successfully.",
            Duration = 3,
        })
    end
end

MiscTab:Button({
    Title = "Load Simple Spy",
    Callback = function()
        LoadSimpleSpy("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/SimpleSpyRework.luau")
    end
})

local function LoadCobalt(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGetAsync(url))()
    end)
    if not success then
        WindUI:Notify({
            Title = "Error",
            Content = "Failed to load Cobalt. Check your connection.",
            Duration = 4,
        })
    else
        WindUI:Notify({
            Title = "Cobalt Loaded",
            Content = "Cobalt loaded successfully.",
            Duration = 3,
        })
    end
end

MiscTab:Button({
    Title = "Load Cobalt",
    Callback = function()
        LoadCobalt("https://github.com/notpoiu/cobalt/releases/latest/download/Cobalt.luau")
    end
})

LinuxHub.DisableAll = function()
    antiFlingEnabled = false
    LinuxHub.Toggles.antiFlingEnabled = false
    if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
    if antiFlingHeartbeat then
        antiFlingHeartbeat:Disconnect()
        antiFlingHeartbeat = nil
    end
end
