local ServerScriptService = game:GetService('ServerScriptService')

local Benchmarker = require(ServerScriptService:WaitForChild("Benchmarker"))
wait(5)
local benchmark = Benchmarker.new(1e1, 10, true, true, true)
local benchmark2 = Benchmarker.new(1e3, 2, false, false, false)
--print(benchmark:getAvg(math.floor, 10.4144))
--print(benchmark:getOperations(math.floor, 10.4144))
--print(Benchmarker:getOperations(math.floor, 10.4144))
--Benchmarker:benchmark(math.floor, 10.4144
-- benchmark:compare(math.floor, math.round, 1, 10.4144, 10.4144 )
-- print("######################")
-- benchmark2:compare(math.floor, math.round, 1, 10.4144, 10.4144 )
-- print("######################")
 Benchmarker:compare(math.floor, math.round, 1, 10.4144, 10.4144 )

local tbl = table.create(1e6,"t")

function testIpairs()
    for _ in ipairs(tbl) do
        
    end
end

function testPairs()
    for _ in pairs(tbl) do
        
    end
end
--benchmark:compare(testIpairs, testPairs)