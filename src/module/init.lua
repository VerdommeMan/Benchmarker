-- @Author: VerdommeMan, see https://github.com/VerdommeMan/Benchmarker for more information 
-- @Version: 2.0.0

local Benchmarker = {}
Benchmarker.__index = Benchmarker

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local config = {
    theme = "Dark",
    studioOnly = true,
    allowedClients = {}, -- empty all, fill with player ids
    yieldtime = 0.1, -- seconds
    displayBasedOnContext = true, -- only display the gui in the server if its called from server an only on the client if its called from client
    hideCoreGuis = true, -- Hides the healthbar, playerlist (block gui view)
    defaultScreenMode = "Window" -- decide if it starts mimized, window or fullscreen
}

local Benchmark = require(script:WaitForChild("Benchmark"))
local Data = require(script.Data)
local benchmarks = Data.Benchmarks
local GuiDirector = require(script.gui.GuiDirector)

require(script.BenchmarkScheduler)
require(script.BenchmarkPerformer)

local guiDirector
if RunService:IsClient() then
   guiDirector = GuiDirector.new(Players.LocalPlayer)
else
   guiDirector = GuiDirector.new(Players:GetPlayers()[1] or Players.PlayerAdded:Wait())
end

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
        ["0.5 in function long name"] = function()
            local function sqrt(nr)
                return nr ^ 0.5
            end
            for i = 1, 1e3 do
                local _ = sqrt(25)   
            end
            
        end,
        ["func creation"] = function()
            local function _(nr)
                return nr ^ 0.5
            end
        end,
    
    }):Start()

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
    local longstr = ("a"):rep(1e3)
    Benchmarker.Create({
        sub = function()
            local function stringEndsWith(str, endsWith)
                return str:sub(-#endsWith) == endsWith
            end
            for i = 1, 1e3 do
                stringEndsWith(longstr, "aaaaa")    
            end
            
        end,
        find = function()
            local function endsWith(str, char)
                 return string.find(str, char, #char, true)
            end
            for i = 1, 1e3 do
                endsWith(longstr, "aaaaa")    
            end
            
        end
    }):Start()

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
end)


-- Benchmark specific stats: time, duration, cycles, status wanna display
-- Benchmark general stats: RAM , FPS



-- configFormat = {
--     Methods = {}, {} or nil denotes all methods, {"specfic"} only does that method
--     Duration = 5, -- duration for Mean method
--     Cycles = 1e9, -- Denotes how many cycles it will run for the
--     NamesOFRandom = func,
--     benchFuncName = func
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
    if benchmarks.Running then
        benchmarks.Running:Cancel()        
    end
    for _, benchmark in ipairs(benchmarks.Queued._tbl) do
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