local ToggleManager = {}
ToggleManager.__index = ToggleManager

local root = script.Parent.Parent.Parent
local Data = require(root.Data)

local default, active, theme, defaultPattern, activePattern

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
    self:_createBtns(methods) 
    self.activeBtn = self.btns[#self.btns] 
    self:_renderBtns(self.activeBtn)
    self:_initBtns()
    return self
end

function ToggleManager:_initBtns()
    for _, btn in ipairs(self.btns) do
        btn.Activated:Connect(function() 
            if btn ~= self.activeBtn then
                self.table[self.activeBtn.Name].Visible = false
                local tbl = self.table[btn.Name]
                tbl.Visible = true
                -- stupid bug, doesnt update the height, forcing update now
                tbl.Size = UDim2.new(1, -7,1, 0)
                self:_renderBtns(btn)
            end
        end)
    end
end

function ToggleManager:_createBtns(methods)
    for i, method in ipairs(methods) do
        self.btns[i] = createButton(method, self.toggle)
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

function ToggleManager:updateTheme()
    ToggleManager.setTheme()
    self:_renderBtns(self.activeBtn)
end

function ToggleManager.setTheme()
    theme = Data.Theme
    default , active = shallowCopy(theme.ToggleButtons.Default), shallowCopy(theme.ToggleButtons.Active)
    defaultPattern, activePattern = default.Text, active.Text
end

ToggleManager.setTheme()

return ToggleManager