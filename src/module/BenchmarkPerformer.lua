local BenchmarkPerformer = {}
BenchmarkPerformer.__index = BenchmarkPerformer

local Data = require(script.Parent.Data)
local benchmarks = Data.Benchmarks

benchmarks:keyChanged("CurrentBenchmark", function(benchmark)
    coroutine.wrap(function()
        if benchmark ~= nil then
            benchmark:_SetStatus("Running")
            print("called perform")
            BenchmarkPerformer.perform(benchmark)        
        end
    end)()
end)

function BenchmarkPerformer.perform(benchmark) -- #todo pcall for errros and diagnostics
    for key, func in pairs(benchmark.Functions) do
       benchmark.CurrentFunction = key
       
       for _, method in ipairs(benchmark.Methods) do
            benchmark.CurrentMethod = method
            benchmark.Results[method]:insert(BenchmarkPerformer["Calc" .. method.Name](benchmark, func))
            print("Benchmark performed for ", key , func) 
            benchmark.TotalCompleted += 1   
       end
    end
    benchmark:_SetStatus("Completed")
    benchmarks.CurrentBenchmark = nil
    benchmarks.Completed:insert(benchmark)
end

function BenchmarkPerformer.CalcCycles(benchmark, func) -- Calc Cyles for a given duration
    local totalTime = 0
    local amount = 0
    local duration = benchmark.Duration

    while totalTime < duration do
        local subTime = 0
        while subTime < Data.noYieldTime and totalTime + subTime < duration do
            local startTime = os.clock()
            func()
            subTime +=  os.clock() - startTime
            amount += 1
        end
        benchmark:_Pauze()
        totalTime += subTime
        benchmark:_SetProgress(totalTime / duration)
    end

    return {amount, Name = benchmark.CurrentFunction}
end

function BenchmarkPerformer.CalcDuration(benchmark, func) -- calc the duration for the a given amount of cycles
    local amount = 0
    local totalTime = 0
    local results = {Name = benchmark.CurrentFunction}
    local cycles = benchmark.Cycles

    while amount < cycles do
        local subTime = 0
        while subTime < Data.noYieldTime and amount < cycles do
            local startTime = os.clock()
            func()
            local diff = os.clock() - startTime
            subTime += diff
            table.insert(results, diff)
            amount += 1
        end
        benchmark:_Pauze()
        totalTime += subTime
        benchmark:_SetProgress(amount / cycles)
    end
    
    return results
end


return BenchmarkPerformer