local PaneManager = {}
PaneManager.__index = {}

local ToggleManager = require(script.Parent.ToggleManager)
local TableManager  = require(script.Parent.TableManager)   

function PaneManager.new(pane, benchmark)
    local self = setmetatable({pane = pane, benchmark = benchmark, Tables = {}}, PaneManager)
    local Table = self.pane.Info.Table

    for _, method in ipairs(benchmark.Methods) do 
        table.insert(self.Tables, TableManager.new(benchmark, method))
    end

    self.Toggle = ToggleManager.new(self.pane.Info.Selector.Toggle, Table)
    
    return self
end

function PaneManager:destroy()
    for _, tbl in ipairs(self.Tables) do
        tbl:destroy()
    end
    table.clear(self.Tables)
    self.pane:Destroy()
    self.pane = nil
end

return PaneManager