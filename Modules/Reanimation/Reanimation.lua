--==================================================
-- DayBreak Reanimation Engine Placeholder
--
-- IMPORTANT:
-- This file is deliberately isolated from the UI.
--
-- Put the existing Reanimation module here when we are
-- ready to connect the engine. The UI does not need to be
-- rewritten when that happens.
--==================================================

local Reanimation = {}

function Reanimation.IsAvailable()
    return false
end

function Reanimation.GetStatus()
    return "Engine not connected"
end

return Reanimation
