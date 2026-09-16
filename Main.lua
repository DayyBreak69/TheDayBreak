--==================================================
-- DayBreak
-- Main entry point
--==================================================

local ModuleManager = require("Core.ModuleManager")
local Config = require("Core.Config")
local UI = require("Core.UI")

local ReanimationUI = require("Modules.Reanimation.UI")
local ReanimationEngine = require("Modules.Reanimation.Reanimation")

local DayBreak = {}

DayBreak.Config = Config
DayBreak.UI = UI
DayBreak.Modules = ModuleManager.new()

-- Keep the existing engine isolated from the UI.
DayBreak.Modules:Register("Reanimation", {
    UI = ReanimationUI,
    Engine = ReanimationEngine,
})

function DayBreak.Start()
    UI:Initialize(Config)

    local reanimation = DayBreak.Modules:Get("Reanimation")
    if reanimation and reanimation.UI then
        reanimation.UI:Initialize(UI)
    end

    return DayBreak
end

return DayBreak
