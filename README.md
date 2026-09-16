# DayBreak

Modular Lua source tree for the DayBreak UI.

## Current status

The first milestone is the **Reanimation UI layer**. It is intentionally separated from the existing Reanimation engine so UI work can continue without changing the engine.

### Included

- Core UI state and rendering abstraction
- Module manager
- Configuration state
- Reanimation UI tabs:
  - All
  - Favs
  - Binds
  - Custom
  - States
  - Size
- Animation search
- Favorites
- Custom animation records
- Idle / Walk / Jump state assignment
- Versioned animation-data format

### Not connected yet

- Reanimation playback
- Remote/event handling
- Character manipulation
- Executor-specific integration
- Persistent filesystem storage

Those boundaries are intentional. The UI communicates through module interfaces instead of reaching directly into an engine.

## Project layout

```text
DayBreak/
├── Main.lua
├── Core/
│   ├── UI.lua
│   ├── ModuleManager.lua
│   └── Config.lua
├── Modules/
│   └── Reanimation/
│       ├── UI.lua
│       └── Reanimation.lua
└── Data/
    └── AnimationFormat.lua
```

## Entry point

`Main.lua` creates the module manager, registers Reanimation, and starts the UI layer.

The source is deliberately framework-agnostic at this stage: the UI layer exposes state and callbacks rather than assuming a particular UI library.
