local BASE_URL = "https://raw.githubusercontent.com/crimiv/silverhub/main/"

local function LoadScript(name)
    local script = game:HttpGet(BASE_URL .. name)
    local fn, err = loadstring(script)
    if not fn then error(err) end
    return fn()
end

local WindUI = LoadScript("shared/windui.lua")
local utils = LoadScript("shared/utils.lua")
local config = LoadScript("shared/config.lua")

SilverHub = SilverHub or {}
SilverHub.WindUI = WindUI
SilverHub.Utils = utils
SilverHub.Config = config

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

SilverHub.Window = Window

LoadScript("games/mm2/esp.lua")
LoadScript("games/mm2/combat.lua")
LoadScript("games/mm2/troll.lua")
LoadScript("games/mm2/misc.lua")
