local ServerScriptService = game:GetService('ServerScriptService')

local Benchmarker = require(ServerScriptService:WaitForChild("Benchmarker"))

local benchmark = Benchmarker.new(1e3, 10, true)
print(benchmark:getAvg(math.floor, 10.4144))
--print(benchmark:getOperations(math.floor, 10.4144))
--print(Benchmarker:getOperations(math.floor, 10.4144))
--Benchmarker:benchmark(math.floor, 10.4144)
--Benchmarker:compare(math.floor, math.round, 1, 10.4144, 10.4144 )
--benchmark:compare(math.floor, math.round, 1, 10.4144, 10.4144 )