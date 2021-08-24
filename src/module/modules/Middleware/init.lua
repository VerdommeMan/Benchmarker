-- Purpose of this module is to be a agnostic (server / client) interface towards events that are client only.
-- This way my code has one listener (for server/client), and this deals with if its required from the client or the server

local Middleware = {}
Middleware.__index = Middleware
local Connection = {}

local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local EventBusTag = "Benchmarker_EventBus"
local EventBus = Instance.new("RemoteEvent")
EventBus.Name = EventBusTag
EventBus.Parent = game.ReplicatedStorage
CollectionService:AddTag(EventBus, EventBusTag)

local ClientScript = script.ClientInitializer
local TIMEOUT_CLIENT = 10 -- seconds
local IS_CLIENT = RunService:IsClient()  
local Id = 0

local clients = {}

if not IS_CLIENT then
    EventBus.OnServerEvent:Connect(function(client, action, id, ...)
        if action == "Invoked" then
            local actions = clients[client]
            if actions and actions[id] then
                actions[id](...)
            end
        end
    end)
end

local function disconnect(client, id)
    clients[client][id] = nil
    EventBus:FireClient(client, "Disconnect", id)
end

function Connection.new(client, id)
    local connection = setmetatable({ClassName = "Connection"}, {__index = function(_, k)
        if k == "Connected" then
            return clients[client] ~= nil
        end
    end})
    function connection:Disconnect()
        self.Connected = false
        disconnect(client, id)
        setmetatable(self, nil)
    end
    return connection
end

local function genId()
    Id += 1
    return Id
end

local function hasReplicated(instance)
    return instance:IsDescendantOf(game) and (not instance:IsDescendantOf(game.ServerScriptService)) and (not instance:IsDescendantOf(game.ServerStorage))
end

local function yieldUntilReplicated(instance: Instance)
    if not hasReplicated(instance) then
        local thread = coroutine.running()
        task.spawn(function()
            local conn
            conn = game.DescendantAdded:Connect(function(descendant)
                if descendant == instance and hasReplicated(instance) then
                    conn:Disconnect()
                    task.spawn(thread)
                end
            end)   
        end)
        coroutine.yield()
    end
end

local function yieldForConfirmation(client, timeout)
    local thread = coroutine.running()
    local con

    task.delay(timeout, function()
        if con and coroutine.status(thread) == "suspended" then
            con:Disconnect()
            task.spawn(thread, false, "Middleware failed to received confirmation from client `" .. client.Name .. "` \nAborting creation of gui instance for that client.")
        end
    end)

    task.defer(function()
        con = EventBus.OnServerEvent:Connect(function(player, action)
            if player == client and action == "Confirmation" then
                con:Disconnect()
                con = nil
                task.spawn(thread, true , setmetatable({_client = client}, Middleware))
            end
        end)
    end)

    return coroutine.yield()
end


local function initializeClient(client)
    clients[client] = {}

    local ls = ClientScript:Clone()
    ls.Disabled = false
    task.defer(function() -- insures that the confirmation listener is registered before the sender can run
        ls.Parent = client:WaitForChild("PlayerGui")    
    end)

    return yieldForConfirmation(client, TIMEOUT_CLIENT)
end

local function handleClient(instance, eventName, callback)
    return instance[eventName]:Connect(callback)
end

local function handleServer(client, instance, eventName, callback)
    local id = genId()
    clients[client][id] = callback
    task.spawn(function()
        yieldUntilReplicated(instance)
        EventBus:FireClient(client, "Connect", id, instance, eventName)
    end)
    return Connection.new(client, id)
end

-- Limited to one middleware per client, can easily be modified to allow multiple
-- But had no requirement for it
-- returns success, and error msg or the object
-- Success can fail when the server doesnt received confirmation of initialization
-- which can happen when the client leaves before this has been completed

function Middleware.init(client: Player) : (boolean, any)
    if IS_CLIENT then
        return true, setmetatable({_client = client}, Middleware) 
    elseif clients[client] then -- limits one middleware to one client
        error("Client `" .. client.Name .. "` has already been initialized!")
    end
    return initializeClient(client)
end

function Middleware:listen(instance: Instance, eventName: String, callback: (any) -> ()) 
    local event = instance[eventName]

    if not event then
        error("An instance with event `" .. eventName .. "` could't be found!")
    elseif IS_CLIENT then
        return handleClient(instance, event, callback)
    else
        return handleServer(self._client, instance, eventName, callback)
    end    
end

function Middleware:disconnectAll()
    for id in pairs(clients[self._client]) do
        disconnect(id)
    end
end

function Middleware:destroy()
    self:disconnectAll()
    clients[self._client] = nil
    EventBus:FireClient(self._client, "Destroy")
    self._client = nil
    setmetatable(self, nil)
end

return Middleware