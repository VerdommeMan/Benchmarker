local BenchmarkPerformer = {}
BenchmarkPerformer.__index = BenchmarkPerformer

local Benchmarker = script.Parent
local Texts = require(Benchmarker.Texts)
local Data = require(Benchmarker.Data)
local benchmarks = Data.Benchmarks

local function printStracktrace(thread, err) -- reconstruct a stacktrace
    warn(err)
    print("Stack Begin")
    local lines = debug.traceback(thread):split("\n") -- can't rely on output of traceback but this should be exception safe
    for i = 1, #lines - 3 do -- skipping built in funcs
        print(lines[i])
    end
    print("Stack End")
end

do -- saving this code temporariliy to detect and catch time out errors
    local isTimeoutError = math.random(1,3) == 2 -- 50% to generate the error for testing purposes
    local thread

    task.spawn(function() -- order 1
        task.defer(function() 
            thread = coroutine.running() -- order 3
            task.spawn(function() 
                -- code
                while isTimeoutError do

                end
            end)
            coroutine.yield() -- errors when timeout error cascades or yield if the above doesnt have that error
        end)
        coroutine.yield() -- prevents the time out error from cascading, it cant cascade it in suspneded threads
    end)
    task.wait() -- order 2
    print(coroutine.status(thread)) -- order 6, reading the status of the thread that potential has errored through the cascade
    print("working")

end

local errorActions = {
    ["Script timeout: exhausted allowed execution time"] = function(thread, benchmark)
        printStracktrace(thread, string.format("Benchmark %d: exhausted allowed execution time", benchmark.Id))
        warn(Texts.Solutions)
    end,
    [Data.SPECIAL_CANCEL_FLAG] = function(_, benchmark)
        benchmark:_HasBeenCancelled()
    end,
    ["Default"] = function(thread, benchmark, msg)
        warn(string.format("Benchmark %s: Incurred an error", benchmark.Id))
        printStracktrace(thread, msg)
    end

}

game:GetService("ScriptContext").Error:Connect(function(msg, stacktrace, instance)
    print(instance:GetFullName().." errored!")
	print("Reason: "..msg)
	print("Trace: "..stacktrace)
    
end)

local function errorHandler(thread, err, benchmark)
    print("received this msg", err);
    (errorActions[err] or errorActions.Default)(thread, benchmark, err)
end

benchmarks:keyChanged("CurrentBenchmark", function(benchmark)
    task.spawn(function() -- needed bc it doesnt call each listener in a seperate thread, thus not using a thread here, will put the ohters from being called
        if benchmark ~= nil then
            benchmark:_SetStatus("Running")
            print("started performing")
            -- local cor = coroutine.create(BenchmarkPerformer.perform)
            -- local success, msg = coroutine.resume(cor, benchmark)
            -- print("have failed? ", success, msg)
            -- warn("doesnt even get here")
            -- if not success then
            --     errorHandler(cor, msg, benchmark)
            -- end

            task.spawn(function()
                BenchmarkPerformer.perform(benchmark)
            end)
        end     
    end)
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