-- @Author: VerdommeMan, see https://github.com/VerdommeMan/Benchmarker for more information 
-- @Version: 2.0.0

local Benchmarker = {}
Benchmarker.__index = Benchmarker

local config = {
    studioOnly = true,
    yieldtime = 0.1, -- seconds
    displayBasedOnContext = true, -- only display the gui in the server if its called from server an only on the client if its called from client
    displayCoreGuis = false,
    defaultFullscreen = false -- decides if the gui will display by on fullscreen on creation
}

local Benchmark = require(script:WaitForChild("Benchmark"))

local GuiDirector = require(script.gui.GuiDirector)

local guiDirector = GuiDirector.new()





-- configFormat = {
--     Methods = {},
--     Duration = 5,
--     Cycles = 1e9,
--     NamesOFRandom
-- }

function Benchmarker.Create(config) -- returns a Benchmark
    
end

function Benchmarker.StartAll() -- starts all the queued benchmarks
    
end

function Benchmarker.Abort() -- cancels current running benchmark and queued benchmarks
    
end

function Benchmarker.Destroy()
    
end

function Benchmarker.Show()
    
end

function Benchmarker.Hide()
    
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