-- OOP bc i might have multipe UIs, Director bc it manages other managers. #todo maids, proper adherence to private vars

local GuiDirector = {}
GuiDirector.__index = GuiDirector

local guiFolder = script.Parent

-- Managers
local PaneManager = require(script.PaneManager)
local WindowManager = require(script.WindowManager)
local PaneControlManager = require(script.PaneControlManager)
local ResizeHandler = require(script.ResizeHandler)
local StatsHandler = require(script.StatsHandler)
local Middleware = require(guiFolder.Parent.modules.Middleware)

local components = guiFolder.components

local Data = require(guiFolder.Parent.Data)

local function getComponent(name)
    return components[name]:Clone()
end


function GuiDirector.new(client)
    local suc, obj = Middleware.init(client)
    if not suc then
        warn(obj)
        return    
    end
    
    local self = setmetatable({
        root = guiFolder.Benchmarker:Clone(), 
        panes = {[0] = {pane = getComponent("EmptyPane")}},
        middleware = obj
    }, GuiDirector)
    
    self.root.Parent = client.PlayerGui
    local background = self.root.Background
    self:_setVersion()
    self.mainWindow = WindowManager.new(background:FindFirstChild("Window", true), self.root, true, self.middleware) 
    self.minmizedWindow = WindowManager.new(self.root.Minimized.window, self.root, false, self.middleware) 
    self.paneHolder = background.Content.VerticalList
    self.paneControlManager = PaneControlManager.new(self.panes, self.paneHolder.Controls) 
    ResizeHandler(self.root, StatsHandler(getComponent("StatsScaffold")))
    
    Data.Benchmarks.Total:added(function(benchmark)
        table.insert(self.panes, PaneManager.new(getComponent("PaneScaffold"), benchmark, self.paneHolder))
        self.paneControlManager:update()
    end)

    return self
end

function GuiDirector:_setVersion()
    self.root.Background.Version.Text = "V" .. Data.Version
end

function GuiDirector:show()
    self.root.Enabled = true
end

function GuiDirector:hide()
    self.root.Enabled = false
end

function GuiDirector:destroy()
    self.paneHolder = nil
    self.paneControlManager:destroy()
    self.root:Destroy()
end


return GuiDirector