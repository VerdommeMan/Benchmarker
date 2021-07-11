-- SSOT
local TableChanged = require(script.Parent.TableChanged)
local Data = {}

Data.Theme = "Dark"
Data.Benchmarks = {
    Queue = {},
    Waiting = {},
    Completed = {},
    Total = {}
}


return TableChanged(Data) -- Observer pattern
