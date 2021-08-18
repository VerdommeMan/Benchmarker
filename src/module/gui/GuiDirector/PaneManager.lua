-- TODO maids
local PaneManager = {}
PaneManager.__index = PaneManager

local ToggleManager = require(script.Parent.ToggleManager)
local TableManager  = require(script.Parent.TableManager)   
local ProgressBarManager = require(script.Parent.ProgressBarManager)

function PaneManager.new(pane, benchmark)
    local self = setmetatable({pane = pane, benchmark = benchmark, Tables = {}}, PaneManager)
    self.toggle = ToggleManager.new(pane, benchmark.Methods)

    self:_initPanes()
    self:_initProgressBar() 
    self:_listenRestart()

    return self
end

function PaneManager:_initProgressBar()
    self.progressBarManager = ProgressBarManager.new(self.pane.Bars.SubTotalProgress)

    self._conProgress = self.benchmark.ProgressChanged:Connect(function(progress)
        self.progressBarManager:setLabel(self.benchmark.CurrentMethod.Name, self.benchmark.CurrentFunction, progress)
        self.progressBarManager:setTotal(self.benchmark.TotalCompleted, self.benchmark.Total)    
    end)
    local oldStatus
    self._conStatus = self.benchmark.StatusChanged:Connect(function(status)
        if status == "Running" then
            self.progressBarManager:show()
        elseif oldStatus == "Running" then
            self.progressBarManager:hide()
        end
        oldStatus = status
    end)
end

function PaneManager:_initPanes()
    for _, method in ipairs(self.benchmark.Methods) do 
        table.insert(self.Tables, TableManager.new(self.benchmark, method, self.pane.Info.Table))
    end
    self.toggle:alignTables()
end

function PaneManager:_destroyPanes()
    for _, tbl in ipairs(self.Tables) do
        tbl:destroy()
    end
    table.clear(self.Tables)
end

function PaneManager:_cleanProgressBarConnections()
    self._conProgress:Disconnect()
    self._conPogress = nil
    self._conStatus:Disconnect()
    self._conStatus = nil 
end

-- When the benchmark restarts it needs to recreate the Tables to show the new results
function PaneManager:_listenRestart()
    local oldStatus = self.benchmark.Status
    self.conStatusRestart = self.benchmark.StatusChanged:Connect(function(status)
        if (oldStatus == "Completed" and status == "Queued") or (oldStatus == "Running" and status ~= "Completed")  then -- when restart or cancel #TODO, doesnt work when cancellign pauzed benchmark
            self:_destroyPanes()
            self:_initPanes()
        end
        oldStatus = status
    end)
end

function PaneManager:destroy()
    self:_cleanProgressBarConnections()
    self._conStatusRetart:Disconnect()
    self:_destroyPanes()
    self.pane:Destroy()
    self.pane = nil
end

return PaneManager