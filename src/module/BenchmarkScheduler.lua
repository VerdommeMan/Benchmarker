-- Schedules the next benchmark to be run
-- might be expanded to let other benchmarks run when the current is pauzed
-- Uses the SSOT to determine the status of the benchmarks

local Data = require(script.Parent.Data)
local benchmarks = Data.Benchmarks
local queue = benchmarks.Queued

benchmarks.Total:added(function(benchmark) -- assumes only being added to last position
    benchmarks.Waiting:insert(benchmark)
end)

local statusSetters = {"Waiting", "Queued", "Errored" , "Pauzed", "Completed"}

for _, status in ipairs(statusSetters) do
    benchmarks[status]:added(function(benchmark) -- #TODO think one day abt clean up
        print("Added has fired for benchmark ", benchmark.Id, " for status ", status)
        benchmark:_SetStatus(status)
    end)
end

queue:changed(function()
    if not benchmarks.Running and queue:len() > 0 then
        benchmarks.Running = table.remove(queue._tbl, 1)
    end
end)

benchmarks:keyChanged("Running", function(benchmark)
    if benchmark == nil and queue:len() > 0 then
        benchmarks.Running = table.remove(queue._tbl, 1)     
    end
    if benchmark then
        benchmark:_SetStatus("Running")
    end 
end)

return true