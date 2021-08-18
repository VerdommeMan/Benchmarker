-- Schedules the next benchmark to be run
-- might be expanded to let other benchmarks run when the current is pauzed
local Data = require(script.Parent.Data)
local benchmarks = Data.Benchmarks
local queue = benchmarks.Queue

queue:exempt():changed(function()
    if not benchmarks.CurrentBenchmark and queue:len() > 0 then
        benchmarks.CurrentBenchmark = table.remove(queue._tbl, 1)
    end
end)

benchmarks:keyChanged("CurrentBenchmark", function(newVal)
    if newVal == nil and queue:len() > 0 then
        benchmarks.CurrentBenchmark = table.remove(queue._tbl, 1)     
    end 
end)

return true