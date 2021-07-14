local Benchmark = {}

Benchmark.__index = Benchmark
Benchmark.Methods = {"Cycles", "Mean"} -- fallback
Benchmark.Status = {Queued = "Queued", Waiting = "Waiting", Running = "Running", Pauzed = "Pauzed", Completed = "Completed"}

local Data = require(script.Parent.Data)
local benchmarks = Data.Benchmarks

local Prototype = {}

function Prototype.new(config) -- #todo get stuff from config like methods
    local bindeable = Instance.new("BindableEvent") --#todo maid
    local bindeable2 = Instance.new("BindableEvent") --#todo maid
    local bindeable3 = Instance.new("BindableEvent") --#todo maid
    local self = setmetatable({
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
        Total = nil,
        Time = 0,
        _exempt = true -- prevent TableChanged from mangling this Class
    }, Benchmark)

    benchmarks.Total:insert(self)
    benchmarks.Waiting:insert(self)

    return self
end

function Benchmark:Start() -- starts the benchmark, if one is already started, it will wait until the previous to start
    if self.Status == Benchmark.Status.Waiting then
        benchmarks.Waiting:remove(benchmarks.Waiting:find(self))
        benchmarks.Queue:insert(self)
        self:_SetStatus(Benchmark.Status.Queued)
    else
        warn("Cant start this benchmark, it is already: " .. self.Status)
    end
end

function Benchmark:Cancel() -- cancels the current benchmark, puts in waiting state again #todo possible removal
    if self.Status == Benchmark.Status.Running then
        --#todo
        print("#todo")     
    elseif self.Status == Benchmark.Status.Completed then
        warn("Can't cancel a benchmark that has been completed already.") 
    elseif self.Status == Benchmark.Status.Queued then
            benchmarks.Queue:remove(benchmarks.Queue:find(self))
            benchmarks.Waiting:insert(self)
            self:_SetStatus(Benchmark.Status.Waiting)
    end
end

function Benchmark:Pauze() -- pauzes the current benchmark
    if self.Status == Benchmark.Status.Running then
        self:_SetStatus(Benchmark.Status.Pauzed)        
    else
        warn("Cant pauze this benchmark, it isn't running")
    end
end

function Benchmark:Unpauze() -- unpauzes the current benchmark
    if self.Status == Benchmark.Status.Pauzed then
        self:_SetStatus(Benchmark.Status.Running)
    else
        warn("Cant unpauze this benchmark, it isn't pauzed")
    end 
end

function Benchmark:Restart() -- possible added
    
end

function Benchmark:_SetStatus(status)
    self.Status = status
    self._StatusBindeable:Fire(status)
end

 return Prototype