-- @Author: VerdommeMan, see https://github.com/VerdommeMan/Benchmarker for more information 
-- @Version: 2.0.0

local Benchmarker = {}
Benchmarker.__index = Benchmarker

local config = {
    theme = "Dark",
    studioOnly = true,
    yieldtime = 0.1, -- seconds
    displayBasedOnContext = true, -- only display the gui in the server if its called from server an only on the client if its called from client
    displayCoreGuis = false,
    defaultFullscreen = false -- decides if the gui will display by on fullscreen on creation
}

local Benchmark = require(script:WaitForChild("Benchmark"))
local Data = require(script.Data)
local benchmarks = Data.Benchmarks
local GuiDirector = require(script.gui.GuiDirector)
local guiDirector = GuiDirector.new()




spawn(function()
    wait(2)
    Data.Benchmarks.Total:insert(Benchmark.new({}))
    wait(2)
    Data.Benchmarks.Total:insert(Benchmark.new({}))
    wait(2)
    Data.Benchmarks.Total:insert(Benchmark.new({}))
end)


-- Benchmark specific stats: time, duration, cycles, status wanna display
-- Benchmark general stats: RAM , FPS



-- configFormat = {
--     Methods = {}, {} or nil denotes all methods, {"specfic"} only does that method
--     Duration = 5, -- duration for Mean method
--     Cycles = 1e9, -- Denotes how many cycles it will run for the
--     NamesOFRandom
-- }

function Benchmarker.Create(config) -- returns a Benchmark
   return Benchmark.new(config) 
end

function Benchmarker.StartAll() -- starts all the waiting benchmarks
    for _, benchmark in ipairs(benchmarks.Waiting._tbl) do
        benchmark:Start()
    end
end

function Benchmarker.Abort() -- cancels current running benchmark and queued benchmarks
    if benchmarks.CurrentBenchmark then
        benchmarks.CurrentBenchmark:Cancel()        
    end
    for _, benchmark in ipairs(benchmarks.Queue._tbl) do
        benchmark:Cancel()
    end
end

function Benchmarker.Destroy()
    guiDirector:destroy()    
end

function Benchmarker.Show()
    guiDirector:show()
end

function Benchmarker.Hide()
    guiDirector:hide()
end

function Benchmarker.ProfileBegin(label)
    
end

function Benchmarker.PofileEnd(label) -- unlike roblox, i do need the label
    
end

function Benchmarker.ProfilePauze(label) -- pauzes the profile, this can be used for example when you dont want a yielding function to count towards the profile
    
end

function Benchmarker.ProfileUnpauze(label) -- unpauzes profile
    
end

return Benchmarker