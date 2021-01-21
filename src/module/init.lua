local Benchmarker = {}
Benchmarker.__index = Benchmarker

local readableNumbers = require(script:WaitForChild("ReadableNumbers")).new()

local RunService = game:GetService('RunService')

local function isFunction(arg)
    return type(arg) == "function"
end

local function isNumber(arg)
    return type(arg) == "number"
end

local function getPercentage(old, new)
    return (new - old) / old * 100   
end

function Benchmarker.new(cycles, duration, showProgress, showFullInfo, ReadableNumbers, noYieldTime) -- set the configuration
    return setmetatable({
        duration = duration or 1,
        cycles = cycles or 1e3,
        showProgress = showProgress,
        showFullInfo = showFullInfo == nil and true or showFullInfo,
        readableNumbers = ReadableNumbers == nil and readableNumbers or ReadableNumbers ,
        noYieldTime = noYieldTime or 0.1,
    }, Benchmarker)
end

function Benchmarker:compare(func1, func2, funcion1AmountArgs, ...)
    if isFunction(func1) and isFunction(func2) then

        self:print(("Performing a comparison between function1 and function2 with %s cycles and a duration of %ss"):format(self:toReadable(self.cycles, self.duration)))
        local avg1, totalTime1 = self:getAvg(func1, unpack({...}, 1, funcion1AmountArgs) )
        self:print(("Function1 has an average of %ss per cycle and took in total %ss"):format(self:toReadable(avg1, totalTime1)))
        local avg2, totalTime2 = self:getAvg(func2, select((funcion1AmountArgs or 0) + 1, ...))
        self:print(("Function2 has an average of %ss per cycle and took in total %ss"):format(self:toReadable(avg2, totalTime2)))
        local p = getPercentage(avg1, avg2)
        print(("Function1 average cycle is %.2f%% %s than function2!"):format(p, p < 0 and "slower" or "faster"))
        
        local totalAmount1, _, amountPerS1 = self:getCycles(func1, ...)
        self:print(("function1 was called %s times (%s/s)"):format(self:toReadable(totalAmount1, amountPerS1)))
        local totalAmount2, _, amountPerS2 = self:getCycles(func2, ...)
        self:print(("function2 was called %s times (%s/s)"):format(self:toReadable(totalAmount2, amountPerS2)))
        local p2 = getPercentage( amountPerS2, amountPerS1)
        print(("Function1 has %.2f%% %s cycles/s than function2!"):format(p2, p2 < 0 and "less" or "more"))
    else
        error("Wrong paramaters given!")
    end
end

function Benchmarker:getAvg(func, ...)
    assert(isFunction(func), "Wrong parameters given")
    local amount = 0
    local totalTime = 0

    if self.showProgress then
        print("Calculating average cycle")
    end

    while amount < self.cycles do
        local subTime = 0
        while subTime < self.noYieldTime and amount < self.cycles do
            local startTime = os.clock()
            func(...)
            subTime +=  os.clock() - startTime
            amount += 1
        end
        RunService.Heartbeat:Wait()
        totalTime += subTime

        if self.showProgress then
            print(("%d%% done!"):format(amount / self.cycles * 100))
        end
    end 

    return totalTime / self.cycles, totalTime
end

function Benchmarker:getCycles(func, ...) --need better name, gets the the cycles for the set duration
    assert(isFunction(func), "Wrong parameters given")
    local amount = 0
    local totalTime = 0

    if self.showProgress then
        print("Calculating amount of cycles for the given duration")
    end

    while totalTime < self.duration do
        local subTime = 0
        while subTime < self.noYieldTime and totalTime + subTime < self.duration do
            local startTime = os.clock()
            func(...)
            subTime +=  os.clock() - startTime
            amount += 1
        end
        RunService.Heartbeat:Wait()
        totalTime += subTime

        if self.showProgress then
            print(("%d%% done!"):format(totalTime/self.duration *100))
        end
    end
    
    return amount, totalTime, amount / self.duration
end

function Benchmarker:benchmark(func, ...)
    if isFunction(func) then
        self:print(("Performing a benchmark with %s cycles and a duration of %ss"):format(self:toReadable(self.cycles, self.duration)))
        print(("The function took on average: %ss and took in total: %ss"):format(self:toReadable(self:getAvg(func, ...))))
        print(("The function was called %s times in %ss (%s/s)"):format(self:toReadable(self:getCycles(func, ...))))
    else
        error("Wrong parameters given")
    end  
end

function Benchmarker:print(...)
    if self.showFullInfo then
        print(...)
    end
end

function Benchmarker:toReadable(...)
    if self.readableNumbers then
        return self.readableNumbers:format(...)
    end
    return ...
end

return Benchmarker.new() -- set default config