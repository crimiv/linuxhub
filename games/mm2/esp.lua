local WindUI = LinuxHub.WindUI
local utils = LinuxHub.Utils
local config = LinuxHub.Config

local WAIT = task.wait
local TBINSERT = table.insert
local TBFIND = table.find
local TBREMOVE = table.remove
local V2 = Vector2.new
local ROUND = math.round

local RS = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local To2D = Camera.WorldToViewportPoint
local LocalPlayer = game.Players.LocalPlayer

local Library = {}
Library.__index = Library

function Library:NewLine(info)
    local l = Drawing.new("Line")
    l.Visible = info.Visible or true
    l.Color = info.Color or Color3.fromRGB(0,255,0)
    l.Transparency = info.Transparency or 1
    l.Thickness = info.Thickness or 1
    return l
end

function Library:Smoothen(v)
    return V2(ROUND(v.X), ROUND(v.Y))
end

local Skeleton = {
    Removed = false,
    Player = nil,
    Visible = false,
    Lines = {},
    Color = Color3.fromRGB(0,255,0),
    Alpha = 1,
    Thickness = 1,
    DoSubsteps = true,
}
Skeleton.__index = Skeleton

function Skeleton:UpdateStructure()
    if not self.Player.Character then return end
    self:RemoveLines()
    for _, part in next, self.Player.Character:GetChildren() do
        if not part:IsA("BasePart") then continue end
        for _, link in next, part:GetChildren() do
            if not link:IsA("Motor6D") then continue end
            TBINSERT(
                self.Lines,
                {
                    Library:NewLine({
                        Visible = self.Visible,
                        Color = self.Color,
                        Transparency = self.Alpha,
                        Thickness = self.Thickness,
                    }),
                    Library:NewLine({
                        Visible = self.Visible,
                        Color = self.Color,
                        Transparency = self.Alpha,
                        Thickness = self.Thickness,
                    }),
                    part.Name,
                    link.Name
                }
            )
        end
    end
end

function Skeleton:SetVisible(State)
    for _,l in pairs(self.Lines) do
        l[1].Visible = State
        l[2].Visible = State
    end
end

function Skeleton:SetColor(Color)
    self.Color = Color
    for _,l in pairs(self.Lines) do
        l[1].Color = Color
        l[2].Color = Color
    end
end

function Skeleton:SetAlpha(Alpha)
    self.Alpha = Alpha
    for _,l in pairs(self.Lines) do
        l[1].Transparency = Alpha
        l[2].Transparency = Alpha
    end
end

function Skeleton:SetThickness(Thickness)
    self.Thickness = Thickness
    for _,l in pairs(self.Lines) do
        l[1].Thickness = Thickness
        l[2].Thickness = Thickness
    end
end

function Skeleton:SetDoSubsteps(State)
    self.DoSubsteps = State
end

function Skeleton:Update()
    if self.Removed then return end
    local Character = self.Player.Character
    if not Character then
        self:SetVisible(false)
        if not self.Player.Parent then
            self:Remove()
        end
        return
    end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then
        self:SetVisible(false)
        return
    end
    self:SetColor(self.Color)
    self:SetAlpha(self.Alpha)
    self:SetThickness(self.Thickness)
    local update = false
    for _, l in pairs(self.Lines) do
        local part = Character:FindFirstChild(l[3])
        if not part then
            l[1].Visible = false
            l[2].Visible = false
            update = true
            continue
        end
        local link = part:FindFirstChild(l[4])
        if not (link and link.part0 and link.part1) then
            l[1].Visible = false
            l[2].Visible = false
            update = true
            continue
        end
        local part0 = link.Part0
        local part1 = link.Part1
        if self.DoSubsteps and link.C0 and link.C1 then
            local c0 = link.C0
            local c1 = link.C1
            local part0p, v1 = To2D(Camera, part0.CFrame.p)
            local part0cp, v2 = To2D(Camera, (part0.CFrame * c0).p)
            if v1 and v2 then
                l[1].From = V2(part0p.x, part0p.y)
                l[1].To = V2(part0cp.x, part0cp.y)
                l[1].Visible = true
            else
                l[1].Visible = false
            end
            local part1p, v3 = To2D(Camera, part1.CFrame.p)
            local part1cp, v4 = To2D(Camera, (part1.CFrame * c1).p)
            if v3 and v4 then
                l[2].From = V2(part1p.x, part1p.y)
                l[2].To = V2(part1cp.x, part1cp.y)
                l[2].Visible = true
            else
                l[2].Visible = false
            end
        else
            local part0p, v1 = To2D(Camera, part0.CFrame.p)
            local part1p, v2 = To2D(Camera, part1.CFrame.p)
            if v1 and v2 then
                l[1].From = V2(part0p.x, part0p.y)
                l[1].To = V2(part1p.x, part1p.y)
                l[1].Visible = true
            else
                l[1].Visible = false
            end
            l[2].Visible = false
        end
    end
    if update or #self.Lines == 0 then
        self:UpdateStructure()
    end
end

function Skeleton:Toggle()
    self.Visible = not self.Visible
    if self.Visible then
        self:RemoveLines()
        self:UpdateStructure()
        local c
        c = RS.Heartbeat:Connect(function()
            if not self.Visible then
                self:SetVisible(false)
                c:Disconnect()
                return
            end
            self:Update()
        end)
    end
end

function Skeleton:RemoveLines()
    for _,l in pairs(self.Lines) do
        l[1]:Remove()
        l[2]:Remove()
    end
    self.Lines = {}
end

function Skeleton:Remove()
    self.Removed = true
    self:RemoveLines()
end

function Library:NewSkeleton(Player, Visible, Color, Alpha, Thickness, DoSubsteps)
    if not Player then error("Missing Player argument (#1)") end
    local s = setmetatable({}, Skeleton)
    s.Player = Player
    s.Bind = Player.UserId
    if DoSubsteps ~= nil then s.DoSubsteps = DoSubsteps end
    if Color then s:SetColor(Color) end
    if Alpha then s:SetAlpha(Alpha) end
    if Thickness then s:SetThickness(Thickness) end
    if Visible then s:Toggle() end
    return s
end

local SkeletonLibrary = Library

local VisualTab = LinuxHub.Window:Tab({ Title = "Visual" })

local espEnabled = LinuxHub.Toggles.espEnabled or false
local skeletons = {}
local espUpdateCooldown = 0

local function GetPlayerRoleColor(player)
    if not player then return nil end
    if utils.PlayerHasTool(player, "Knife") then
        return config.colors.murderer
    elseif utils.PlayerHasTool(player, "Gun") then
        return config.colors.sheriff
    else
        return config.colors.innocent
    end
end

local function ClearESP()
    for _, skeleton in pairs(skeletons) do
        if skeleton and skeleton.Remove then
            skeleton:Remove()
        end
    end
    skeletons = {}
end

local function UpdateESP()
    if _G.LINUXHUB_UPDATING or not espEnabled then
        ClearESP()
        return
    end
    local localPlayer = game.Players.LocalPlayer
    if not localPlayer then return end
    local currentPlayers = game.Players:GetPlayers()
    for player, skeleton in pairs(skeletons) do
        if not table.find(currentPlayers, player) or player == localPlayer then
            skeleton:Remove()
            skeletons[player] = nil
        end
    end
    for _, player in pairs(currentPlayers) do
        if player == localPlayer then continue end
        if not player.Character then continue end
        local roleColor = GetPlayerRoleColor(player)
        if not roleColor then continue end
        local skeleton = skeletons[player]
        if not skeleton then
            skeleton = SkeletonLibrary:NewSkeleton(player, true, roleColor, 0.8, 2)
            skeletons[player] = skeleton
        else
            skeleton:SetColor(roleColor)
        end
    end
end

local function GetCurrentMurderer()
    for _, player in pairs(game.Players:GetPlayers()) do
        if utils.PlayerHasTool(player, "Knife") then
            return player
        end
    end
    return nil
end

local function GetCurrentSheriff()
    for _, player in pairs(game.Players:GetPlayers()) do
        if utils.PlayerHasTool(player, "Gun") then
            return player
        end
    end
    return nil
end

local replicatedStorage = game:GetService("ReplicatedStorage")
local remotes = replicatedStorage:FindFirstChild("Remotes")
local extras = remotes and remotes:FindFirstChild("Extras")
local setMurdererRemote = extras and extras:FindFirstChild("SetMurderer")
local setSheriffRemote = extras and extras:FindFirstChild("SetSheriff")

if setMurdererRemote and setMurdererRemote:IsA("RemoteEvent") then
    setMurdererRemote.OnClientEvent:Connect(function(...)
        if _G.LINUXHUB_UPDATING then return end
        UpdateESP()
    end)
end

if setSheriffRemote and setSheriffRemote:IsA("RemoteEvent") then
    setSheriffRemote.OnClientEvent:Connect(function(...)
        if _G.LINUXHUB_UPDATING then return end
        UpdateESP()
    end)
end

local roundTimer = workspace:FindFirstChild("RoundTimerPart")
if roundTimer then
    roundTimer:GetAttributeChangedSignal("Time"):Connect(function()
        if _G.LINUXHUB_UPDATING then return end
        UpdateESP()
    end)
end

if espEnabled then UpdateESP() end

game.Players.PlayerAdded:Connect(function(player)
    if _G.LINUXHUB_UPDATING then return end
    player.CharacterAdded:Connect(function()
        if _G.LINUXHUB_UPDATING then return end
        task.wait(0.5)
        UpdateESP()
    end)
end)

game.Players.PlayerRemoving:Connect(function(player)
    if _G.LINUXHUB_UPDATING then return end
    if skeletons[player] then
        skeletons[player]:Remove()
        skeletons[player] = nil
    end
end)

game:GetService("RunService").Heartbeat:Connect(function()
    if _G.LINUXHUB_UPDATING then return end
    if espEnabled then
        local now = tick()
        if now - espUpdateCooldown >= 0.5 then
            espUpdateCooldown = now
            UpdateESP()
        end
    end
end)

VisualTab:Toggle({
    Title = "ESP Highlight",
    Value = espEnabled,
    Callback = function(state)
        espEnabled = state
        LinuxHub.Toggles.espEnabled = state
        if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
        WindUI:Notify({
            Title = "ESP Highlight",
            Content = espEnabled and "ESP Enabled" or "ESP Disabled",
            Duration = 2,
        })
        if not espEnabled then
            ClearESP()
        else
            UpdateESP()
        end
    end
})

LinuxHub.GetCurrentMurderer = GetCurrentMurderer
LinuxHub.GetCurrentSheriff = GetCurrentSheriff

LinuxHub.DisableAll = function()
    espEnabled = false
    LinuxHub.Toggles.espEnabled = false
    if LinuxHub.SaveSettings then LinuxHub.SaveSettings() end
    ClearESP()
end
