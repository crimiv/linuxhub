-- Minimal WindUI stub for offline development and smoke tests
local WindUI = {}

function WindUI:AddTheme(_) end
function WindUI:SetTheme(_) end

local WindowProto = {}
function WindowProto:SetToggleKey(_) end
function WindowProto:CreateTab(opts)
    local tab = {}
    function tab:Button(_) end
    function tab:Toggle(_) end
    function tab:Paragraph(_) end
    return tab
end
function WindowProto:Tab(opts)
    return self:CreateTab(opts)
end

function WindUI:CreateWindow(opts)
    local win = setmetatable({}, { __index = WindowProto })
    function win:Notify(_) end
    return win
end

WindUI.Creator = {
    AddColor = function(_, ...) return nil end
}

return WindUI
