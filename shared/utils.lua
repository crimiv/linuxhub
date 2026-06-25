local LinuxHub = {}

function LinuxHub.GetPlayerFromArg(arg)
    if typeof(arg) == "Instance" and arg:IsA("Player") then
        return arg
    elseif type(arg) == "string" then
        return game.Players:FindFirstChild(arg)
    end
    return nil
end

function LinuxHub.PlayerHasTool(player, toolName)
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

function LinuxHub.GetPlatform()
    if _G.ExecutorFunctionality and _G.ExecutorFunctionality.IsMobile then
        if _G.ExecutorFunctionality.IsMobile() then
            return "Mobile"
        end
    end
    return "PC"
end

function LinuxHub.GetExecutor()
    if getexecutorname then
        local success, name = pcall(getexecutorname)
        if success and name then
            return name
        end
    end
    
    if syn then return "Synapse X" end
    if KRNL_LOADED then return "Krnl" end
    if _G.VEGA then return "Vega X" end
    if _G.FURK then return "Furk" end
    if _G.DELTA then return "Delta" end
    if _G.HADES then return "Hades" end
    if _G.MIRAI then return "Mirai" end
    if protosmasher_loader then return "ProtoSmasher" end
    if exploit then return "Exploit" end
    if debug.getinfo then return "Roblox Studio" end
    
    return "Unknown"
end

function LinuxHub.CreateStatusTab(Window)
    if not Window then return end
    
    local StatusTab = Window:CreateTab({
        Title = "Status",
        Icon = "rbxassetid://15898349158"
    })
    
    local platform = LinuxHub.GetPlatform()
    local executor = LinuxHub.GetExecutor()
    
    StatusTab:Paragraph({
        Title = "Platform",
        Content = platform
    })
    
    StatusTab:Paragraph({
        Title = "Executor",
        Content = executor
    })
end

return LinuxHub
