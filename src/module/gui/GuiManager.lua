-- OOP bc i might have multipe UIs

local GuiManager = {}
GuiManager.__index = GuiManager

local EmptyPane = script.Parent.EmptyPane:Clone()
local Pane = script.Parent.Pane:Clone()


function GuiManager.new(gui)
    return setmetatable({root = gui}, GuiManager)
end



function GuiManager:Destroy()
    self.root:Destroy()
end


return GuiManager