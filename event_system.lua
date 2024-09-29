-- event_system.lua
EventSystem = {}

function EventSystem:init()
    self.listeners = {}
    return self
end

function EventSystem:addEventListener(eventName, listener)
    if not self.listeners[eventName] then
        self.listeners[eventName] = {}
    end
    table.insert(self.listeners[eventName], listener)
end

function EventSystem:removeEventListener(eventName, listener)
    if self.listeners[eventName] then
        for i, l in ipairs(self.listeners[eventName]) do
            if l == listener then
                table.remove(self.listeners[eventName], i)
                return
            end
        end
    end
end

function EventSystem:dispatchEvent(eventName, ...)
    if self.listeners[eventName] then
        for _, listener in ipairs(self.listeners[eventName]) do
            listener(...)
        end
    end
end

return EventSystem