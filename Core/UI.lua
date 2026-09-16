--==================================================
-- DayBreak
-- UI Abstraction
--
-- This layer intentionally does not assume a specific
-- UI framework. A renderer can subscribe to the state
-- and callbacks later.
--==================================================

local UI = {
    State = {
        ActiveModule = nil,
        ActiveTab = nil,
    },

    Callbacks = {},
}

function UI:Initialize(config)
    self.State.ActiveModule = config.UI.ActiveModule
    self.State.ActiveTab = config.UI.ActiveTab
end

function UI:SetModule(name)
    self.State.ActiveModule = name
    self:Emit("ModuleChanged", name)
end

function UI:SetTab(name)
    self.State.ActiveTab = name
    self:Emit("TabChanged", name)
end

function UI:On(eventName, callback)
    self.Callbacks[eventName] = self.Callbacks[eventName] or {}
    table.insert(self.Callbacks[eventName], callback)
end

function UI:Emit(eventName, ...)
    local listeners = self.Callbacks[eventName]
    if not listeners then
        return
    end

    for _, callback in ipairs(listeners) do
        callback(...)
    end
end

return UI
