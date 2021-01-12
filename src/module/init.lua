local Benchmarker = {}
Benchmarker.__index = Benchmarker

local DEFAULT_AMOUNT_OPERATIONS = 1e6
local DEFAULT_DURATION = 1 -- seconds
local STEP = 0.1

local RunService = game:GetService('RunService')


local function isFunction(arg)
    return arg and type(arg) == "function"
end

local function delay(index, mod)
    return (index % (mod or 10 )) == 0 and RunService.Heartbeat:Wait() or 0
end

function Benchmarker.new(amountOperations, duration, showProgress) -- set the configuration
    return setmetatable({
        duration = duration or DEFAULT_DURATION,
        operations = amountOperations or DEFAULT_AMOUNT_OPERATIONS,
        showProgress = showProgress
    }, Benchmarker)
end

function Benchmarker.compare(funcion1, function2, funcion1AmountArgs, ...)
   

    if isFunction(funcion1) and isFunction(function2) then
        
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

function Benchmarker:getOperations(func, ...)
    if isFunction(func) then
        local amount = 0
        local totalTime = 0
        local remainder = self.duration % STEP
        local loops = (self.duration - remainder) / STEP
        print(self.duration, loops, remainder)

        for i = 1, loops  do
            local subTime = 0
            while subTime < STEP do
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




return Benchmarker.new()