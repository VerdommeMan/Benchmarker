-- OOP bc i might have multipe UIs, Director bc it manages other managers

local GuiDirector = {}
GuiDirector.__index = GuiDirector

-- local EmptyPane = script.Parent.EmptyPane:Clone()
-- local Pane = script.Parent.Pane:Clone()

-- Managers
local WindowManager = require(script.WindowManager)

function GuiDirector.new(gui)
   local self = setmetatable({root = gui}, GuiDirector)
   self.MainWindow = WindowManager.new(self.root.Background:FindFirstChild("Window", true), self.root, true) 
   self.MinmizedWindow = WindowManager.new(self.root.Minimized.window, self.root) 
   return self
end



function GuiDirector:Destroy()
    self.root:Destroy()
end


return GuiDirector