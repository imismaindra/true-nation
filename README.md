# True Nation 🌍⚔️
> **Modern Grand Strategy RTS (Real-Time with Pause) Engine in Godot 4.7+**

Inspired by *Hearts of Iron IV*, *Victoria*, and *Conflict of Nations*, **True Nation** is a 2D strategic simulation game featuring tri-matra military operations (Army, Navy, Air Force), dynamic provincial territorial control, resource-driven national economy, and an event-driven tick clock engine.

---

## 🎮 Core Features (Version 0.1)

- ⏱️ **Real-Time with Pause Engine (Tick System)**
  - Dynamic game clock (`TimeManager`) emitting hourly, daily, and monthly ticks.
  - Speeds: Pause (`Space`), `1x`, `2x`, `3x`, `5x` (Numeric keys `1`, `2`, `3`, `5`).
  - Interactive top-right HUD control bar with live date display (`01 Jan 2026`).

- 🗺️ **Interactive RTS Map & Camera**
  - Smooth 2D RTS Camera (`W`, `A`, `S`, `D` pan, mouse-wheel cursor-centered zoom from `0.4x` to `2.5x`, and middle-mouse drag).
  - 7 connected strategic territories including land provinces and naval ocean straits across 3 nations:
    - 🔵 **Republic of Valoria** (Player)
    - 🔴 **Krasnovian Federation** (Rival / Enemy)
    - 🟡 **Republic of Al-Zubara** (Neutral)
  - Color-coded borders, hovered visual highlights, and contextual province inspection drawer.

- 📈 **National Economy & Resource Pipeline**
  - TopBar HUD displaying 4 vital national resources:
    - 💵 **Money** (Treasury reserves & tax revenue)
    - ⚙️ **Steel** (Industrial production output)
    - 🛢️ **Fuel** (Military logistics & operational readiness)
    - 👥 **Manpower** (Recruitment pool)
  - Daily automatic yield aggregation and dynamic delta indicators (`+125/day`).

- 🎖️ **Tri-Matra Armed Forces (Army, Navy, Air Force)**
  - **Land Forces**: Infantry Division, Armored/Tank Division.
  - **Naval Forces**: Guided Missile Frigate Fleet (traverses deep sea and straits).
  - **Air Forces**: Multi-Role Fighter Wing (traverses land and sea zones).
  - Domain-based movement validation (`LAND`, `SEA`, `AIR`), multi-hop automated waypoint navigation, and hourly movement interpolation.
  - Interactive unit selection, command dispatching (Right-Click to march), and unit detail inspector drawer.

- ⚔️ **Simulated Combat & Territorial Annexation**
  - Automatic hostile engagement upon co-presence in the same province.
  - Pulsing battle marker (`⚔️ BATTLE`) with real-time soft/hard attack simulation, defense resistance, and morale attrition.
  - Morale collapse triggers automated tactical retreat to nearest friendly territory.
  - Total defeat triggers province annexation and instant territorial border recoloring.

---

## 🕹️ Controls

| Action | Input |
|---|---|
| **Pan Camera** | `W`, `A`, `S`, `D` or Screen Edge / Middle Mouse Drag |
| **Zoom In / Out** | Mouse Wheel `Scroll Up` / `Scroll Down` |
| **Toggle Pause** | `Spacebar` |
| **Change Speed** | `1` (1x), `2` (2x), `3` (3x), `5` (5x) |
| **Select Province** | `Left-Click` on province polygon |
| **Select Unit** | `Left-Click` on unit token |
| **Move Unit** | `Right-Click` on target destination province |

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
