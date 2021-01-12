local ServerScriptService = game:GetService('ServerScriptService')

local Benchmarker = require(ServerScriptService:WaitForChild("Benchmarker"))

local benchmark = Benchmarker.new(2, 10e3)
print(benchmark)
print(benchmark:getAvg(math.floor, 10.4144))