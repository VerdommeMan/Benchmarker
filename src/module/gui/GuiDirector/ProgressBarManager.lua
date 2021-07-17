local ProgressBarManager = {}
ProgressBarManager.__index = ProgressBarManager

function ProgressBarManager.new(bar)
    return setmetatable({_bar = bar}, ProgressBarManager)
end

function ProgressBarManager:show()
    self._bar.Visible = true
end

function ProgressBarManager:hide()
    self._bar.Visible = false
end

function ProgressBarManager:_setProgress(alpha)
    self._bar.base.Clipper.Size = UDim2.fromScale(math.clamp(alpha, 0, 1), 1)
end

function ProgressBarManager:setTotal(current, total)
    self._bar.base.parts.Text = current .. "/" .. total
end

function ProgressBarManager:setLabel(methodName, func, progress)
    self._bar.base.SubTotal.Text = string.format("%s %s: %2i%%", methodName, func, progress * 100)
    self:_setProgress(progress)
end

return ProgressBarManager