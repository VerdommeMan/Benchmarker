local Benchmarker = {}
Benchmarker.__index = Benchmarker

local DEFAULT_AMOUNT_OPERATIONS = 1e3
local DEFAULT_DURATION = 1 -- seconds
local DEFAULT_NO_YIELD = 0.1

local RunService = game:GetService('RunService')


local function isFunction(arg)
    return arg and type(arg) == "function"
end

local function delay(index, mod)
    return (index % (mod or 10 )) == 0 and RunService.Heartbeat:Wait() or 0
end

local function getPercentage(old, new)
    return (new - old) / old * 100   
end

function Benchmarker.new(amountOperations, duration, showProgress, convertNumbersToUnits, showFullInfo) -- set the configuration
    return setmetatable({
        duration = duration or DEFAULT_DURATION,
        operations = amountOperations or DEFAULT_AMOUNT_OPERATIONS,
        showProgress = showProgress
    }, Benchmarker)
end

function Benchmarker:compare(func1, func2, funcion1AmountArgs, ...)

    if isFunction(func1) and isFunction(func2) then
        print("Performing an comparison between function1 and function2 with: "..self.operations.." cycles and duration of "..self.duration.."s")
        local avg1, totalTime1 = self:getAvg(func1, unpack({...}, 1, funcion1AmountArgs) )
        local avg2, totalTime2 = self:getAvg(func2, select(funcion1AmountArgs+1, ...))
        print("Function1 has an average of ".. avg1 .."s per cycle and took in total "..totalTime1.."s")
        print("Function2 has an average of ".. avg2 .."s per cycle and took in total "..totalTime2.."s")
        local p = getPercentage(avg1, avg2)
        print(("Function1 average cycle is %.2f%% %s than function2!"):format(p, p < 0 and "slower" or "faster"))

    else
        error("Wrong paramaters given!")
    end
end

function Benchmarker:getAvg(func, ...)
    if isFunction(func) then
        local totalTime = 0

        for i = 1, self.operations do
            local startTime = os.clock()
            func(...)
            totalTime +=  os.clock() - startTime
            delay(i)
        end

        return totalTime / self.operations, totalTime
    else
        error("Wrong parameters given")
    end
end

function Benchmarker:getOperations(func, ...) --need better name
    if isFunction(func) then
        local amount = 0
        local totalTime = 0
        local remainder = self.duration % DEFAULT_NO_YIELD
        local loops = (self.duration - remainder) / DEFAULT_NO_YIELD
        print(self.duration, loops, remainder)

        for i = 1, loops  do
            local subTime = 0
            while subTime < DEFAULT_NO_YIELD do
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




return Benchmarker.new()