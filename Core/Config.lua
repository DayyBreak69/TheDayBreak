--==================================================
-- DayBreak
-- Configuration
--==================================================

local Config = {
    Name = "DayBreak",
    Version = "0.1.0",

    UI = {
        ActiveModule = "Reanimation",
        ActiveTab = "All",
    },

    Reanimation = {
        Search = "",
        Favorites = {},
        States = {
            Idle = nil,
            Walk = nil,
            Jump = nil,
        },
        CustomAnimations = {},
    },
}

return Config
