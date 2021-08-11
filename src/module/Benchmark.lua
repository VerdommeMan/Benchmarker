local Benchmark = {}

Benchmark.Status = {Queued = "Queued", Waiting = "Waiting", Running = "Running", Pauzed = "Pauzed", Completed = "Completed"}
Benchmark.ReservedKeywords = {"Duration", "Cycles", "Methods"} -- possibly be stored in Method description too, to prevent duplication

local modules = script.Parent.modules 
local TableChanged = require(modules.TableChanged)
local Methods = require(script.Parent.Methods)
local Data = require(script.Parent.Data)
local benchmarks = Data.Benchmarks

local function verifyMethods(methods)
    if methods == nil or #methods == 0 then
        return Methods
    end

    local foundMethods = {}

    for i, methodName in ipairs(methods) do
        for _, method in ipairs(Methods) do
            if methodName:lower() == method.Name:lower() then -- will be case insenstive
                foundMethods[i] = method
            end
        end
        if not foundMethods[i] then
            error("A method with name '" .. methodName .. "' doesn't exist!")
        end
    end

    return foundMethods
end

local function removeReservedKeywords(config)
    for _, keyword in ipairs(Benchmark.ReservedKeywords) do
        config[keyword] = nil        
    end
    return config
end

local function countDict(dict)
    local count = 0
    for _ in pairs(dict) do
        count +=1
    end
    return count
end

local function getTemplateResults(methods)
    local results = {}
    for _, method in ipairs(methods) do
        results[method] = TableChanged({})
    end
    return results
end

local function calcTime(startTime)
    return time() - startTime
end

-- allows for special functionality, it calcs the time when requested only when the benchmark is running
Benchmark.__index = function(t , k)
    if k == "Time" then
        print("calcing time")
        return calcTime(t._StartTime)
    end
    return Benchmark[k]
end

local id = 1
local Prototype = {} -- using a prototype so that the users cant access the constructor

function Prototype.new(config) -- #todo get stuff from config like methods
    local bindeable = Instance.new("BindableEvent") --#todo maid
    local bindeable2 = Instance.new("BindableEvent") --#todo maid
    local bindeable3 = Instance.new("BindableEvent") --#todo maid
    local self = setmetatable({
        Methods = verifyMethods(config.Methods),
        Cycles = config.Cycles or 1000,
        Duration = config.Duration or 1,
        Functions = removeReservedKeywords(config),
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
        Time = 0,
        Id = id,
        _exempt = true -- prevent TableChanged from mangling this Class
    }, Benchmark)

    self.Total = countDict(self.Functions) * #self.Methods
    self.Results = getTemplateResults(self.Methods)
    benchmarks.Total:insert(self)
    benchmarks.Waiting:insert(self)
    self:_initFinished()
    
    id += 1

    return self
end

function Benchmark:Start() -- starts the benchmark, if one is already started, it will wait until the previous to start
    if self.Status == Benchmark.Status.Waiting then
        benchmarks.Waiting:findThenRemove(self)
        self:_SetStatus(Benchmark.Status.Queued)
        benchmarks.Queue:insert(self)
    else
        warn("Cant start this benchmark, it is already: " .. self.Status)
    end
end

function Benchmark:Cancel() -- cancels the current benchmark, puts in waiting state again #todo possible removal
    if self.Status == Benchmark.Status.Running then
        self._Cancelling = true
    elseif self.Status == Benchmark.Status.Completed then
        warn("Can't cancel a benchmark that has been completed already.") 
    elseif self.Status == Benchmark.Status.Queued then
            benchmarks.Queue:findThenRemove(self)
            self:_SetStatus(Benchmark.Status.Waiting)
            benchmarks.Waiting:insert(self)
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
    if self.Status == Benchmark.Status.Completed then
        self:_Reset()
        benchmarks.Completed:findThenRemove(self)
        self:_SetStatus(Benchmark.Status.Queued)
        benchmarks.Queue:insert(self)
    else
        warn("Benchmark must be completed first in order to restart it!")
    end
end

function Benchmark:_SetStatus(status)
    self.Status = status
    self._StatusBindeable:Fire(status)
end

function Benchmark:_SetProgress(progress)
    self.Progress = progress
    self._ProgressBindeable:fire(progress)
end

function Benchmark:_Pauze()
    if self._Cancelling then
        self._Cancelling = nil
        error(Data.SPECIAL_CANCEL_FLAG) -- must be executed inside the thread which performs the benchmark
    elseif self.Status == Benchmark.Status.Pauzed then
        self.StatusChanged:Wait()
    else
        task.wait()
    end
end

function Benchmark:_Reset()
    self.Time = 0
    self.Progress = 0
    self.TotalCompleted = 0
    self.Results = getTemplateResults(self.Methods)
end

function Benchmark:_HasBeenCancelled()
    self:_Reset()
    benchmarks.Runnning:findThenRemove(self)
    self:_SetStatus(Benchmark.Status.Waiting)
    benchmarks.Waiting:insert(self)
end

-- #todo maid on conn
function Benchmark:_initFinished() 
    self.StatusChanged:Connect(function(status)
        if status == Benchmark.Status.Completed then
            self._FinishedBindeable:Fire()
        end
    end)
end

 return Prototype