local WindowManager = {}
WindowManager.__index = WindowManager


local function createHover(middleware, gui, enter, leave)
	middleware:listen(gui, "MouseEnter", function() 
		gui.BackgroundTransparency = enter
	end)

	middleware:listen(gui, "MouseLeave", function() 
		gui.BackgroundTransparency = (leave or 1)
	end)
end

function WindowManager.new(window, root, includeMaximize, middleware)
    local self = setmetatable({window = window, root = root, middleware = middleware}, WindowManager)
    self:initClose(function()   end) --#TODO need to figure out how to pass the destroy from main module
    self:initMinimize()
    if includeMaximize then
        self:initMaximize()
    end
    return self
end

function WindowManager:initClose(destroy)
    local close = self.window.Close
    createHover(self.middleware, close, 0.5)
    self.middleware:listen(close, "Activated", destroy)
end

function WindowManager:initMinimize()
    local close = self.window.Minimize
    local background = self.root.Background
    createHover(self.middleware, close, 0.8)

    self.middleware:listen(close, "Activated", function() 
       background.Visible = not background.Visible
       background.Parent.Minimized.Visible = not background.Parent.Minimized.Visible
    end)
end

function WindowManager:initMaximize()
    local fullscreen = true -- need to find a  goodway to have config available from all managers classes
    self.mode = fullscreen and WindowManager.fullscreenMode or WindowManager.windowMode
    self.defaultSize = self.root.Background.Size
    self.defaultPos = self.window.Position
    self.head = self.window.Parent.Head
    self.defaultHeadPos = self.head.Position

    self.middleware:listen(self.window.Maximize, "Activated", function() self:mode() end)
    
    createHover(self.middleware, self.window.Maximize, 0.8)
end

function WindowManager:fullscreenMode()
    self.root.Background.Size = UDim2.fromScale(1, 1)
    self.window.Position = UDim2.new(1, -58, 0.5, 0) -- 10 pixels left from more button
    self.head.Position = UDim2.new(0, 102, 0.5, 0) -- 32 +32 +12+16 +10, 10 pixels right from icon
    self.mode = WindowManager.windowMode
end

function WindowManager:windowMode()
    self.root.Background.Size = self.defaultSize
    self.window.Position = self.defaultPos
    self.head.Position = self.defaultHeadPos
    self.mode = WindowManager.fullscreenMode
end

return WindowManager