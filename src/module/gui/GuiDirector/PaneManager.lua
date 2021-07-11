local PaneManager = {}
PaneManager.__index = {}

function PaneManager.new(pane, benchmark)
    local self = setmetatable({pane = pane, benchmark = benchmark})
    
end

return PaneManager