-- Quick and dirty module to get events for tables

local CHANGED = {} -- unique key
local mod = {}

local function initChanged(tbl, childExecptions)
    for k,v in pairs(tbl) do
        if type(v) == "table" and not (childExecptions or {})[k] then
           tbl[k] = initChanged(v)
        end
    end
    return setmetatable({_tbl = tbl, _listeners = {[CHANGED] = {}}}, {__index = function(_, k) return mod[k] or tbl[k] end, __newindex = __newindex})
end

function __newindex(t, k ,v)
    if t._tbl[k] ~= v then
        t._tbl[k] = t._exempt == nil and type(v) == "table" and initChanged(v) or v
          
        for _, listener in ipairs(t._listeners[k] or {}) do
            listener(v)
        end
        for _, listener in ipairs(t._listeners[CHANGED]) do
            listener(v)
        end
    end
end

function mod:keyChanged(key, callback)
    if not self._listeners[key] then
        self._listeners[key] = {}
    end
    table.insert(self._listeners[key], callback)
end

function mod:len()
    return #self._tbl
end

function mod:insert(v, i) -- cant use table.insert, due to rawset
   self[i or #self._tbl + 1] = v
end

function mod:remove(i) -- cant use table.remove, due to rawset
    local len = #self._tbl
    self[i] = nil -- only trigger once
    if i < len then -- shift tbl
        for j = i, len do
            self._tbl[j] = self._tbl[j+1]  
        end
    end
end

function mod:changed(callback)
    table.insert(self._listeners[CHANGED], callback)
end

-- This method prevents the added children that are tables from being transformed into this new format
function mod:exempt() 
    self._exempt = true
    return self
end

return initChanged