local Benchmarker = {}
Benchmarker.__index = Benchmarker

local RunService = game:GetService('RunService')

local prefixes = {"K", "M", "G", "T", "P", "E", "Z", "Y", [-1] = "m", [-2] = "μ", [-3] = "n", [-4] = "p", [-5] = "f", [-6] = "a", [-7] = "z", [-8] = "y"}

local function isFunction(arg)
    return type(arg) == "function"
end

local function isNumber(arg)
    return type(arg) == "number"
end

local function getPercentage(old, new)
    return (new - old) / old * 100   
end

function Benchmarker.new(cycles, duration, showProgress, convertNumbersToUnits, showFullInfo, noYieldTime, precision) -- set the configuration
    return setmetatable({
        duration = duration or 1,
        cycles = cycles or 1e3,
        showProgress = showProgress,
        convUnits = convertNumbersToUnits == nil and true or convertNumbersToUnits,
        showFullInfo = showFullInfo == nil and true or showFullInfo,
        noYieldTime = noYieldTime or 0.1,
        precision = precision or 3
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
    if isFunction(func) then
        local totalTime = 0
        local amount = 0
        local ops = self.cycles

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
                print(("%d%% done!"):format(amount/ops *100))
            end
        end 

        return totalTime / ops, totalTime
    else
        error("Wrong parameters given")
    end
end

function Benchmarker:getCycles(func, ...) --need better name, gets the the cycles for the set duration
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
                print(("%d%% done!"):format(i/loops *100))
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
    local returns = {}
    for _, number in ipairs({...}) do
        if isNumber(number) then
            local index = math.floor(math.log10(number) / 3)    
            if self.convUnits and index > -10 and index < 9 then
                table.insert(returns, (string.gsub(string.format("%." .. self.precision .. "f",  number / 10 ^ (index * 3)), "%.?0+$","") .. (prefixes[index] or "")))
            else
                table.insert(returns, string.format("%g", number))
            end
        else
            error("Wrong arguments given, you can give only numbers!")
        end
    end
    return unpack(returns)
end

return Benchmarker.new() -- set default config