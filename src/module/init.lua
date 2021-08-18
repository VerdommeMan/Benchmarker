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

require(script.BenchmarkScheduler)
require(script.BenchmarkPerformer)



delay(2, function()
    Benchmarker.Create({
        Duration = 5,
        Cycles = 1e6,
        ["0.5"] = function()
            for i = 1, 1e3 do
                local _ = 25 ^ 0.5
            end
        end,
        ["1/2"] = function()
            for i = 1, 1e3 do
                local _ = 25 ^ (1/2)    
            end
        end,
        ["math.sqrt"] = function()
            for i = 1, 1e3 do
                local _ = math.sqrt(25)    
            end
        end,
    
    })
    Benchmarker.Create({
        Duration = 5,
        Cycles = 1e6,
        ["0.5"] = function()
            for i = 1, 1e3 do
                local _ = 25 ^ 0.5
            end
        end,
        ["1/2"] = function()
            for i = 1, 1e3 do
                local _ = 25 ^ (1/2)    
            end
        end,
        ["math.sqrt"] = function()
            for i = 1, 1e3 do
                local _ = math.sqrt(25)    
            end
        end,
    
    })
    Benchmarker.Create({
        Duration = 5,
        Cycles = 1e6,
        ["0.5"] = function()
            for i = 1, 1e3 do
                local _ = 25 ^ 0.5
            end
        end,
        ["1/2"] = function()
            for i = 1, 1e3 do
                local _ = 25 ^ (1/2)    
            end
        end,
        ["math.sqrt"] = function()
            for i = 1, 1e3 do
                local _ = math.sqrt(25)    
            end
        end,
    
    })

    Benchmarker.Create({
        ["must error"] = function()
            local function tester()
                while true do end
            end
            tester()
            warn("should never ever be printed")
        end
    })

    Benchmarker.Create({
        ["must error nil"] = function()
            function test()
                ({})[nil][nil] = nil
            end

        (function ()
                test()
            end)()
        end
    })

    Benchmarker.Create({
        ["shall cancel"] = function()
            print("func is running at: ", coroutine.running())
            error(Data.SPECIAL_CANCEL_FLAG)
        end
    })

    local bench = Benchmarker.Create({
        ["The canceling"] = function()
            ("b"):rep(1e4)
        end
    })

    
    bench.StatusChanged:Connect(function(status)
        print("Changed status to: ", status)
        if status == "Running" then
            task.wait(0.5)
            print('Canceling bench', bench.Id)
            bench:Cancel()
        end
    end)

--     wait(2)
--     Data.Benchmarks.Total:insert(Benchmark.new({}))
--     wait(2)
--     Data.Benchmarks.Total:insert(Benchmark.new({}))
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