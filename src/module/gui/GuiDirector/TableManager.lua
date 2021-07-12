local TableManager = {}
TableManager.__index = TableManager

local guiFolder = script.Parent.Parent
local module = guiFolder.Parent
local Data = require(module.Data)
local CalcStats = require(module.CalcStatistics)

local Column = Data.Theme.Column
local TableScaffold = guiFolder.components.TableScaffold

local function createCell(order, text)
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundColor3 = order % 4 == 0 and Column.Primary or Column.Secondary
    lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.Size = UDim2.fromOffset(50, 25)
    lbl.Text = text
    lbl.TextColor3 = Column.TextColor3
    lbl.LayoutOrder = order
    return lbl
end

local function createBorder(order)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Column.Border
    frame.AutomaticSize = Enum.AutomaticSize.X
    frame.Size = UDim2.fromOffset(0, 1)
    frame.LayoutOrder = order
    return frame
end

local function createColumnHolder()
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.Size = UDim2.fromOffset(70, 0)
    return frame
end

local function createColumn(config, parent)
    local frame = parent or createColumnHolder()

    local order = 0
    for _, nr in ipairs(config) do
        createCell(order, nr).Parent = frame
        order += 1
        if nr ~= #config then
            createBorder(order).Parent = frame
            order += 1    
        end
    end
    return frame
end

function TableManager.new(benchmark, method)
    local self = setmetatable({table = TableScaffold:Clone(), benchmark = benchmark, method = method}, TableManager)
    self.table.Name = method
    createColumn(CalcStats.order, self.table.Header)
    return self
end

function TableManager:destroy()
    self.table:destroy()
    self.table = nil
end

return TableManager