-- Quick and dirty module to get events for tables

local CHANGED = {} -- unique keys
local ADDED = {}
local REMOVED = {}
local mod = {}

local Connection = {}

function Connection.new(listeners, callback)
    local connection = {}
    local thread = coroutine.create(function(...)
        callback(...)    
        while true do
            callback(coroutine.yield()) -- gotta keep this thread alive    
        end
    end)
    table.insert(listeners, thread)
    function connection:disconnect()
        table.remove(listeners, table.find(listeners, thread))
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
          
        for _, listener in ipairs(t._listeners[k] or {}) do
            task.spawn(listener, v)
        end
        for _, listener in ipairs(t._listeners[CHANGED]) do
            task.spawn(listener, v)
        end
        if oldV == nil then
            for _, listener in ipairs(t._listeners[ADDED]) do
                task.spawn(listener, v)
            end
        end
        if v == nil then
            for _, listener in ipairs(t._listeners[REMOVED]) do
                task.spawn(listener, v)
            end
        end
    end
end

function mod:keyChanged(key, callback)
    if not self._listeners[key] then
        self._listeners[key] = {}
    end
    return Connection.new(self._listeners[key], callback)
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

-- Added event, only fires when adding an element to a key which was previously nil
function mod:added(callback)
    return Connection.new(self._listeners[ADDED], callback)
end

function mod:changed(callback)
    return Connection.new(self._listeners[CHANGED], callback)
end

function mod:removed(callback)
    return Connection.new(self._listeners[REMOVED], callback)
end

-- This method prevents the added children that are tables from being transformed into this new format
function mod:exempt() 
    self._exempt = true
    return self
end

return initChanged