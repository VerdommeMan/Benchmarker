-- SSOT
local TableChanged = require(script.Parent.TableChanged)
local Themes = require(script.Parent.gui.Theme).Themes
local Data = {}

Data.Theme = Themes["Dark"]
Data.Benchmarks = {
    Queue = {},
    Waiting = {},
    Completed = {},
    Total = {}
}


return TableChanged(Data) -- Observer pattern
