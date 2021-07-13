-- OOP bc i might have multipe UIs, Director bc it manages other managers

local GuiDirector = {}
GuiDirector.__index = GuiDirector

-- Managers
local PaneManager = require(script.PaneManager)
local WindowManager = require(script.WindowManager)
local PaneControlManager = require(script.PaneControlManager)
local ResizeHandler = require(script.ResizeHandler)
local StatsHandler = require(script.StatsHandler)

local guiFolder = script.Parent
local components = guiFolder.components

local Data = require(guiFolder.Parent.Data)

local function getComponent(name)
    return components[name]:Clone()
end


function GuiDirector.new()
    local self = setmetatable({root = guiFolder.Benchmarker:Clone(), panes = {[0] = {pane = getComponent("EmptyPane")}}}, GuiDirector)
    local background = self.root.Background
    self.mainWindow = WindowManager.new(background:FindFirstChild("Window", true), self.root, true) 
    self.minmizedWindow = WindowManager.new(self.root.Minimized.window, self.root) 
    self.paneHolder = background.Content.VerticalList
    self.paneControlManager = PaneControlManager.new(self.panes, self.paneHolder.Controls) 
    ResizeHandler(self.root, StatsHandler(getComponent("StatsScaffold")))
    local total = Data.Benchmarks.Total
    
    total:exempt()
    total:changed(function()
        table.insert(self.panes, PaneManager.new(getComponent("PaneScaffold"), total[total:len()], self.paneHolder))
        self.paneControlManager:update()
    end)

    wait(5)
    self.root.Parent = game.Players.LocalPlayer.PlayerGui

   return self
end



function GuiDirector:destroy()
    self.paneHolder = nil
    self.paneControlManager:destroy()
    self.root:Destroy()
end


return GuiDirector