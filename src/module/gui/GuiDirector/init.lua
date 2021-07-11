-- OOP bc i might have multipe UIs, Director bc it manages other managers

local GuiDirector = {}
GuiDirector.__index = GuiDirector

-- Managers
local WindowManager = require(script.WindowManager)
local ResizeHandler = require(script.ResizeHandler)
local StatsHandler = require(script.StatsHandler)

local guiFolder = script.Parent
local components = guiFolder.components

local Data = require(guiFolder.Parent.Data)

local function getComponent(name)
    return components[name]:Clone()
end


function GuiDirector.new()
    local self = setmetatable({root = guiFolder.Benchmarker:Clone()}, GuiDirector)
    local background = self.root.Background
    self.MainWindow = WindowManager.new(background:FindFirstChild("Window", true), self.root, true) 
    self.MinmizedWindow = WindowManager.new(self.root.Minimized.window, self.root) 
    self.PaneHolder = background.Content.VerticalList
    ResizeHandler(self.root, StatsHandler(getComponent("StatsScaffold")))

    self.Panes = {Empty = getComponent("EmptyPane")}
    self.Panes.Empty.Parent = self.PaneHolder

    wait(5)
    self.root.Parent = game.Players.LocalPlayer.PlayerGui

   return self
end



function GuiDirector:Destroy()
    self.root:Destroy()
end


return GuiDirector