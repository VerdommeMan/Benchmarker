local BenchmarkPerformer = {}
BenchmarkPerformer.__index = BenchmarkPerformer

local Benchmarker = script.Parent
local Texts = require(Benchmarker.Texts)
local Spcall = require(Benchmarker.modules.Spcall)
local Data = require(Benchmarker.Data)
local benchmarks = Data.Benchmarks

local function getErrorPart(msg) -- removes the 'game.SSS.script:69: ' part
    return string.match(msg, ":%d+: (.*)") or msg -- in some rare cases, it only returns the errorPart already, too rare and inconsistent to find out why, but this should cover it
end

-- Due to being forced to (it was the only way) get the error with the stacktrace I need to split them back apart.
local function splitStacktrace(stacktrace)
    local lines = stacktrace:split("\n") -- can't rely on output of traceback but this should be exception safe 
    return getErrorPart(table.remove(lines, 1)), lines
end

local function printStracktrace(stacktraceLines, err) -- reconstruct a stacktrace
    warn(err)
    print("Stack Begin")
    local lines = stacktraceLines
    for i = 1, #lines - 4 do -- skipping my own funcs
        print(lines[i])
    end
    print("Stack End")
end

local errorActions = {
    ["Script timeout: exhausted allowed execution time"] = function(stacktraceLines, benchmark)
        printStracktrace(stacktraceLines, string.format("Benchmark %d function '%s': exhausted allowed execution time", benchmark.Id, benchmark.CurrentFunction))
        warn(Texts.Solutions)
        benchmark:_HasIncurredAnError()
    end,
    [Data.SPECIAL_CANCEL_FLAG] = function(_, benchmark)
        benchmark:_HasBeenCancelled()
    end,
    ["Default"] = function(stacktraceLines, benchmark, msg)
        warn(string.format("Benchmark %d function '%s': Incurred an error", benchmark.Id, benchmark.CurrentFunction))
        printStracktrace(stacktraceLines, msg) -- #TODO maybe restructure so that it can get the full error msg instead of just a part
        benchmark:_HasIncurredAnError()
    end

}

local function errorHandler(benchmark, err, stacktraceLines)
    (errorActions[err] or errorActions.Default)(stacktraceLines, benchmark, err)
end

benchmarks:keyChanged("Running", function(benchmark)
    if benchmark == nil or benchmark.Time ~= 0 then return end
    print("started performing benchmark", benchmark.Id)
    local suc, stacktrace = Spcall.xpcall(BenchmarkPerformer.perform, benchmark)
    print(suc, stacktrace)
    if not suc then
        errorHandler(benchmark, splitStacktrace(stacktrace))
    end
end)

function BenchmarkPerformer.perform(benchmark) -- #todo pcall for errros and diagnostics
    benchmark._StartTime = time()
    benchmark.Time = nil -- lets the time calc being delegated

    for key, func in pairs(benchmark.Functions) do
       benchmark.CurrentFunction = key
       
       for _, method in ipairs(benchmark.Methods) do
            benchmark.CurrentMethod = method
            benchmark.Results[method]:insert(BenchmarkPerformer["Calc" .. method.Name](benchmark, func))
            benchmark.TotalCompleted += 1   
       end
    end
    
    benchmark.Time = benchmark.Time -- looks useless but it isn't !!!
    benchmarks.Running = nil
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