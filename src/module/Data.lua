-- SSOT
local TableChanged = require(script.Parent.modules.TableChanged)
local Themes = require(script.Parent.gui.Theme).Themes
local Data = {}

Data.Theme = Themes["Dark"]
Data.Benchmarks = {
    Running = nil,
    Queue = {},
    Waiting = {},
    Completed = {},
    Total = {}
}


return TableChanged(Data, {Theme = true}) -- Observer pattern
