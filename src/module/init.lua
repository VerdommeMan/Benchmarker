local Benchmarker = {}
Benchmarker.__index = Benchmarker

local DEFAULT_AMOUNT_OPERATIONS = 10e9
local DEFAULT_DURATION = 3 -- seconds

local function isFunction(arg)
    return arg and type(arg) == "function"
end

function Benchmarker.new(amountOperations, duration) -- set the configuration
    return setmetatable({
        duration = duration or DEFAULT_DURATION,
        operations = amountOperations or DEFAULT_AMOUNT_OPERATIONS
    }, Benchmarker)
end

function Benchmarker.benchmark(funcion1, function2, funcion1AmountArgs, ...)
   

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
            if i % 10 then
                wait()
            end
        end

        return totalTime / self.operations, totalTime
    else
        error("Wrong parameters given")
    end  
end


return Benchmarker