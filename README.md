# True Nation
> **Modern Grand Strategy RTS (Real-Time with Pause) Engine in Godot 4.7+**

Inspired by *Hearts of Iron IV*, *Victoria*, and *Conflict of Nations*, **True Nation** is a strategic simulation game featuring tri-matra military operations (Army, Navy, Air Force), dynamic provincial territorial control, resource-driven national economy, and an event-driven tick clock engine set across the Indonesian archipelago.

---

## Core Features (Version 0.4.0)

- **Total War Damage, Battle Reports & Capitulation**
  - Battles damage provincial infrastructure (up to -80% output), inflict civilian casualties, and generate detailed battle reports.
  - Countries that lose all land provinces capitulate; encircled divisions surrender and stranded production orders are cancelled.
  - Province panel exposes infrastructure damage, civilian casualties, and a paid repair action.

- **Multi-Province Movement & Box Selection**
  - BFS pathfinding across connected provinces with automatic route continuation until enemy contact.
  - Right-click drag box selection, `Ctrl+A` select-all, larger unit counters, and live personnel readout.

- **Procedural 2D Tactical Ocean Shader & Coastal Shelf Halos**
  - Continuous mathematical GLSL wave harmonics (`src/shaders/ocean_water.gdshader`) with zero texture tiling artifacts.
  - Realistic bathymetric depth gradient (Sunda/Sahul continental shelves vs deep oceanic trenches).
  - Subtle military nautical navigation grid, coordinate crosshairs, and dashed golden Equator line.
  - Glowing shallow water coastal shelf rims around all 37 Indonesian land masses.

- **Professional Military Command Ribbon UI & MapModeBar**
  - Full-width top command ribbon with glassmorphism, faction crest, modular resource chips, and NATO chronometer.
  - Dedicated tactical navigation dock (`MapModeBar`) with instant capital jump (Batavia), full map view, and C4ISR sync.
  - Crisp high-resolution SVG vector iconography (`assets/sprites/ui/`) replacing all generic emoji strings.
  - Modernized C4ISR Tactical Dark Theme (`assets/ui/tactical_theme.tres`) with Deep Navy Slate cards and Cyber Cyan accents.

- **Nusantara Archipelago Theater (37 Strategic Regions)**
  - Expansive strategic map encompassing 29 land provinces from Sabang to Merauke (Sumatra, Java, Bali/Nusra, Kalimantan, Sulawesi, Maluku, Papua).
  - 8 Strategic Maritime Chokepoints and ALKI shipping lanes (Malacca Strait, Natuna Sea, Sunda Strait, Karimata Strait, Java Sea, Makassar Strait, Flores Sea, Banda Sea).
  - Seamless nautical bathymetric ocean chart texture (`ocean_texture.png`) with shelf and deep trench depth contours.
  - Automatic Green's theorem visual centroid positioning ensuring units, labels, and facilities sit squarely on land.

- **Tactical Unit Counters & Anti-Clumping Formations**
  - Vector NATO/tactical unit symbology with streamlined organization & strength indicators.
  - Dynamic tactical offset formations (linear spacing, triangle, 2x2 grid) when multiple divisions occupy the same province.
  - Flashing tactical retreat alert when organization falls below 15%, plus direct Halt and Retreat commands.
  - Animated marching lines and orientation tracking towards target provinces.

- **Expanded Modern Military Unit Roster (8 Divisions)**
  - Infantry Division, Main Battle Tank Division, Field Artillery & MLRS (siege fortress reduction), Attack Helicopter Wing, Recon Drone Wing (UAV with 2-hop radar), Multirole Fighter Wing, Surface Frigate Fleet, and Combat Submarine Fleet (stealth camouflage).

- **Real-Time with Pause Engine (Tick System)**
  - Dynamic game clock (`TimeManager`) emitting hourly, daily, and monthly ticks.
  - Speeds: Pause (`Space`), `1x`, `2x`, `3x`, `5x` (Numeric keys `1`, `2`, `3`, `5`).
  - Interactive top-right HUD control bar with live date display (`01 Jan 2026`).

- **Autonomous Strategic AI**
  - Independent AI rival manages logistics, constructs munitions plants when stockpiles run low, fortifies contested borders (+35% Defense), and opens naval/air infrastructure.

- **Military Supply Chain & Logistics**
  - Finished war materials: Arms (assembly) & Munitions (hourly combat consumption).
  - Supply outage penalties (-50% attack, accelerated morale loss).

- **Dynamic Fog of War**
  - 3-tier visibility (`VISIBLE`, `FOGGED`, `UNKNOWN`) with aerial recon and submarine stealth camouflage.

- **Procedural Tactical Sound FX & Atmosphere**
  - Integrated procedural 16-bit audio synthesizer (`AudioManager`): radio chirp, tactical click, movement roger tones, cannon fire, rifle bursts, and war sirens.

- **Safe JSON Save & Load Persistence**
  - Complete state persistence (`user://savegame.json`) serializing time, faction economics, 37 provinces, facilities, and all military divisions. Quick Save (`F5`) and Quick Load (`F9`).

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
| **Move Unit(s)** | `Right-Click` on target destination province (multi-province route) |
| **Box Select Units** | `Right-Click Drag` |
| **Select All Units** | `Ctrl+A` |
| **Quick Save Game** | `F5` or TopBar Menu "Simpan" |
| **Quick Load Game** | `F9` or TopBar Menu "Muat" |

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
