local BenchmarkPerformer = {}
BenchmarkPerformer.__index = BenchmarkPerformer

local RunService = game:GetService("RunService")
local Data = require(script.Parent.Data)
local benchmarks = Data.Benchmarks

benchmarks:keyChanged("CurrentBenchmark", function(benchmark)
    if benchmark ~= nil then
        benchmark:_setStatus("Running")
        BenchmarkPerformer.perform(benchmark)        
    end
end)

function BenchmarkPerformer.perform(benchmark) -- #todo pcall for errros and diagnostics
    for key, func in pairs(benchmark.Functions) do
       benchmark.CurrentFunction = key
       
       for _, method in ipairs(benchmark.Methods) do
            benchmark.CurrentMethod = method
            benchmark.Results[key]:insert(BenchmarkPerformer["Calc" .. method](benchmark, func)) 
            benchmark.TotalCompleted += 1   
       end
    end
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
        RunService.Heartbeat:Wait()
        totalTime += subTime
        benchmark:_setProgress(totalTime / duration)
    end

    return {amount}
end

function BenchmarkPerformer.CalcDuration(benchmark, func) -- calc the duration for the a given amount of cycles
    local amount = 0
    local totalTime = 0
    local results = {}
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
        RunService.Heartbeat:Wait()
        totalTime += subTime
        benchmark:_setProgress(amount / cycles)
    end
    
    return results
end


return BenchmarkPerformer