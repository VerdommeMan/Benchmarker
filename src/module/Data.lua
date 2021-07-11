-- Easiest way of doing Observer pattern, source of truth

local Themes = require(script.Parent.gui.Theme)

local Data = {}

Data.Theme = Themes["Dark"]

return Data
