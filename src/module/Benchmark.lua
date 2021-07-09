local Benchmark = {}
Benchmark.__index = Benchmark

local Prototype = {}

function Prototype.new()
    local bindeable = Instance.new("BindableEvent")
    return setmetatable({Status = "queued", Finished = bindeable.Event, _Bindeable = bindeable}, Benchmark)
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