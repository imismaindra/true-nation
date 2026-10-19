# True Nation 🌍⚔️
> **Modern Grand Strategy RTS (Real-Time with Pause) Engine in Godot 4.7+**

Inspired by *Hearts of Iron IV*, *Victoria*, and *Conflict of Nations*, **True Nation** is a 2D strategic simulation game featuring tri-matra military operations (Army, Navy, Air Force), dynamic provincial territorial control, resource-driven national economy, and an event-driven tick clock engine.

---

## 🎮 Core Features (Version 0.2.1)

- ⏱️ **Real-Time with Pause Engine (Tick System)**
  - Dynamic game clock (`TimeManager`) emitting hourly, daily, and monthly ticks.
  - Speeds: Pause (`Space`), `1x`, `2x`, `3x`, `5x` (Numeric keys `1`, `2`, `3`, `5`).
  - Interactive top-right HUD control bar with live date display (`01 Jan 2026`).

- 🧭 **Unit Facing Direction & Smooth Orientation (Sprint 1)**
  - Dynamic smooth rotations for Air Wings and Naval Fleets matching heading trajectory.
  - Natural horizontal flipping and chassis tilt for Land divisions (Tanks, Infantry, Artillery).

- 🎖️ **Expanded Modern Military Unit Roster (Sprint 2)**
  - 8 distinct recruit-ready unit types utilizing 28 modern military top-down sprites:
    - 🪖 Infantry Division & 🚜 Main Battle Tank Division
    - 💥 **Field Artillery & MLRS**: High soft attack and siege bombardment reducing enemy fortifications.
    - 🚁 **Attack Helicopter Wing**: Fast multi-domain anti-tank strike capability.
    - 📡 **Recon Drone Wing (UAV)**: Low cost, extended 2-hop Fog of War radar line of sight.
    - ✈️ Multirole Fighter Wing & 🚢 Surface Frigate Fleet
    - 🌊 **Combat Submarine Fleet**: Subsurface stealth operations undetected by surface radar.

- 🤖 **AI Autonomous Construction & Strategic Depth (Sprint 3)**
  - Independent AI rival manages provincial facilities:
    - Detects munitions shortages (<100) and constructs Munitions Plants.
    - Fortifies border provinces with players (+35% Defense).
    - Erects Airbases and Naval Dockyards for multi-matra recruitment.

- 📊 **Interactive Economic Tooltips & Multi-Unit Army Selection (Sprint 4)**
  - Comprehensive hover tooltips on TopBar HUD breaking down daily revenue, factory inputs, military upkeep, and net balance.
  - "Pilih Semua Pasukan di Sini" button on province panel for simultaneous multi-division corps movement.

- 🔊 **Procedural Tactical Sound FX & Atmosphere (Sprint 5)**
  - Integrated procedural 16-bit audio synthesizer (`AudioManager`):
    - Military radio chirp & tactical click, movement roger tones, booming cannon fire, automatic rifle bursts, and war siren alarms.

- 💾 **Safe JSON Save & Load Persistence (Sprint 6)**
  - Complete state persistence (`user://savegame.json`) serializing game time, faction commodities, province ownership, facilities, and all military divisions.
  - Fast Quick Save (`F5`) and Quick Load (`F9`), with dedicated TopBar UI buttons.

- 🏭 **Military Supply Chain & Logistics**
  - Finished war materials: 🔫 Arms (assembly) & 🚀 Munitions (hourly combat consumption).
  - Supply Outage penalties (-50% attack, accelerated morale loss).

- 🌫️ **Dynamic Fog of War**
  - 3-tier visibility (`VISIBLE`, `FOGGED`, `UNKNOWN`) with aerial recon and submarine stealth camouflage.

---

## 🕹️ Controls

| Action | Input |
|---|---|
| **Pan Camera** | `W`, `A`, `S`, `D` or Screen Edge / Middle Mouse Drag |
| **Zoom In / Out** | Mouse Wheel `Scroll Up` / `Scroll Down` |
| **Toggle Pause** | `Spacebar` |
| **Change Speed** | `1` (1x), `2` (2x), `3` (3x), `5` (5x) |
| **Select Province** | `Left-Click` on province polygon |
| **Select Single Unit** | `Left-Click` on unit token |
| **Select All Units in Province** | Click "🎯 Pilih Semua Pasukan di Sini" on Province Panel |
| **Move Unit(s)** | `Right-Click` on target destination province |
| **Quick Save Game** | `F5` or TopBar "💾 Simpan" Button |
| **Quick Load Game** | `F9` or TopBar "📂 Muat" Button |

---

## 📁 Project Architecture

```
true-nation/
├── assets/
│   ├── sprites/         # Unit sprites, flags, icons
│   └── ui/              # Fonts, UI themes, audio assets
├── docs/
│   └── GAME_DESIGN_DOCUMENT.md  # Comprehensive living game design spec
├── src/
│   ├── autoload/        # Global singletons (EventBus, TimeManager)
│   ├── core/            # Country data models & core constants
│   ├── data/            # Resource assets (.tres) for countries and units
│   ├── economy/         # Economic simulation & building systems
│   ├── map/             # World map, provinces, and RTS camera
│   ├── military/        # Unit instances, movement, and combat system
│   ├── ui/              # TopBar HUD, TimeControls, Province & Unit drawers
│   └── main.tscn        # Main runtime scene
├── project.godot        # Godot 4.7 engine configuration
├── README.md            # Project overview
└── RELEASE_NOTES.md     # Version history & release changelogs
```

---

## 🚀 Getting Started

### Prerequisites
- **Godot Engine 4.3+** (Tested and verified on **Godot 4.7.2-stable**).

### Running the Project
1. Clone the repository:
   ```bash
   git clone https://github.com/imismaindra/true-nation.git
   ```
2. Open **Godot Engine**, click **Import**, and select `project.godot`.
3. Press **F5** (or click the Run icon in the top right) to launch the simulation.

---

## 📜 License
Developed with ❤️ by **Ismaindra** as an open, moddable grand strategy simulation foundation.
