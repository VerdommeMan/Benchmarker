local Stats = {}
Stats.order = {"Name","mean", "std", "min", "25%", "50%", "75%", "max"}

function Stats.calc(arr)
    table.sort(arr)  
    local results = {}
    for _, stat in ipairs(Stats.order) do
        results[stat] = Stats[stat](arr)
    end
    return results
end

function Stats.std(arr)
    local sum, mean = 0, Stats.mean(arr)
    for _, nr in ipairs(arr) do
       sum += (nr - mean)^2
    end
    return sum / #arr
end

function Stats.min(arr)
    return arr[1]
end

function Stats.max(arr)
    return arr[#arr]
end

function Stats.mean(arr)
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
    Stats.percentile(arr, 0.25)
end

Stats["50%"] = function(arr)
    Stats.percentile(arr, 0.5)
end

Stats["75%"] = function(arr)
    Stats.percentile(arr, 0.75)
end

function Stats.Name(arr)
    return arr.Name
end

return Stats