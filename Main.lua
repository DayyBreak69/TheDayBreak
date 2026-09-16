--==================================================
-- DayBreak
-- Main
--==================================================

local ModuleManager = require("Core.ModuleManager")
local Config = require("Core.Config")
local UIClass = require("Core.UI")

local ReanimationUIClass =
    require("Modules.Reanimation.UI")

local ReanimationEngine =
    require("Modules.Reanimation.Reanimation")

--==================================================
-- DAYBREAK
--==================================================

local DayBreak = {}

DayBreak.Name = "DayBreak"
DayBreak.Version = "0.1.0"

--==================================================
-- CORE SYSTEMS
--==================================================

DayBreak.Config = Config

DayBreak.UI = UIClass.new()

DayBreak.Modules =
    ModuleManager.new()

--==================================================
-- REANIMATION
--==================================================

DayBreak.ReanimationUI =
    ReanimationUIClass.new()

DayBreak.ReanimationEngine =
    ReanimationEngine

--==================================================
-- REGISTER MODULE
--==================================================

DayBreak.Modules:Register(
    "Reanimation",
    {
        UI = DayBreak.ReanimationUI,
        Engine = DayBreak.ReanimationEngine,
    }
)

--==================================================
-- INITIALIZE
--==================================================

function DayBreak:Start()

    -- Initialize core UI
    self.UI:Initialize(self.Config)

    -- Initialize Reanimation UI
    self.ReanimationUI:Initialize(
        self.UI
    )

    -- Make Reanimation the active module
    self.UI:SetModule(
        "Reanimation"
    )

    -- Start on the All tab
    self.ReanimationUI:SetTab(
        "All"
    )

    return self
end

--==================================================
-- GET MODULE
--==================================================

function DayBreak:GetModule(name)
    return self.Modules:Get(name)
end

--==================================================
-- STATUS
--==================================================

function DayBreak:GetStatus()

    return {
        Name = self.Name,
        Version = self.Version,

        ActiveModule =
            self.UI:GetActiveModule(),

        ActiveTab =
            self.UI:GetTab(),

        ReanimationEngine =
            self.ReanimationEngine:GetStatus(),
    }

end

--==================================================
-- RETURN
--==================================================

return DayBreak
