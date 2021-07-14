-- Schedules the next benchmark to be run
-- might be expanded to let other benchmarks run when the current is pauzed
local Data = require(script.Parent.Data)
local Benchmarks = Data.Benchmarks
local queue = Benchmarks.Queue

queue:exempt():changed(function()
    if not Benchmarks.CurrentBenchmark then
        Benchmarks.CurrentBenchmark = table.remove(queue._tbl, 1)
    end
end)

Benchmarks:keyChanged("CurrentBenchmark", function(newVal)
   if newVal == nil and queue:len() > 0 then
        Benchmarks.CurrentBenchmark = table.remove(queue._tbl, 1)     
   end 
end)