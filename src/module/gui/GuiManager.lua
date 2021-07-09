-- OOP bc i might have multipe UIs

local GuiManager = {}
GuiManager.__index = GuiManager

function GuiManager.new(gui)
    return setmetatable({root = gui}, GuiManager)
end



function GuiManager:Destroy()
    self.root:Destroy()
end


return GuiManager