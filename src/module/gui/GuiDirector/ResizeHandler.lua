local function getWidth(gui)
	return gui.AbsolutePosition.X + gui.AbsoluteSize.X
end

local function getWidthBetween(gui, guiParent)
	return math.abs(getWidth(gui) - getWidth(guiParent))
end

return function (root, stats)
    local background = root.Background
    local nextBtn = background.Content.VerticalList.Controls.Next
    local atTop = false

    background:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() 
        local width = getWidthBetween(nextBtn, background)
        
        if width > 130 and not atTop then
            atTop = true
            stats.Parent = background.StatHolder
        elseif width < 130 and atTop then
            stats.Parent = background.Content.VerticalList
            atTop = false
        end
    end)
    stats.Parent = background.Content.VerticalList
end