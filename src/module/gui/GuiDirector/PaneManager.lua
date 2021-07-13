local PaneManager = {}
PaneManager.__index = PaneManager

local ToggleManager = require(script.Parent.ToggleManager)
local TableManager  = require(script.Parent.TableManager)   
local ProgressBarManager = require(script.Parent.ProgressBarManager)

function PaneManager.new(pane, benchmark)
    local self = setmetatable({pane = pane, benchmark = benchmark, Tables = {}}, PaneManager)

    for _, method in ipairs(benchmark.Methods) do 
        table.insert(self.Tables, TableManager.new(benchmark, method, pane.Info.Table))
    end

    self.toggle = ToggleManager.new(pane, benchmark.Methods)
    self:_initProgressBar() 
    
    return self
end

function PaneManager:_initProgressBar()
    self.progressBarManager = ProgressBarManager.new(self.pane.Bars.SubTotalProgress)

    self._conPogress = self.benchmark.ProgressChanged:Connect(function(progress)
        self.progressBarManager:setLabel(self.Benchmark.CurrentMethod, self.Benchmark.CurrentFunction, progress)
        self.progressBarManager:setTotal(self.Benchmark.TotalCompleted, self.Benchmark.Total)    
    end)

    self._conStatus = self.benchmark.StatusChanged:Connect(function(status)
        if status == "Running" then
            self.progressBarManager:show()
        elseif status == "Completed" then
            self.progressBarManager:hide()
            self:_cleanProgressBarConnections()
        end
    end)
end

function PaneManager:_cleanProgressBarConnections()
    self._conProgress:Disconnect()
    self._conPogress = nil
    self._conStatus:Disconnect()
    self._conStatus = nil 
end

function PaneManager:destroy()
    if self._conPogress then
        self:_cleanProgressBarConnections()
    end
    for _, tbl in ipairs(self.Tables) do
        tbl:destroy()
    end
    table.clear(self.Tables)
    self.pane:Destroy()
    self.pane = nil
end

return PaneManager