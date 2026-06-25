local WindUI = (function()
    local url = "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
    local raw = game:HttpGet(url)
    local patched = raw:gsub(
        'IconLabelFrame = New%( "ImageLabel", %{',
        'IconLabelFrame = New( "Frame", {'
    )
    return loadstring(patched)()
end)()

WindUI:AddTheme({
    Name = "Silver",
    Primary = Color3.fromHex("#a1a1aa"),
    White = Color3.new(1,1,1),
    Black = Color3.new(0,0,0),
    Dialog = Color3.fromHex("#2a2a2a"),
    Background = Color3.fromHex("#1a1a1a"),
    BackgroundTransparency = 0,
    Hover = Color3.fromHex("#d4d4d4"),
    PanelBackground = Color3.new(1,1,1),
    PanelBackgroundTransparency = .95,
    WindowBackground = Color3.fromHex("#1a1a1a"),
    WindowShadow = Color3.new(0,0,0),
    WindowTopbarTitle = Color3.fromHex("#ffffff"),
    WindowTopbarAuthor = Color3.fromHex("#c0c0c0"),
    WindowTopbarIcon = Color3.fromHex("#c0c0c0"),
    WindowTopbarButtonIcon = Color3.fromHex("#c0c0c0"),
    WindowSearchBarBackground = Color3.fromHex("#1a1a1a"),
    TabBackground = Color3.fromHex("#ffffff"),
    TabBackgroundHover = Color3.fromHex("#ffffff"),
    TabBackgroundHoverTransparency = .97,
    TabBackgroundActive = Color3.fromHex("#ffffff"),
    TabBackgroundActiveTransparency = 0.93,
    TabText = Color3.fromHex("#ffffff"),
    TabTextTransparency = 0.3,
    TabTextTransparencyActive = 0,
    TabTitle = Color3.fromHex("#ffffff"),
    TabIcon = Color3.fromHex("#c0c0c0"),
    TabIconTransparency = 0.4,
    TabIconTransparencyActive = 0.1,
    TabBorderTransparency = 1,
    TabBorderTransparencyActive = 0.75,
    TabBorder = Color3.new(1,1,1),
    ElementBackground = Color3.fromHex("#ffffff"),
    ElementBackgroundTransparency = .93,
    ElementBackgroundHover = WindUI.Creator:AddColor("ElementBackground", "#ffffff", 1/10),
    ElementTitle = Color3.fromHex("#ffffff"),
    ElementDesc = Color3.fromHex("#c0c0c0"),
    ElementIcon = Color3.fromHex("#c0c0c0"),
    PopupBackground = Color3.fromHex("#1a1a1a"),
    PopupBackgroundTransparency = "BackgroundTransparency",
    PopupTitle = Color3.fromHex("#ffffff"),
    PopupContent = Color3.fromHex("#ffffff"),
    PopupIcon = Color3.fromHex("#c0c0c0"),
    DialogBackground = Color3.fromHex("#1a1a1a"),
    DialogBackgroundTransparency = "BackgroundTransparency",
    DialogTitle = Color3.fromHex("#ffffff"),
    DialogContent = Color3.fromHex("#ffffff"),
    DialogIcon = Color3.fromHex("#c0c0c0"),
    Toggle = Color3.fromHex("#4a4a4a"),
    ToggleBar = Color3.new(1,1,1),
    Checkbox = Color3.fromHex("#c0c0c0"),
    CheckboxIcon = Color3.new(1,1,1),
    CheckboxBorder = Color3.new(1,1,1),
    CheckboxBorderTransparency = .75,
    SliderIcon = Color3.fromHex("#c0c0c0"),
    Slider = Color3.fromHex("#c0c0c0"),
    SliderThumb = Color3.new(1,1,1),
    SliderIconFrom = Color3.fromHex("#c0c0c0"),
    SliderIconTo = Color3.fromHex("#c0c0c0"),
    Tooltip = Color3.fromHex("4C4C4C"),
    TooltipText = Color3.new(1,1,1),
    TooltipSecondary = Color3.fromHex("#c0c0c0"),
    TooltipSecondaryText = Color3.new(1,1,1),
    TabSectionIcon = Color3.fromHex("#c0c0c0"),
    SectionIcon = Color3.fromHex("#c0c0c0"),
    SectionExpandIcon = Color3.new(1,1,1),
    SectionExpandIconTransparency = .4,
    SectionBox = Color3.new(1,1,1),
    SectionBoxTransparency = .95,
    SectionBoxBorder = Color3.new(1,1,1),
    SectionBoxBorderTransparency = .75,
    SectionBoxBackground = Color3.new(1,1,1),
    SectionBoxBackgroundTransparency = .95,
    SearchBarBorder = Color3.new(1,1,1),
    SearchBarBorderTransparency = .75,
    Notification = Color3.fromHex("#1a1a1a"),
    NotificationTitle = Color3.fromHex("#ffffff"),
    NotificationTitleTransparency = 0,
    NotificationContent = Color3.fromHex("#ffffff"),
    NotificationContentTransparency = .4,
    NotificationDuration = Color3.new(1,1,1),
    NotificationDurationTransparency = .95,
    NotificationBorder = Color3.new(1,1,1),
    NotificationBorderTransparency = .75,
    DropdownTabBorder = Color3.new(1,1,1),
    LabelBackground = Color3.new(1,1,1),
    LabelBackgroundTransparency = .95,
})

WindUI:SetTheme("Silver")

local Window = WindUI:CreateWindow({
    Title = "Silver Hub",
    Author = "by coolio",
    Folder = "SilverHub",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Silver",
    Resizable = true,
    SideBarWidth = 200,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    BackgroundImageTransparency = 0.42,
    Background = "rbxassetid://92817156632393",
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function() end,
    },
})

local VisualTab = Window:Tab({
    Title = "Visual",
})

local INNOCENT_COLOR = Color3.fromRGB(0, 255, 0)
local MURDERER_COLOR = Color3.fromRGB(255, 0, 0)
local SHERIFF_COLOR  = Color3.fromRGB(0, 100, 255)

local espEnabled = false
local highlightInstances = {}
local playerRoles = {}

local function GetPlayerFromArg(arg)
    if typeof(arg) == "Instance" and arg:IsA("Player") then
        return arg
    elseif type(arg) == "string" then
        return game.Players:FindFirstChild(arg)
    end
    return nil
end

local replicatedStorage = game:GetService("ReplicatedStorage")
local remotes = replicatedStorage:FindFirstChild("Remotes")
local extras = remotes and remotes:FindFirstChild("Extras")
local setMurdererRemote = extras and extras:FindFirstChild("SetMurderer")
local setSheriffRemote = extras and extras:FindFirstChild("SetSheriff")
local setMapRemote = extras and extras:FindFirstChild("SetMap")

if setMurdererRemote and setMurdererRemote:IsA("RemoteEvent") then
    setMurdererRemote.OnClientEvent:Connect(function(...)
        local player = GetPlayerFromArg(...)
        if player then
            playerRoles[player] = "murderer"
            if espEnabled then UpdateESP() end
        end
    end)
end

if setSheriffRemote and setSheriffRemote:IsA("RemoteEvent") then
    setSheriffRemote.OnClientEvent:Connect(function(...)
        local player = GetPlayerFromArg(...)
        if player then
            playerRoles[player] = "sheriff"
            if espEnabled then UpdateESP() end
        end
    end)
end

local currentMap = nil
if setMapRemote and setMapRemote:IsA("RemoteEvent") then
    setMapRemote.OnClientEvent:Connect(function(mapName)
        currentMap = mapName
    end)
end

local roundTimer = workspace:FindFirstChild("RoundTimerPart")
if roundTimer then
    roundTimer:GetAttributeChangedSignal("Time"):Connect(function()
        local time = roundTimer:GetAttribute("Time") or -1
        if time <= 0 then
            for player, _ in pairs(playerRoles) do
                playerRoles[player] = "innocent"
            end
            if espEnabled then UpdateESP() end
        end
    end)
end

local function PlayerHasTool(player, toolName)
    if not player then return false end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == toolName then
                return true
            end
        end
    end
    local character = player.Character
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == toolName then
                return true
            end
        end
    end
    return false
end

local function GetPlayerRoleColor(player)
    if not player then return nil end
    local role = playerRoles[player]
    if role == "murderer" then
        return MURDERER_COLOR
    elseif role == "sheriff" then
        return SHERIFF_COLOR
    else
        if PlayerHasTool(player, "Knife") then
            return MURDERER_COLOR
        elseif PlayerHasTool(player, "Gun") then
            return SHERIFF_COLOR
        else
            return INNOCENT_COLOR
        end
    end
end

local function GetCurrentMurderer()
    for player, role in pairs(playerRoles) do
        if role == "murderer" then
            return player
        end
    end
    for _, player in pairs(game.Players:GetPlayers()) do
        if PlayerHasTool(player, "Knife") then
            return player
        end
    end
    return nil
end

local function GetCurrentSheriff()
    for player, role in pairs(playerRoles) do
        if role == "sheriff" then
            return player
        end
    end
    for _, player in pairs(game.Players:GetPlayers()) do
        if PlayerHasTool(player, "Gun") then
            return player
        end
    end
    return nil
end

local function UpdateESP()
    for _, highlight in pairs(highlightInstances) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    highlightInstances = {}

    if not espEnabled then return end

    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end

    for _, player in pairs(game.Players:GetPlayers()) do
        if player == localPlayer then continue end
        if not player.Character then continue end

        local roleColor = GetPlayerRoleColor(player)
        if not roleColor then continue end

        local highlight = Instance.new("Highlight")
        highlight.Adornee = player.Character
        highlight.FillColor = roleColor
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = roleColor
        highlight.OutlineTransparency = 0.2
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = player.Character

        highlightInstances[player] = highlight
    end
end

local function AssignFallbackRoles()
    for _, player in pairs(game.Players:GetPlayers()) do
        if not playerRoles[player] then
            if PlayerHasTool(player, "Knife") then
                playerRoles[player] = "murderer"
            elseif PlayerHasTool(player, "Gun") then
                playerRoles[player] = "sheriff"
            else
                playerRoles[player] = "innocent"
            end
        end
    end
end

AssignFallbackRoles()
if espEnabled then UpdateESP() end

game.Players.PlayerAdded:Connect(function(player)
    if not playerRoles[player] then
        if PlayerHasTool(player, "Knife") then
            playerRoles[player] = "murderer"
        elseif PlayerHasTool(player, "Gun") then
            playerRoles[player] = "sheriff"
        else
            playerRoles[player] = "innocent"
        end
    end

    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if not playerRoles[player] then
            if PlayerHasTool(player, "Knife") then
                playerRoles[player] = "murderer"
            elseif PlayerHasTool(player, "Gun") then
                playerRoles[player] = "sheriff"
            else
                playerRoles[player] = "innocent"
            end
        end
        UpdateESP()
    end)
end)

game.Players.PlayerRemoving:Connect(function(player)
    if highlightInstances[player] then
        highlightInstances[player]:Destroy()
        highlightInstances[player] = nil
    end
    playerRoles[player] = nil
end)

game:GetService("RunService").Heartbeat:Connect(function()
    if espEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if not playerRoles[player] then
                if PlayerHasTool(player, "Knife") then
                    playerRoles[player] = "murderer"
                elseif PlayerHasTool(player, "Gun") then
                    playerRoles[player] = "sheriff"
                else
                    playerRoles[player] = "innocent"
                end
            end
        end
        UpdateESP()
    end
end)

VisualTab:Toggle({
    Title = "ESP",
    Value = false,
    Callback = function(state)
        espEnabled = state
        if not espEnabled then
            for _, highlight in pairs(highlightInstances) do
                if highlight and highlight.Parent then
                    highlight:Destroy()
                end
            end
            highlightInstances = {}
        else
            UpdateESP()
        end
    end
})

local CombatTab = Window:Tab({
    Title = "Combat",
})

local autoShootEnabled = false
local AUTO_SHOOT_COOLDOWN = 0.3
local lastAutoShootTime = 0

local function ShootAtMurderer(silent)
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then
        if not silent then return end
        return
    end

    local murderer = GetCurrentMurderer()
    if not murderer then
        if not silent then return end
        return
    end

    local gun = nil
    local backpack = localPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Gun" then
                gun = tool
                break
            end
        end
    end
    if not gun and localPlayer.Character then
        for _, tool in ipairs(localPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Gun" then
                gun = tool
                break
            end
        end
    end

    if not gun then
        if not silent then return end
        return
    end

    local character = localPlayer.Character
    if not character then
        if not silent then return end
        return
    end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        if not silent then return end
        return
    end

    local targetPos = nil
    if murderer.Character then
        local head = murderer.Character:FindFirstChild("Head")
        if head then
            targetPos = head.Position
        else
            local root = murderer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                targetPos = root.Position + Vector3.new(0, 1.5, 0)
            end
        end
    end

    if not targetPos then
        if not silent then return end
        return
    end

    local originalCFrame = rootPart.CFrame
    local teleportOffset = Vector3.new(0, 0, 1.5)
    local teleportCFrame = CFrame.new(targetPos + teleportOffset)
    rootPart.CFrame = teleportCFrame

    local originCFrame = rootPart.CFrame * CFrame.new(0, 0.5, -2)
    local targetCFrame = CFrame.new(targetPos)

    local shootRemote = gun:FindFirstChild("Shoot")
    if shootRemote and shootRemote:IsA("RemoteEvent") then
        shootRemote:FireServer(originCFrame, targetCFrame)
    else
        if not silent then return end
        rootPart.CFrame = originalCFrame
        return
    end

    rootPart.CFrame = originalCFrame
end

game:GetService("RunService").Heartbeat:Connect(function()
    if autoShootEnabled then
        local now = tick()
        if now - lastAutoShootTime >= AUTO_SHOOT_COOLDOWN then
            lastAutoShootTime = now
            pcall(function() ShootAtMurderer(true) end)
        end
    end
end)

CombatTab:Button({
    Title = "Shoot Murderer",
    Callback = function()
        ShootAtMurderer(false)
    end
})

CombatTab:Toggle({
    Title = "Auto Shoot Murderer",
    Value = false,
    Callback = function(state)
        autoShootEnabled = state
        if autoShootEnabled then
            lastAutoShootTime = tick()
        end
    end
})

CombatTab:Button({
    Title = "Kill All",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        if not localPlayer then return end

        local knife = nil
        local backpack = localPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.Name == "Knife" then
                    knife = tool
                    break
                end
            end
        end
        if not knife and localPlayer.Character then
            for _, tool in ipairs(localPlayer.Character:GetChildren()) do
                if tool:IsA("Tool") and tool.Name == "Knife" then
                    knife = tool
                    break
                end
            end
        end

        if not knife then return end

        local handleTouched = knife:FindFirstChild("Events") and knife.Events:FindFirstChild("HandleTouched")
        if not handleTouched or not handleTouched:IsA("RemoteEvent") then return end

        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    handleTouched:FireServer(rootPart)
                end
            end
        end
    end
})

local autoKillAllEnabled = false
local AUTO_KILL_ALL_COOLDOWN = 1
local lastAutoKillAllTime = 0

local function KillAll()
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end

    local knife = nil
    local backpack = localPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Knife" then
                knife = tool
                break
            end
        end
    end
    if not knife and localPlayer.Character then
        for _, tool in ipairs(localPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == "Knife" then
                knife = tool
                break
            end
        end
    end

    if not knife then return end

    local handleTouched = knife:FindFirstChild("Events") and knife.Events:FindFirstChild("HandleTouched")
    if not handleTouched or not handleTouched:IsA("RemoteEvent") then return end

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                handleTouched:FireServer(rootPart)
            end
        end
    end
end

game:GetService("RunService").Heartbeat:Connect(function()
    if autoKillAllEnabled then
        local now = tick()
        if now - lastAutoKillAllTime >= AUTO_KILL_ALL_COOLDOWN then
            lastAutoKillAllTime = now
            pcall(KillAll)
        end
    end
end)

CombatTab:Toggle({
    Title = "Auto Kill All",
    Value = false,
    Callback = function(state)
        autoKillAllEnabled = state
        if autoKillAllEnabled then
            lastAutoKillAllTime = tick()
        end
    end
})

local function GetAllGunDrops()
    local gunDrops = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "GunDrop" then
            table.insert(gunDrops, obj)
        end
    end
    return gunDrops
end

local function GetClosestGunDrop()
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return nil end
    local character = localPlayer.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    local pos = rootPart.Position
    local gunDrops = GetAllGunDrops()
    local closest = nil
    local closestDist = math.huge
    for _, gd in ipairs(gunDrops) do
        local gdPos
        if gd:IsA("BasePart") then
            gdPos = gd.Position
        elseif gd:IsA("Model") then
            local primary = gd.PrimaryPart
            if primary then
                gdPos = primary.Position
            else
                local parts = gd:GetDescendants()
                for _, part in ipairs(parts) do
                    if part:IsA("BasePart") then
                        gdPos = part.Position
                        break
                    end
                end
            end
        end
        if gdPos then
            local dist = (pos - gdPos).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = gd
            end
        end
    end
    return closest
end

local isTeleporting = false

local function TeleportToGunDrop(gunDrop)
    if not gunDrop or isTeleporting then return end
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end
    local character = localPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local targetCFrame
    if gunDrop:IsA("BasePart") then
        targetCFrame = gunDrop.CFrame
    elseif gunDrop:IsA("Model") then
        local primary = gunDrop.PrimaryPart
        if primary then
            targetCFrame = primary.CFrame
        else
            local parts = gunDrop:GetDescendants()
            for _, part in ipairs(parts) do
                if part:IsA("BasePart") then
                    targetCFrame = part.CFrame
                    break
                end
            end
        end
    end
    if not targetCFrame then return end

    isTeleporting = true
    local originalCFrame = rootPart.CFrame
    rootPart.CFrame = targetCFrame

    local collected = false
    local con1, con2
    local function checkGun()
        if localPlayer.Backpack and localPlayer.Backpack:FindFirstChild("Gun") then
            collected = true
        elseif character and character:FindFirstChild("Gun") then
            collected = true
        end
        if collected then
            if con1 then con1:Disconnect() end
            if con2 then con2:Disconnect() end
        end
    end
    con1 = localPlayer.Backpack.ChildAdded:Connect(checkGun)
    con2 = character.ChildAdded:Connect(checkGun)
    checkGun()

    task.wait(1)
    con1:Disconnect()
    con2:Disconnect()

    rootPart.CFrame = originalCFrame
    isTeleporting = false
end

CombatTab:Button({
    Title = "TP to Gun",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        if not localPlayer then return end

        if PlayerHasTool(localPlayer, "Knife") then return end

        local gunDrop = GetClosestGunDrop()
        if not gunDrop then return end

        TeleportToGunDrop(gunDrop)
    end
})

local autoGunTPEnabled = false
local gunTPTimer = nil
local currentSheriff = nil
local mapChildAddedConnection = nil
local sheriffCharacterRemovedConnection = nil
local sheriffPlayerRemovingConnection = nil

local function CleanupAutoGunTP()
    if gunTPTimer then
        gunTPTimer:Disconnect()
        gunTPTimer = nil
    end
    if mapChildAddedConnection then
        mapChildAddedConnection:Disconnect()
        mapChildAddedConnection = nil
    end
    if sheriffCharacterRemovedConnection then
        sheriffCharacterRemovedConnection:Disconnect()
        sheriffCharacterRemovedConnection = nil
    end
    if sheriffPlayerRemovingConnection then
        sheriffPlayerRemovingConnection:Disconnect()
        sheriffPlayerRemovingConnection = nil
    end
end

local function TryTeleportToGun()
    if not autoGunTPEnabled or isTeleporting then return end
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end
    if PlayerHasTool(localPlayer, "Knife") then return end
    local gd = GetClosestGunDrop()
    if gd then
        TeleportToGunDrop(gd)
    end
end

local function SetupAutoGunTP()
    CleanupAutoGunTP()
    if not autoGunTPEnabled then return end

    TryTeleportToGun()

    gunTPTimer = game:GetService("RunService").Stepped:Connect(function()
        if not autoGunTPEnabled then return end
        if not gunTPTimer._lastCheck then
            gunTPTimer._lastCheck = tick()
        end
        if tick() - gunTPTimer._lastCheck < 0.5 then return end
        gunTPTimer._lastCheck = tick()
        TryTeleportToGun()
    end)

    local map = currentMap and workspace:FindFirstChild(currentMap)
    if map then
        mapChildAddedConnection = map.ChildAdded:Connect(function(child)
            if child.Name == "GunDrop" then
                TryTeleportToGun()
            end
        end)
    end

    currentSheriff = nil
    for player, role in pairs(playerRoles) do
        if role == "sheriff" then
            currentSheriff = player
            break
        end
    end

    if currentSheriff then
        local function onSheriffCharacterRemoved()
            task.wait(0.1)
            TryTeleportToGun()
        end
        if currentSheriff.Character then
            sheriffCharacterRemovedConnection = currentSheriff.Character:WaitForChild("Humanoid").Died:Connect(onSheriffCharacterRemoved)
        end
        sheriffPlayerRemovingConnection = currentSheriff.AncestryChanged:Connect(function()
            if not currentSheriff.Parent then
                task.wait(0.1)
                TryTeleportToGun()
            end
        end)
    end
end

CombatTab:Toggle({
    Title = "Auto TP to Gun",
    Value = false,
    Callback = function(state)
        autoGunTPEnabled = state
        if state then
            SetupAutoGunTP()
        else
            CleanupAutoGunTP()
        end
    end
})

local TrollTab = Window:Tab({
    Title = "Troll",
})

local function IsSeated(player)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and (hum.SeatPart or hum:GetState() == Enum.HumanoidStateType.Seated)
end

local function FlingPlayer(target, silent)
    if not target or target == game.Players.LocalPlayer then
        return false
    end

    local localPlayer = game.Players.LocalPlayer
    local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tChar = target.Character
    local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")
    local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")

    if not hrp or not tHrp or not tHum or tHum.Health <= 0 then
        return false
    end

    if IsSeated(target) then
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

    return launched
end

TrollTab:Button({
    Title = "Fling Murderer",
    Callback = function()
        local murderer = GetCurrentMurderer()
        if murderer then
            FlingPlayer(murderer, false)
        end
    end
})

TrollTab:Button({
    Title = "Fling Sheriff",
    Callback = function()
        local sheriff = GetCurrentSheriff()
        if sheriff then
            FlingPlayer(sheriff, false)
        end
    end
})

local autoFlingMurdererEnabled = false
local autoFlingSheriffEnabled = false
local autoFlingMurdererCoroutine = nil
local autoFlingSheriffCoroutine = nil

TrollTab:Toggle({
    Title = "Auto Fling Murderer",
    Value = false,
    Callback = function(state)
        autoFlingMurdererEnabled = state
        if autoFlingMurdererEnabled then
            if autoFlingMurdererCoroutine then
                autoFlingMurdererCoroutine = nil
            end
            autoFlingMurdererCoroutine = coroutine.create(function()
                while autoFlingMurdererEnabled do
                    local target = GetCurrentMurderer()
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
    Value = false,
    Callback = function(state)
        autoFlingSheriffEnabled = state
        if autoFlingSheriffEnabled then
            if autoFlingSheriffCoroutine then
                autoFlingSheriffCoroutine = nil
            end
            autoFlingSheriffCoroutine = coroutine.create(function()
                while autoFlingSheriffEnabled do
                    local target = GetCurrentSheriff()
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
        CreateFlingDropdown()
    end
})

TrollTab:Button({
    Title = "Fling Selected Player",
    Callback = function()
        if not selectedFlingPlayer or selectedFlingPlayer == "No other players" then
            return
        end

        local targetPlayer = game.Players:FindFirstChild(selectedFlingPlayer)
        if not targetPlayer then
            return
        end

        task.spawn(function()
            while targetPlayer and targetPlayer.Parent do
                local launched = FlingPlayer(targetPlayer, true)
                if launched then
                    break
                end
                task.wait(0.5)
            end
        end)
    end
})

game.Players.PlayerAdded:Connect(CreateFlingDropdown)
game.Players.PlayerRemoving:Connect(CreateFlingDropdown)

local MiscTab = Window:Tab({
    Title = "Misc",
})

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
    Title = "Refresh Players",
    Callback = function()
        CreatePlayerDropdown()
    end
})

MiscTab:Button({
    Title = "Teleport to Selected Player",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        if not localPlayer then return end

        if not selectedPlayerName or selectedPlayerName == "No other players" then
            return
        end

        local targetPlayer = game.Players:FindFirstChild(selectedPlayerName)
        if not targetPlayer then return end

        local targetCharacter = targetPlayer.Character
        if not targetCharacter then return end

        local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end

        local localCharacter = localPlayer.Character
        if not localCharacter then return end

        local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
        if not localRoot then return end

        localRoot.CFrame = targetRoot.CFrame
    end
})

game.Players.PlayerAdded:Connect(CreatePlayerDropdown)
game.Players.PlayerRemoving:Connect(CreatePlayerDropdown)
