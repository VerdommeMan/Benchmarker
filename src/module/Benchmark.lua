local Benchmark = {}

Benchmark.__index = Benchmark
Benchmark.Methods = {"Cycles", "Mean"} -- fallback
Benchmark.Status = {Queued = "Queued", Waiting = "Waiting", Running = "Running", Pauzed = "Pauzed", Completed = "Completed"}

local Prototype = {}

function Prototype.new(config) -- #todo get stuff from config like methods
    local bindeable = Instance.new("BindableEvent") --#todo maid
    local bindeable2 = Instance.new("BindableEvent") --#todo maid
    local bindeable3 = Instance.new("BindableEvent") --#todo maid
    return setmetatable({
        Status = Benchmark.Status.Waiting,
        StatusChanged = bindeable2.Event,
        _StatusBindeable = bindeable2,  
        Finished = bindeable.Event, 
        _FinishedBindeable = bindeable,
        ProgressChanged = bindeable3.Event,
        _ProgressBindeable = bindeable3,
        Progress = 0,
        CurrentMethod = nil,
        CurrentFunction = nil,
        TotalCompleted = 0,
        Total = nil
    }, Benchmark)
end

function Benchmark:Start() -- starts the benchmark, if one is already started, it will wait until the previous to start
    
end

function Benchmark:Cancel() -- cancels the current benchmark
    
end

function Benchmark:Pauze() -- pauzes the current benchmark
    
end

function Benchmark:Unpauze() -- unpauzes the current benchmark
    
end

return Prototype