-- SSOT
local TableChanged = require(script.Parent.modules.TableChanged)
local Themes = require(script.Parent.gui.Theme).Themes
local Data = {}
Data.SPECIAL_CANCEL_FLAG = "BENCHMARK HAS BEEN CANCELLED"
Data.noYieldTime = 0.1 -- #todo add config
Data.Version = "2.0.0"
Data.Theme = Themes["Dark"]
Data.Benchmarks = {
    Running = nil,
    Pauzed = {},
    Queued = {},
    Waiting = {},
    Errored = {},
    Completed = {},
    Total = {}
}




return TableChanged(Data, {Theme = true})