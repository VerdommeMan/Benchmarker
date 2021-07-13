local PaneControlManager = {}
PaneControlManager.__index = PaneControlManager

local Maid = require(script.Parent.Parent.Parent.modules.Maid)

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
    self:initButtons()
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
    end
    setButtonState(self.controls.Previous, self.pos > 1)
    setButtonState(self.controls.Next, self.pos ~= #self.panes)
end

function PaneControlManager:initButtons()
    self.maid.previous = self.controls.Previous.Activated:Connect(function()
        print("prev")
        self.pos = math.max(1, self.pos - 1)
        self:update()
    end)
    self.maid.next = self.controls.Next.Activated:Connect(function()        
        print("next")
        self.pos = math.min(#self.panes, self.pos + 1)
        self:update()
    end)
    self.maid.start = self.controls.Start.Activated:Connect(function()
        self:startButton()
    end)
    self:update()
end

function PaneControlManager:startButton()
    
end

function PaneControlManager:destroy()
    self.maid:DoCleaning()
    for _, pane in ipairs(self.panes) do
        pane:destroy()
    end
    table.clear(self.panes)
end

return PaneControlManager