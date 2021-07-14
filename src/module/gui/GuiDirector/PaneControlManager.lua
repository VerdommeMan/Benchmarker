local PaneControlManager = {}
PaneControlManager.__index = PaneControlManager

local root = script.Parent.Parent.Parent 
local Maid = require(root.modules.Maid)
local Data = require(root.Data)

function PaneControlManager.new(panes, controls)
    local self = setmetatable({
        panes = panes, 
        controls = controls,  
        paneHolder = controls.Parent,
        maid = Maid.new(), 
        pos = 0
    }, PaneControlManager)

    local emptyPane = self.panes[self.pos]
    self.currentPane = emptyPane
    emptyPane.pane.Parent = self.paneHolder

    self.maid:GiveTask(emptyPane.pane)
    self:_initButtons()
    return self
end

local function setButtonState(btn: TextButton, enabled)
    btn.Active = enabled
    btn.BackgroundTransparency = enabled and 0 or 1
    btn.TextTransparency = enabled and 0 or 1 
end

function PaneControlManager:update()
    if self.pos == 0 and #self.panes > 0 then
        self.pos = 1
    end
    if self.currentPane ~= self.panes[self.pos] then
        self.currentPane.pane.Parent = nil
        self.currentPane = self.panes[self.pos]
        self.currentPane.pane.Parent = self.paneHolder
        self.maid.StatusChanged = self.currentPane.benchmark.StatusChanged:Connect(function()
            self:updateStartButton()
        end)
    end
    setButtonState(self.controls.Previous, self.pos > 1)
    setButtonState(self.controls.Next, self.pos ~= #self.panes)
    self:updateStartButton()
end

function PaneControlManager:_initButtons()
    self.maid.previous = self.controls.Previous.Activated:Connect(function()
        self.pos = math.max(1, self.pos - 1)
        self:update()
    end)
    self.maid.next = self.controls.Next.Activated:Connect(function()        
        self.pos = math.min(#self.panes, self.pos + 1)
        self:update()
    end)
    self.maid.start = self.controls.Start.Activated:Connect(function()
        self:_startButton()
    end)
    self:update()
end

function PaneControlManager:_startButton()
    local benchmark = self.currentPane.benchmark
    if benchmark.Status == "Waiting" then
        benchmark:Start()
    elseif benchmark.Status == "Running" then
        benchmark:Pauze()
    elseif benchmark.Status == "Pauzed" then
        benchmark:Unpauze()
    end 
end

function PaneControlManager:updateStartButton()
    local benchmark = self.currentPane.benchmark
    local currentBenchmark = Data.Benchmarks.CurrentBenchmark 
    local start = self.controls.Start
    local isActive = start.Active

    if benchmark and benchmark.Status ~= "Completed" and (not currentBenchmark or currentBenchmark == benchmark) then
        if benchmark.Status == "Running" then
            start.Text = "PAUZE"
        elseif benchmark.Status == "Pauzed" then
            start.Text = "UNPAUZE"
        else
            start.Text = "START"
        end
        if not isActive then
            setButtonState(start, true) 
        end
    elseif isActive then
        setButtonState(start, false)
    end
end

function PaneControlManager:destroy()
    self.maid:DoCleaning()
    for _, pane in ipairs(self.panes) do
        pane:destroy()
    end
    table.clear(self.panes)
end

return PaneControlManager