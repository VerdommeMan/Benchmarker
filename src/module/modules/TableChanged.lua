-- Quick and dirty module to get events for tables

local CHANGED = {} -- unique keys
local ADDED = {}
local REMOVED = {}
local REPLACED = {}
local mod = {}

local Connection = {}

function Connection.new(listeners, listener, callback)
    local connection = {}

    listener.thread = coroutine.create(function(...) -- not requried anymore but ill keep it
        callback(...)    
        while true do
            callback(coroutine.yield()) -- gotta keep this thread alive    
        end
    end)
    table.insert(listeners, listener)
    function connection:disconnect()
        table.remove(listeners, table.find(listeners, listener))
        self.disconnect = nil
    end

    return connection    
end


local function initChanged(tbl, childExecptions)
    for k,v in pairs(tbl) do
        if type(v) == "table" and not (childExecptions or {})[k] then
           tbl[k] = initChanged(v)
        end
    end
    return setmetatable({_tbl = tbl, _listeners = {[CHANGED] = {}, [ADDED] = {}, [REMOVED] = {}}}, {__index = function(_, k) return mod[k] or tbl[k] end, __newindex = __newindex})
end

function __newindex(t, k ,v)
    local oldV = t._tbl[k]
    if oldV ~= v then
        t._tbl[k] = (not t._exempt) and type(v) == "table" and (not v._exempt) and initChanged(v) or v
          
        local mode = (v == nil and REMOVED) or (oldV == nil and ADDED) or REPLACED
        
        for _, listener in ipairs(t._listeners) do
            if listener.changed or listener.key == k or listener.mode == mode then -- not a fan, couldnt figure out a way do avoid checks
                task.spawn(listener.thread, v)
            end
        end
    end
end

function mod:len()
    return #self._tbl
end

function mod:insert(v, i) -- cant use table.insert, due to rawset
    local len = self:len()
    i = i or (len + 1)
    if i <= len then
       self:rightshift(i, len) 
    end
    self._tbl[i] = nil -- silent, must be nil to trigger added event
    self[i] = v
end

function mod:find(val)
    return table.find(self._tbl, val)
end

function mod:findThenRemove(val)
    local found = self:find(val)
    if found then
        self:remove(found)
    else
        error("Didnt find the value in the table!", 2)
    end
end

function mod:findThenMove(val, tableChanged, i)
    self:findThenRemove(val)
    tableChanged:insert(val, i)
end

function mod:remove(i) -- cant use table.remove, due to rawset
    local len = #self._tbl
    local old = self[i]
    self[i] = nil -- only trigger once
    if i < len then -- shift tbl
        self:leftshift(i, len)
    end
    return old
end

function mod:leftshift(at, to) -- silent shift, it wont trigger any events
    for i = at, (to or self:len()) do
        self._tbl[i] = self._tbl[i+1]  
    end
end

function mod:rightshift(at, to) -- silent shift
    for i = (to or self:len()), at, -1 do
        self._tbl[i + 1] = self._tbl[i]
    end 
end

function mod:clear() -- only for arrays, triggers each removal
    for i = self:len(), 1, -1 do
        self[i] = nil
    end
end

function mod:keyChanged(key, callback)
    return Connection.new(self._listeners, {key = key}, callback)
end

-- Added event, only fires when adding an element to a key which was previously nil
function mod:added(callback)
    return Connection.new(self._listeners, {mode = ADDED}, callback)
end

function mod:changed(callback)
    return Connection.new(self._listeners, {changed = true}, callback)
end

function mod:replaced(callback)
    return Connection.new(self._listeners, {mode = REPLACED}, callback)
end

function mod:removed(callback)
    return Connection.new(self._listeners, {mode = REMOVED}, callback)
end

-- This method prevents the added children that are tables from being transformed into this new format
function mod:exempt() 
    self._exempt = true
    return self
end

return initChanged