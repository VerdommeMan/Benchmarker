local TableManager = {}
TableManager.__index = TableManager

local guiFolder = script.Parent.Parent
local Data = require(guiFolder.Parent.Data)

local Column = Data.Theme.Column
local TableScaffold = guiFolder.components.TableScaffold

local 

function TableManager.new(benchmark, method)
    local self = setmetatable({table = TableScaffold:Clone(), benchmark = benchmark, method = method})

end

return TableManager