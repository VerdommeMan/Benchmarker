-- This module describes the methods
local Formatter = require(script.Parent.modules.ReadableNumbers)

return {
    {
        Name = "Cycles",
        Description = "Returns the amount of cycles it ran for a given duration.",
        Columns = {"Name", "cycles"},
        Formatter = Formatter.new()
    },
    {
        Name = "Duration",
        Description = "Returns the duration for a cycle.",
        Columns = {"Name","mean", "std", "min", "25%", "50%", "75%", "max"},
        Formatter = Formatter.new(2, true, " ", "SI", "s") 
    }
}