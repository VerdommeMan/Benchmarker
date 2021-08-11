-- Defines the function for each column in the Methods module
local Stats = {}

function Stats.calc(arr, method)
    table.sort(arr)  
    local results = {}
    for i, stat in ipairs(method.Columns) do
        results[i] = i ~= 1 and method.Formatter:format(Stats[stat](arr)) or Stats[stat](arr) 
    end
    return results
end

function Stats.STD(arr)
    local sum, mean = 0, Stats.Mean(arr)
    for _, nr in ipairs(arr) do
       sum += (nr - mean)^2
    end
    return (sum / #arr) ^ 0.5
end

function Stats.Min(arr)
    return arr[1]
end

function Stats.Max(arr)
    return arr[#arr]
end

function Stats.Mean(arr)
    local sum = 0
    for _, nr in ipairs(arr) do
        sum += nr
    end
    return sum / #arr
end

function Stats.percentile(arr, percent)
    return arr[math.floor(percent * #arr)]
end

Stats["25%"] = function(arr)
    return Stats.percentile(arr, 0.25)
end

Stats["50%"] = function(arr)
    return Stats.percentile(arr, 0.5)
end

Stats["75%"] = function(arr)
    return Stats.percentile(arr, 0.75)
end

function Stats.Name(arr)
    return arr.Name
end

function Stats.Cycles(arr)
    return arr[1]
end

return Stats