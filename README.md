# True Nation 🌍⚔️
> **Modern Grand Strategy RTS (Real-Time with Pause) Engine in Godot 4.7+**

Inspired by *Hearts of Iron IV*, *Victoria*, and *Conflict of Nations*, **True Nation** is a 2D strategic simulation game featuring tri-matra military operations (Army, Navy, Air Force), dynamic provincial territorial control, resource-driven national economy, and an event-driven tick clock engine.

---

## 🎮 Core Features (Version 0.2)

- ⏱️ **Real-Time with Pause Engine (Tick System)**
  - Dynamic game clock (`TimeManager`) emitting hourly, daily, and monthly ticks.
  - Speeds: Pause (`Space`), `1x`, `2x`, `3x`, `5x` (Numeric keys `1`, `2`, `3`, `5`).
  - Interactive top-right HUD control bar with live date display (`01 Jan 2026`).

- 🏭 **Military Supply Chain & Logistics (Option A: Arms & Munitions)**
  - Raw resources (Steel, Fuel, Money, Manpower) processed into finished war materials:
    - 🔫 **Arms (Persenjataan)**: Required to recruit and assemble new military divisions.
    - 🚀 **Munitions (Amunisi & Rudal)**: Consumed hourly by combat units engaged in battle.
  - **Combat Supply Consumption & Supply Outage**: Units fighting without ammunition suffer a heavy -50% Attack penalty and accelerated morale collapse.

- 📦 **Recruitment & Construction Queues**
  - **Unit Training**: `ProductionManager` manages discrete hourly assembly queues with 80% refund cancellation.
  - **Provincial Infrastructure**: `BuildingManager` manages the construction of 7 strategic facilities:
    - Arms Factory, Munitions Plant, Steel Foundry, Oil Refinery, Naval Dockyard, Airbase, Fortification.
  - Floating `ProductionQueuePanel` widget displays real-time progress for both unit training and construction projects.

- 🤖 **Autonomous Strategic Enemy AI (FSM)**
  - Independent AI controller (`AIManager`) for rival factions:
    - Resource assessment, independent division recruitment, neutral province expansion (Sumatera Timur), coordinated counter-attacks, border garrisons, and graph BFS multi-hop pathfinding.

- 🌫️ **Fog of War & Aerial Reconnaissance**
  - 3-tier dynamic visibility system (`VISIBLE`, `FOGGED`, `UNKNOWN`).
  - Reconnaissance sensors: Airbases and Fighter Jets uncover distant provinces and reveal hidden enemy troops.
  - Enemy units outside sensor lines of sight are visually camouflaged.

- 🎨 **Modern Military Top-Down Visuals & Combat FX**
  - High-resolution top-down unit sprites across 28 modern military variants (Army, Armor, Air, and Navy).
  - Dynamic animated Marching Line showing unit destination.
  - Gunfire muzzle flashes and smoke puff particle effects during combat.
  - Strategic Pop-Up Notification Banner (`NotificationBanner`) for major geopolitical events.

- 🗺️ **Interactive RTS Map & Tri-Matra Forces**
  - Smooth 2D RTS Camera with WASD pan and mouse-wheel zoom.
  - Land, Sea, and Air domains with amphibious sea-lane traversal and coastal harbor requirements.

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
