local ServerScriptService = game:GetService('ServerScriptService')

local Benchmarker = require(ServerScriptService:WaitForChild("Benchmarker"))

local benchmark = Benchmarker.new(1e3, 2, true)
--print(benchmark:getAvg(math.floor, 10.4144))
print(benchmark:getOperations(math.floor, 10.4144))
print(Benchmarker:getOperations(math.floor, 10.4144))