local WindUI = LinuxHub.WindUI

local AdminTab = LinuxHub.Window:Tab({ Title = "Admin" })

local function LoadAdmin(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then
        WindUI:Notify({
            Title = "Error",
            Content = "Failed to load admin script. Check your connection.",
            Duration = 4,
        })
    else
        WindUI:Notify({
            Title = "Admin Loaded",
            Content = "Admin script executed successfully.",
            Duration = 3,
        })
    end
end

AdminTab:Button({
    Title = "Load Nameless Admin",
    Callback = function()
        LoadAdmin("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua")
    end
})

AdminTab:Button({
    Title = "Load Infinite Yield",
    Callback = function()
        LoadAdmin("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
    end
})