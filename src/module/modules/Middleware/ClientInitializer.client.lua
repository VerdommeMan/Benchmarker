-- Part of the Benchmarker Module
-- Handles input redirection

local CollectionService = game:GetService("CollectionService")

local EventBus: RemoteEvent = CollectionService:GetTagged("Benchmarker_EventBus")[1]
local connEventBus
local listeners = {}
local Actions = {}

local function createCallback(id)
    return function (...)
        EventBus:FireServer("Invoked", id, ...)
    end
end

function Actions.Connect(id, instance, eventname)
    listeners[id] = instance[eventname]:Connect(createCallback(id))    
end

function Actions.Disconnect(id)
    local listener = listeners[id]
    if listener then
       if listener.Connected then
           listener:Disconnect()
       end
    else
        warn("Listener with id ", id, " wasnt found")
    end
end

function Actions.Destroy()
    connEventBus:Disconnect()
    for _, connection in pairs(listeners) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    listeners = nil
    connEventBus = nil
    EventBus = nil
    script:Destroy()
end

connEventBus = EventBus.OnClientEvent:Connect(function(actionName, ...)
    local action = Actions[actionName]
    if action then
       action(...)
    else
        warn("An action couldnt be found: ", action)
    end
end)

EventBus:FireServer("Confirmation")