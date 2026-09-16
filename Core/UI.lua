--==================================================
-- DayBreak
-- Core UI Controller
--
-- This file controls UI state and UI events.
-- It does NOT control the Reanimation engine.
--==================================================

local UI = {}
UI.__index = UI

--==================================================
-- DEFAULT STATE
--==================================================

UI.State = {
    Visible = true,

    ActiveModule = "Reanimation",
    ActiveTab = "All",

    SearchText = "",

    Window = {
        Width = 900,
        Height = 600,
    },
}

--==================================================
-- REGISTERED MODULES
--==================================================

UI.Modules = {}

--==================================================
-- EVENT CALLBACKS
--==================================================

UI.Callbacks = {}

--==================================================
-- CREATE
--==================================================

function UI.new()
    local self = setmetatable({}, UI)

    self.State = {
        Visible = true,

        ActiveModule = "Reanimation",
        ActiveTab = "All",

        SearchText = "",

        Window = {
            Width = 900,
            Height = 600,
        },
    }

    self.Modules = {}
    self.Callbacks = {}

    return self
end

--==================================================
-- MODULE MANAGEMENT
--==================================================

function UI:RegisterModule(name, module)
    assert(
        type(name) == "string",
        "DayBreak UI: module name must be a string"
    )

    assert(
        type(module) == "table",
        "DayBreak UI: module must be a table"
    )

    self.Modules[name] = module

    self:Emit("ModuleRegistered", name, module)

    return module
end

function UI:GetModule(name)
    return self.Modules[name]
end

function UI:HasModule(name)
    return self.Modules[name] ~= nil
end

function UI:GetModules()
    return self.Modules
end

--==================================================
-- ACTIVE MODULE
--==================================================

function UI:SetModule(name)
    if not self:HasModule(name) then
        return false, "Module not found: " .. tostring(name)
    end

    self.State.ActiveModule = name

    self:Emit("ModuleChanged", name)

    return true
end

function UI:GetActiveModule()
    return self.State.ActiveModule
end

--==================================================
-- TABS
--==================================================

function UI:SetTab(tabName)
    assert(
        type(tabName) == "string",
        "DayBreak UI: tab name must be a string"
    )

    self.State.ActiveTab = tabName

    self:Emit("TabChanged", tabName)

    return true
end

function UI:GetTab()
    return self.State.ActiveTab
end

--==================================================
-- SEARCH
--==================================================

function UI:SetSearch(text)
    self.State.SearchText = tostring(text or "")

    self:Emit(
        "SearchChanged",
        self.State.SearchText
    )
end

function UI:GetSearch()
    return self.State.SearchText
end

--==================================================
-- VISIBILITY
--==================================================

function UI:Show()
    self.State.Visible = true

    self:Emit("VisibilityChanged", true)
end

function UI:Hide()
    self.State.Visible = false

    self:Emit("VisibilityChanged", false)
end

function UI:Toggle()
    if self.State.Visible then
        self:Hide()
    else
        self:Show()
    end

    return self.State.Visible
end

function UI:IsVisible()
    return self.State.Visible
end

--==================================================
-- WINDOW
--==================================================

function UI:SetWindowSize(width, height)
    assert(
        type(width) == "number",
        "DayBreak UI: width must be a number"
    )

    assert(
        type(height) == "number",
        "DayBreak UI: height must be a number"
    )

    self.State.Window.Width = width
    self.State.Window.Height = height

    self:Emit(
        "WindowSizeChanged",
        width,
        height
    )
end

function UI:GetWindowSize()
    return
        self.State.Window.Width,
        self.State.Window.Height
end

--==================================================
-- EVENTS
--==================================================

function UI:On(eventName, callback)
    assert(
        type(eventName) == "string",
        "DayBreak UI: event name must be a string"
    )

    assert(
        type(callback) == "function",
        "DayBreak UI: callback must be a function"
    )

    self.Callbacks[eventName] =
        self.Callbacks[eventName] or {}

    table.insert(
        self.Callbacks[eventName],
        callback
    )

    return callback
end

function UI:Emit(eventName, ...)
    local listeners = self.Callbacks[eventName]

    if not listeners then
        return
    end

    for _, callback in ipairs(listeners) do
        local success, errorMessage =
            pcall(callback, ...)

        if not success then
            -- UI callbacks should not break the rest
            -- of DayBreak if one callback errors.
            warn(
                "[DayBreak UI] Callback error:",
                errorMessage
            )
        end
    end
end

--==================================================
-- RESET
--==================================================

function UI:Reset()
    self.State.ActiveModule = "Reanimation"
    self.State.ActiveTab = "All"
    self.State.SearchText = ""
    self.State.Visible = true

    self:Emit("Reset")
end

--==================================================
-- DEBUG INFORMATION
--==================================================

function UI:GetState()
    return self.State
end

return UI
