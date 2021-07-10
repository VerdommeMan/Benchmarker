-- OOP bc i might have multipe UIs, Director bc it manages other managers

local GuiDirector = {}
GuiDirector.__index = GuiDirector

-- Managers
local WindowManager = require(script.WindowManager)
local ResizeHandler = require(script.ResizeHandler)
local StatsHandler = require(script.StatsHandler)

local guiFolder = script.Parent
local components = guiFolder.components


local function getComponent(name)
    return components[name]:Clone()
end


function GuiDirector.new(gui)
   local self = setmetatable({root = gui}, GuiDirector)
   self.MainWindow = WindowManager.new(self.root.Background:FindFirstChild("Window", true), self.root, true) 
   self.MinmizedWindow = WindowManager.new(self.root.Minimized.window, self.root) 
   ResizeHandler(self.root, StatsHandler(getComponent("StatsScaffold")))
   return self
end



function GuiDirector:Destroy()
    self.root:Destroy()
end


return GuiDirector