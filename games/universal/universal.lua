local WindUI = LinuxHub.WindUI

-- Create one unified "Universal" tab and group admin/misc controls under it
local UniversalTab = LinuxHub.Window:CreateTab({
    Title = "Universal",
    Icon = "rbxassetid://11942428",
})

local function notify(title, content, duration)
    WindUI:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
    })
end

-- Admin controls
UniversalTab:Paragraph({
    Title = "Admin Tools",
    Content = "Load popular admin scripts. Use responsibly."
})

local function LoadAdmin(url)
    local success, result = pcall(function()
        if LinuxHub and LinuxHub.Network and LinuxHub.Network.Load then
            return LinuxHub.Network.Load(url)
        else
            return loadstring(game:HttpGet(url))()
        end
    end)
    if not success then
        notify("Admin: Load Failed", "Failed to load admin script. Check your connection.")
    else
        notify("Admin: Loaded", "Admin script executed successfully.")
    end
end

UniversalTab:Button({
    Title = "Load Nameless Admin",
    Callback = function()
        LoadAdmin("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua")
    end
})

UniversalTab:Button({
    Title = "Load Infinite Yield",
    Callback = function()
        LoadAdmin("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
    end
})

-- Misc controls
UniversalTab:Paragraph({
    Title = "Misc Tools",
    Content = "Utility scripts and small helpers."
})

local MiscTab = UniversalTab

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
        if LinuxHub and LinuxHub.Network and LinuxHub.Network.Load then
            return LinuxHub.Network.Load(url)
        else
            return loadstring(game:HttpGet(url))()
        end
    end)
    if not success then
        notify("Dex: Load Failed", "Failed to load Dex. Check your connection.")
    else
        notify("Dex: Loaded", "Dex loaded successfully.")
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
        if LinuxHub and LinuxHub.Network and LinuxHub.Network.Load then
            return LinuxHub.Network.Load(url)
        else
            return loadstring(game:HttpGetAsync(url))()
        end
    end)
    if not success then
        notify("Simple Spy: Load Failed", "Failed to load Simple Spy. Check your connection.")
    else
        notify("Simple Spy: Loaded", "Simple Spy loaded successfully.")
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
        if LinuxHub and LinuxHub.Network and LinuxHub.Network.Load then
            return LinuxHub.Network.Load(url)
        else
            return loadstring(game:HttpGetAsync(url))()
        end
    end)
    if not success then
        notify("Cobalt: Load Failed", "Failed to load Cobalt. Check your connection.")
    else
        notify("Cobalt: Loaded", "Cobalt loaded successfully.")
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
