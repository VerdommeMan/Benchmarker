local Benchmarker = {}
Benchmarker.__index = Benchmarker

wait(3) -- slows down the initial require so that the game gets time to load fully first, this allows to the benchmarks to be more accurate 

local readableNumbers = require(script:WaitForChild("ReadableNumbers")).new()

local RunService = game:GetService('RunService')

local function isFunction(arg)
    return type(arg) == "function"
end

local function areFunctions(...)
    local args = {...}
    local n = select("#", ...)

    for i = 1, n do
        if not isFunction(args[i]) then
            return false
        end
    end
    return true
end

-- these are modified to allow string-number coersion
local function isNumber(arg)
    return tonumber(arg)
end

local function isInt(arg)
    return isNumber(arg) and tonumber(arg) == math.floor(arg)
end

local function getPercentage(old, new)
    return (new - old) / old * 100   
end

function Benchmarker.new(cycles, duration, showProgress, showFullInfo, ReadableNumbers, noYieldTime) -- set the configuration
     -- set defaults
    duration = duration or 1
    cycles = cycles or 1e3
    showFullInfo = showFullInfo == nil and true or showFullInfo -- defaults to true
    ReadableNumbers = ReadableNumbers == nil and readableNumbers or ReadableNumbers 
    noYieldTime = noYieldTime or 0.1
    -- type checking
    assert(isInt(cycles), "Wrong argument given for cycles, expected integer but received " .. typeof(cycles))
    assert(isNumber(duration), "wrong argument given for duration, expected a number but received " .. typeof(duration))
    assert(ReadableNumbers == false or ReadableNumbers.format, "Wrong argument given for readableNumbers, expected false/ReadableNumbers object but received " .. typeof(ReadableNumbers))
    assert(isNumber(noYieldTime), "Wrong argument given for noYieldTime, expected number but received " .. typeof(noYieldTime))

    return setmetatable({
        duration = duration,
        cycles = cycles,
        showProgress = showProgress,
        showFullInfo = showFullInfo,
        readableNumbers = ReadableNumbers,
        noYieldTime = noYieldTime
    }, Benchmarker)
end

function Benchmarker:compare(func1, func2, function1AmountArgs, ...)
    function1AmountArgs = function1AmountArgs or 0
    assert(areFunctions(func1, func2), "Wrong argument given for func1/func2, expected functions but received " .. typeof(func1) .. " and " .. typeof(func2))
    assert(isInt(function1AmountArgs), "Wrong argument given for funcion1AmountArgs, expected integer but received " .. typeof(func1)  )

    self:print(("Performing a comparison between function1 and function2 with %s cycles and a duration of %ss"):format(self:toReadable(self.cycles, self.duration)))
    local avg1, totalTime1 = self:getAvg(func1, unpack({...}, 1, function1AmountArgs) )
    self:print(("Function1 has an average of %ss per cycle and took in total %ss"):format(self:toReadable(avg1, totalTime1)))
    local avg2, totalTime2 = self:getAvg(func2, select(function1AmountArgs + 1, ...))
    self:print(("Function2 has an average of %ss per cycle and took in total %ss"):format(self:toReadable(avg2, totalTime2)))
    local p = getPercentage(avg1, avg2)
    print(("Function1 average cycle is %.2f%% %s than function2!"):format(p, p < 0 and "slower" or "faster"))
    
    local totalAmount1, amountPerS1 = self:getCycles(func1, unpack({...}, 1, function1AmountArgs))
    self:print(("function1 was called %s times (%s/s)"):format(self:toReadable(totalAmount1, amountPerS1)))
    local totalAmount2, amountPerS2 = self:getCycles(func2, select(function1AmountArgs + 1, ...))
    self:print(("function2 was called %s times (%s/s)"):format(self:toReadable(totalAmount2, amountPerS2)))
    local p2 = getPercentage( amountPerS2, amountPerS1)
    print(("Function1 has %.2f%% %s cycles/s than function2!"):format(p2, p2 < 0 and "less" or "more"))
end

function Benchmarker:getAvg(func, ...)
    assert(isFunction(func), "Wrong argument given for func, expected function but received " .. typeof(func))

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
    assert(isFunction(func), "Wrong argument given for func, expected function but received " .. typeof(func))

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
    
    return amount, amount / totalTime, totalTime 
end

function Benchmarker:benchmark(func, ...)
    assert(isFunction(func), "Wrong argument given for func, expected function but received " .. typeof(func))

    self:print(("Performing a benchmark with %s cycles and a duration of %ss"):format(self:toReadable(self.cycles, self.duration)))
    print(("The function took on average %ss per cycle and took in total %ss"):format(self:toReadable(self:getAvg(func, ...))))
    print(("The function was called %s times (%s/s) for the given duration %ss "):format(self:toReadable(self:getCycles(func, ...))))
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