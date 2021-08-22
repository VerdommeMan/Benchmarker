local TableManager = {}
TableManager.__index = TableManager

local guiFolder = script.Parent.Parent
local module = guiFolder.Parent
local Data = require(module.Data)
local CalcStats = require(module.CalcStatistics)
local Maid = require(module.modules.Maid)
local TextService = game:GetService("TextService")

local Column = Data.Theme.Column
local TableScaffold = guiFolder.components.TableScaffold
local PADDING = 10 -- extra padding

local function getWidth(string)
   local x = TextService:GetTextSize(string, 8,"Legacy" , Vector2.new(1000,1000)).X + PADDING
   return x > 75 and x or 75
end

local function createCell(order, text, isHeader)
    local lbl = Instance.new("TextLabel")
    lbl.Name = "Cell"
    lbl.BorderSizePixel = 0
    lbl.BackgroundColor3 = order % 4 == 0 and Column.Primary or Column.Secondary
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.RichText = isHeader
    lbl.Text = isHeader and "<b>" .. text .. "</b>" or text
    lbl.TextColor3 = Column.TextColor3
    lbl.LayoutOrder = order
    return lbl
end

local function createBorder(order, vertical)
    local frame = Instance.new("Frame")
    frame.Name = "Border"
    frame.BorderSizePixel = 0
    frame.BackgroundColor3 = Column.Border
    frame.AutomaticSize = vertical and Enum.AutomaticSize.Y or Enum.AutomaticSize.X
    frame.Size = vertical and UDim2.fromOffset(1, 0) or UDim2.fromOffset(0, 1)
    frame.LayoutOrder = order
    return frame
end

local columnOrder = 0


local function createColumnHolder(width)
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.Size = UDim2.fromOffset(width or 75, 0)
    frame.LayoutOrder = columnOrder
    columnOrder += 1
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = frame
    return frame
end

local function createShell(name, parent)
    createBorder(columnOrder, true).Parent = parent
    local shell = createColumnHolder(getWidth(name))
    columnOrder += 1
    shell.Name = name
    createCell(0, name).Parent = shell
    createBorder(1).Parent = shell
    shell.Parent = parent
    return shell
end

local function fillColumn(config, parent, isHeader)
    local order = isHeader and 0 or 2
    for _, nr in ipairs(config) do
        createCell(order, nr, isHeader).Parent = parent
        order += 1
        if nr ~= #config then
            createBorder(order).Parent = parent
            order += 1    
        end
    end
end

local function clearColumn(parent)
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("GuiObject") and child.LayoutOrder > 1 then
            child:Destroy()
        end
    end
end

function TableManager.new(benchmark, method, tableHolder)
    local self = setmetatable({benchmark = benchmark, method = method}, TableManager)
    self._maid = Maid.new()
    local tbl = TableScaffold:Clone()  
    self._maid.table = tbl 
    tbl.Name = method.Name
    tbl.Parent = tableHolder
    fillColumn(method.Columns, tbl.Header, true)
    self:_initListeners()
    return self
end

function TableManager:_initListeners()
    local results = self.benchmark.Results[self.method]
    for _, header in ipairs(results.Headers) do
        local shell = createShell(header, self._maid.table.Body)
        self._maid["Listener | " .. header] = results.Body:keyChanged(header, function(result)
            if result then
                local vals = CalcStats.calc(result, self.method)
                fillColumn(vals, shell)
            else
                clearColumn(shell)
            end
        end)
    end
end

function TableManager:destroy()
    self._maid:DoCleaning()
end

return TableManager