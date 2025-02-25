local Automod = {
    enabled = false, -- Automod toggle
    log = {}, -- Logs of automod actions
}

-- Function to enable or disable Automod
function Automod:toggle()
    self.enabled = not self.enabled
    table.insert(self.log, "Automod " .. (self.enabled and "enabled" or "disabled") .. " at " .. os.date("%X"))
end

-- Function to process game events with Automod AI
function Automod:processEvent(event)
    if not self.enabled then return end

    -- Detect offensive chat messages
    if event.type == "chat" and self:isOffensive(event.message) then
        table.insert(self.log, "Offensive message detected: '" .. event.message .. "' at " .. os.date("%X"))
        return "Warning: Inappropriate message detected!"
    end
end

-- Helper function to check for offensive content
function Automod:isOffensive(message)
    local offensiveWords = {"badword1", "badword2"} -- Add offensive words here
    for _, word in ipairs(offensiveWords) do
        if message:lower():find(word) then
            return true
        end
    end
    return false
end
