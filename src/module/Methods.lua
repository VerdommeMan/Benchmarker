-- This module describes the methods
local Formatter = require(script.Parent.modules.ReadableNumbers)

return {
    {
        Name = "Cycles",
        Description = "Returns the amount of cycles it ran for a given duration.",
        Columns = {"Name", "Cycles"},
        Formatter = Formatter.new()
    },
    {
        Name = "Duration",
        Description = "Returns the duration for a cycle.",
        Columns = {"Name","Mean", "STD", "Min", "25%", "50%", "75%", "Max"},
        Formatter = Formatter.new(2, true, " ", "SI", "s") 
    }
}