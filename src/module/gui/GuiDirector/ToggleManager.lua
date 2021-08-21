local ToggleManager = {}
ToggleManager.__index = ToggleManager

local root = script.Parent.Parent.Parent
local Data = require(root.Data)

local default, active, theme, defaultPattern, activePattern

local function setByName(array)
    local names = {}

    for _, instance in ipairs(array) do
        names[instance.Name] = instance
    end

    return names
end

local function shallowCopy(tbl)
	local newTbl = {}
	
	for k, v in pairs(tbl) do
		newTbl[k] = v
	end
	
	return newTbl
end

local function getComponent(name): GuiObject
    return root.gui.components[name]:Clone()
end

local function applyProps(instance, props)
	for name, value in pairs(props) do
		instance[name] = value
	end
end

local function setRichText(props, pattern, text)
	props.Text = string.gsub(pattern, "%$", text)
	return props
end

local function createButton(text, parent)
    local btn = getComponent("ToggleButton")
    btn.Name = text
    btn.Text = text 
    btn.Parent = parent
    return btn
end

function ToggleManager.new(pane, methods)
    local self = setmetatable({toggle = pane.Info.Selector.Toggle, table = pane.Info.Table, btns = {}}, ToggleManager)
    self.tables = setByName(self.table:GetChildren())
    self:_createBtns(methods) 
    self.activeBtn = self.btns[#self.btns] 
    self:_renderBtns(self.activeBtn)
    self:_initBtns()
    return self
end

function ToggleManager:_initBtns()
    for _, btn in ipairs(self.btns) do
        btn.Activated:Connect(function() -- #TODO clean this up
            if btn ~= self.activeBtn then
                self.tables[self.activeBtn.Name].Parent = nil -- setting parent instead of .Visible bc had lots of issues bc of AutomaticSize
                self.tables[btn.Name].Parent = self.table
                self:_renderBtns(btn)
            end
        end)
    end
end

function ToggleManager:_createBtns(methods)
    for i, method in ipairs(methods) do
        self.btns[i] = createButton(method.Name, self.toggle)
    end
end

function ToggleManager:_renderBtns(newMethod)
    self.activeBtn = newMethod
    for _, btn in ipairs(self.btns) do
        if newMethod == btn then
            applyProps(btn, setRichText(active, activePattern, btn.Name))
        else
            applyProps(btn, setRichText(default, defaultPattern, btn.Name))
        end
    end
end

-- sets the table in the correct state according to state of the buttons
function ToggleManager:alignTables()
    for _, tbl in pairs(self.tables) do
        tbl.Parent = tbl.Name == self.activeBtn.Name and self.table or nil
    end
end

function ToggleManager:updateTheme()
    ToggleManager.setTheme()
    self:_renderBtns(self.activeBtn)
end

function ToggleManager:destroy() -- prob not needed
    self.toggle = nil
    self.table = nil
    self.tables = nil
end

function ToggleManager.setTheme()
    theme = Data.Theme
    default , active = shallowCopy(theme.ToggleButtons.Default), shallowCopy(theme.ToggleButtons.Active)
    defaultPattern, activePattern = default.Text, active.Text
end

ToggleManager.setTheme()

return ToggleManager