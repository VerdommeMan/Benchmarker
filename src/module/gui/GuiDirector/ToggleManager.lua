local ToggleManager = {}
ToggleManager.__index = ToggleManager

local Data = require(script.Parent.Parent.Parent.Data)

local default, active, theme, defaultPattern, activePattern

ToggleManager.setTheme()

local function shallowCopy(tbl)
	local newTbl = {}
	
	for k, v in pairs(tbl) do
		newTbl[k] = v
	end
	
	return newTbl
end

local function getChildrenIsA(instance, class)
	local children = {}
	for _, child in ipairs(instance:GetChildren()) do
		if child:IsA(class) then
			table.insert(children, child)
		end
	end
	return children
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

function ToggleManager.new(toggle, table)
    local self = setmetatable({toggle = toggle, table = table, btns = getChildrenIsA(toggle, "TextButton")}, ToggleManager)
    self:render(toggle.Cycles)
    return self
end

function ToggleManager:initBtns()
    for _, method in ipairs(self.btns) do
        method.Activated:Connect(function() 
            if method ~= self.activeMethod then
                -- self.table[self.activeMethod.Name].Visible = false
                -- local tbl = self.table[method.Name]
                -- tbl.Visible = true
                -- -- stupid bug, doesnt update the height, forcing update now
                -- tbl.Size = UDim2.new(1, -7,1, 0)
                print("make ", self.activeMethod.Name, " invisible and ", method.Name, " visible")
                self:renderBtns(method)
            end
        end)
    end
end

function ToggleManager:renderBtns(newMethod)
    self.activeMethod = newMethod
    for _, method in ipairs(self.btns) do
        if newMethod == method then
            applyProps(method, setRichText(active, activePattern, method.Name))
        else
            applyProps(method, setRichText(default, defaultPattern, method.Name))
        end
    end
end

function ToggleManager:updateTheme()
    ToggleManager.setTheme()
    self:renderBtns(self.activeMethod)
end

function ToggleManager.setTheme()
    theme = Data.Theme
    default , active = shallowCopy(theme.Default), shallowCopy(theme.Active)
    defaultPattern, activePattern = default.Text, active.Text
end