# Release Notes - True Nation v0.1

**Release Date:** 19 Oktober 2026  
**Version:** `v0.1`  
**Milestone:** Foundation Engine & Core Mechanics  
**Compatibility:** Godot Engine 4.3 - 4.7.2+ (Forward+ & Compatibility)

---

## 🌟 Ringkasan Rilis (Release Overview)

Versi **v0.1** menandai fondasi awal yang utuh dari engine game strategi modern bertempo **Real-Time with Pause** (*Hearts of Iron IV* / *Conflict of Nations* style) yang dibangun dari nol menggunakan Godot 4. Versi ini mengintegrasikan sistem waktu diskrit berbasis tick, navigasi kamera 2D fleksibel, peta wilayah multi-faksi interaktif, HUD ekonomi dinamis, serta sistem militer gabungan 3 matra (AD, AL, AU) beserta kalkulasi pertempuran dan aneksasi teritori secara otomatis.

---

## 🚀 Fitur yang Diimplementasikan (Changelog)

### 1. Sistem Inti & Arsitektur Game (Core Scaffolding)
- Struktur modular berbasis *Data-Driven Architecture* menggunakan Godot Custom Resources (`Country`, `UnitData`, `BuildingData`).
- Arsitektur *Decoupled Event-Driven* menggunakan singleton global [EventBus](file:///d:/03%20ProjectGame/true-nation/src/autoload/event_bus.gd) untuk komunikasi antar sistem tanpa circular dependency.

### 2. TimeManager & Real-Time with Pause Engine
- Singleton [TimeManager](file:///d:/03%20ProjectGame/true-nation/src/autoload/time_manager.gd) dengan kontrol kecepatan real-time:
  - Pause (`Spacebar` atau Speed 0)
  - Speed 1x (1 jam game = 1.0 detik riil)
  - Speed 2x (1 jam game = 0.5 detik riil)
  - Speed 3x (1 jam game = 0.25 detik riil)
  - Speed 5x (1 jam game = 0.1 detik riil)
- Pemancar sinyal siklus waktu: `hourly_tick`, `daily_tick`, dan `monthly_tick`.
- HUD [TimeControls](file:///d:/03%20ProjectGame/true-nation/src/ui/time_controls.tscn) di pojok kanan atas dengan penampil tanggal riil (`DD MMM YYYY`), jam digital, dan tombol kecepatan responsif.

### 3. Kamera RTS 2D (RTS Camera 2D)
- Komponen kamera taktis [rts_camera_2d.gd](file:///d:/03%20ProjectGame/true-nation/src/map/rts_camera_2d.gd) dengan:
  - Pan halus via tombol keyboard `W`, `A`, `S`, `D` dan drag mouse tombol tengah.
  - Zoom halus berpusat pada kursor mouse (*zoom to mouse position*) dari `0.4x` hingga `2.5x`.
  - Pembatasan wilayah gerak kamera (*boundary clamping*) agar pandangan tidak keluar dari batas area peta dunia.

### 4. Peta Wilayah Interaktif (Interactive Province Map)
- 7 wilayah teritori strategis:
  - `prov_north_capital` (Valoria - Ibukota)
  - `prov_west_coast` (Valoria - Pesisir Industri)
  - `prov_iron_valley` (Valoria - Tambang Besi)
  - `prov_strait_ocean` (Zona Laut / Selat Strategis)
  - `prov_red_citadel` (Krasnovia - Benteng Pertahanan)
  - `prov_krasno_plain` (Krasnovia - Dataran Rendah)
  - `prov_neutral_oasis` (Al-Zubara - Oasis Netral)
- Visualisasi poligon dinamis: warna kepemilikan negara, garis batas teritorial tebal, dan efek highlight saat kursor hover.
- Panel inspeksi wilayah [ProvincePanel](file:///d:/03%20ProjectGame/true-nation/src/ui/province_panel.tscn) yang menampilkan tipe medan, populasi, pemilik, dan hasil sumber daya harian.

### 5. Sistem Ekonomi & HUD TopBar
- 4 pilar sumber daya nasional:
  - 💵 **Money**: Cadangan kas negara & pemeliharaan pasukan.
  - ⚙️ **Steel**: Logam industri untuk produksi peralatan tempur.
  - 🛢️ **Fuel**: Bahan bakar operasional armada laut, udara, dan divisi tank.
  - 👥 **Manpower**: Pasokan tenaga manusia untuk rekrutmen divisi militer.
- Agregasi otomatis pendapatan harian via [EconomyManager](file:///d:/03%20ProjectGame/true-nation/src/economy/economy_manager.gd) pada setiap `daily_tick`.
- [TopBar HUD](file:///d:/03%20ProjectGame/true-nation/src/ui/top_bar.tscn) di bagian atas layar dengan indikator delta surplus/defisit harian.

### 6. Matra Darat & Sistem Pergerakan (Army & Movement)
- Preset data unit militer:
  - Divisi Infanteri (`infantry_division.tres`)
  - Divisi Kavaleri / Tank (`tank_division.tres`)
- Token visual unit [MilitaryUnit](file:///d:/03%20ProjectGame/true-nation/src/military/unit.gd) dengan badge matra, bar HP & Morale, serta penanda seleksi bercahaya.
- Sistem pergerakan multi-hop berbasis jam game (`hourly_tick`) dengan kalkulasi kecepatan medan dan interpolasi posisi visual yang halus antar titik ibukota provinsi.
- Drawer inspeksi unit [UnitPanel](file:///d:/03%20ProjectGame/true-nation/src/ui/unit_panel.tscn) dengan detail status divisi dan tombol komando henti.

### 7. Matra Laut, Udara & Sistem Pertempuran (Navy, Air Force & Combat)
- Dukungan penuh Tri-Matra:
  - Armada Laut: Frigate Fleet (`frigate_fleet.tres`) - bergerak hanya di zona perairan/laut.
  - Skuadron Udara: Fighter Wing (`fighter_wing.tres`) - dapat melintasi daratan maupun perairan bebas hambatan.
  - Validasi domain otomatis (`LAND`, `SEA`, `AIR`) saat pemain memberikan perintah pergerakan (klik kanan).
- [CombatSystem](file:///d:/03%20ProjectGame/true-nation/src/military/combat_system.gd) real-time:
  - Deteksi otomatis saat unit bermusuhan berada di provinsi yang sama.
  - Marker pertempuran visual berdenyut (`⚔️ BATTLE`) di peta.
  - Pertukaran serangan harian (Soft/Hard Attack vs Defense) dengan pengurangan HP dan Morale.
  - Penarikan mundur taktis otomatis (*tactical retreat*) jika morale unit hancur.
  - Aneksasi wilayah otomatis saat semua pasukan musuh terusir/hancur, mengubah warna teritori dan kepemilikan provinsi secara instan.

---

## 🛠️ Verifikasi Mesin & Kualitas Kode
- Seluruh scene dan script telah diuji dan divalidasi bebas error pada console Godot 4.7.2 (`--headless --quit-after 2`).
- Penanganan caching referensi class pada Godot Language Server untuk stabilitas tinggi tanpa circular autoload issues.

---

## 📋 Roadmap Versi Selanjutnya (v0.2+)
- [ ] Sistem rekrutmen unit militer baru via antarmuka provinsi.
- [ ] Sistem konstruksi bangunan (Pabrik Militer, Kilang Minyak, Pangkalan Udara, Galangan Kapal).
- [ ] Sistem Fog of War (kabut perang) berbasis radar dan garis pandang perbatasan.
- [ ] AI dasar untuk negara lawan (Krasnovian Federation).
