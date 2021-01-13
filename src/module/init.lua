local Benchmarker = {}
Benchmarker.__index = Benchmarker

local DEFAULT_AMOUNT_OPERATIONS = 1e3
local DEFAULT_DURATION = 1 -- seconds
local DEFAULT_NO_YIELD_TIME = 0.1

local RunService = game:GetService('RunService')


local function isFunction(arg)
    return arg and type(arg) == "function"
end

local function getPercentage(old, new)
    return (new - old) / old * 100   
end

function Benchmarker.new(amountOperations, duration, showProgress, convertNumbersToUnits, showFullInfo, noYieldTime) -- set the configuration
    return setmetatable({
        duration = duration or DEFAULT_DURATION,
        operations = amountOperations or DEFAULT_AMOUNT_OPERATIONS,
        showProgress = showProgress,
        showFullInfo = showFullInfo == nil and true or showFullInfo,
        noYieldTime = noYieldTime or DEFAULT_NO_YIELD_TIME
    }, Benchmarker)
end

function Benchmarker:compare(func1, func2, funcion1AmountArgs, ...)
    if isFunction(func1) and isFunction(func2) then
        self:print("Performing an comparison between function1 and function2 with: "..self.operations.." cycles and a duration of "..self.duration.."s")
        local avg1, totalTime1 = self:getAvg(func1, unpack({...}, 1, funcion1AmountArgs) )
        self:print("Function1 has an average of ".. avg1 .."s per cycle and took in total "..totalTime1.."s")
        local avg2, totalTime2 = self:getAvg(func2, select((funcion1AmountArgs or 0)+1, ...))
        self:print("Function2 has an average of ".. avg2 .."s per cycle and took in total "..totalTime2.."s")
        local p = getPercentage(avg1, avg2)
        print(("Function1 average cycle is %.2f%% %s than function2!"):format(p, p < 0 and "slower" or "faster"))
        
        local totalAmount1, _, amountPerS1 = self:getOperations(func1, ...)
        self:print("function1 was called ", totalAmount1, "times (".. amountPerS1.."/s)")
        local totalAmount2, _, amountPerS2 = self:getOperations(func2, ...)
        self:print("function2 was called ", totalAmount2, "times (".. amountPerS2.."/s)")
        local p2 = getPercentage( amountPerS2, amountPerS1)
        print(("Function1 has %.2f%% %s cycles/s than function2!"):format(p2, p2 < 0 and "less" or "more"))
    else
        error("Wrong paramaters given!")
    end
end

function Benchmarker:getAvg(func: number, ...)
    if isFunction(func) then
        local totalTime = 0
        local amount = 0
        local ops = self.operations

        if self.showProgress then
            print("Calculating average cycle")
        end

        while amount < ops do
            local subTime = 0
            while subTime < self.noYieldTime and amount < ops do
                local startTime = os.clock()
                func(...)
                subTime +=  os.clock() - startTime
                amount += 1
            end
            totalTime += subTime
            RunService.Heartbeat:Wait()
            if self.showProgress then
                print(("Percent %d%% done!"):format(amount/ops *100))
            end
        end 

        return totalTime / ops, totalTime
    else
        error("Wrong parameters given")
    end
end

function Benchmarker:getOperations(func, ...) --need better name
    if isFunction(func) then
        local amount = 0
        local totalTime = 0
        local remainder = self.duration % self.noYieldTime
        local loops = (self.duration - remainder) / self.noYieldTime

        if self.showProgress then
            print("Calculating amount of cycles for the given duration")
        end

        for i = 1, loops  do
            local subTime = 0
            while subTime < self.noYieldTime do
                local startTime = os.clock()
                func(...)
                subTime +=  os.clock() - startTime
                amount += 1
            end
            totalTime += subTime
            RunService.Heartbeat:Wait()
            if self.showProgress then
                print(("Percent %d%% done!"):format(i/loops *100))
            end
        end

        local subTime = 0

        RunService.Heartbeat:Wait()
        while subTime < remainder do
            local startTime = os.clock()
            func(...)
            subTime +=  os.clock() - startTime
            amount += 1
        end
        totalTime += subTime
       
        return amount, totalTime, amount / self.duration
    else
        error("Wrong parameters given")
    end  
end

function Benchmarker:benchmark(func, ...)
    if isFunction(func) then
        local avg, totalTime = self:getAvg(func, ...)
        print("The function took on average: ", avg, "s and took in total: ", totalTime, "s with ", self.operations, " cycles")
        local totalAmount, time, amountPerS = self:getOperations(func, ...)
        print("The function was called ", totalAmount, "times in ", time, "s (".. amountPerS.."/s)")
    else
        error("Wrong parameters given")
    end  
end

function Benchmarker:print(...)
    if self.showFullInfo then
        print(...)
    end
end



return Benchmarker.new()