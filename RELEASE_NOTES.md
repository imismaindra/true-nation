# Release Notes - True Nation v0.2.1

**Release Date:** 19 Oktober 2026  
**Version:** `v0.2.1`  
**Milestone:** Polish, Tactical Unit Roster, AI Autonomous Construction & Quality of Life (QoL)  
**Compatibility:** Godot Engine 4.3 - 4.7.2+ (Forward+ & Compatibility)

---

## 🌟 Ringkasan Rilis (Release Overview v0.2.1)

Versi **v0.2.1** hadir sebagai pematangan menyeluruh (*polish & tactical expansion*) sebelum melangkah ke Peta Raksasa Nusantara di Versi 0.3. Pembaruan ini mengimplementasikan penuh seluruh **6 Sprint Master Roadmap v0.2.1**:
1. **Orientasi & Rotasi Halus Pasukan**: Rotasi dinamis haluan jet tempur, kapal perang, serta pembalikan moncong tank secara presisi mengikuti arah gerak.
2. **Ekspansi Roster Militer Modern**: 4 divisi tempur baru memanfaatkan aset 28 sprite militer (Artileri Medan / MLRS, Helikopter Serbu, Drone Pengintai UAV, Kapal Selam Tempur).
3. **Kecerdasan Buatan (AI) Konstruksi Fasilitas**: AI rival mampu mendeteksi krisis logistik dan membangun Pabrik Amunisi, Benteng Perbatasan, serta Pangkalan Udara/Laut secara mandiri.
4. **Tooltip Neraca Ekonomi & Seleksi Korps Gabungan (Multi-Select)**: Visibilitas rinci pendapatan vs pengeluaran komoditas pada TopBar HUD dan tombol gerak serentak seluruh garnisun provinsi.
5. **Sistem Tata Suara Atmosfer Tempur (Audio Manager)**: Modul audio singleton prosedural 16-bit mandiri (*radio click, movement order beep, booming cannon blast, automatic gunfire, alert sirens*).
6. **Sistem Simpan & Muat Permainan (Save & Load Manager)**: Persistensi data lengkap berbasis JSON (`user://savegame.json`) dengan tombol UI dan shortcut F5 (Save) / F9 (Load).

---

# Release Notes - True Nation v0.2

**Release Date:** 19 Oktober 2026  
**Version:** `v0.2`  
**Milestone:** Military Supply Chain, Industry, Tactical AI & Fog of War  
**Compatibility:** Godot Engine 4.3 - 4.7.2+ (Forward+ & Compatibility)

---

## 🌟 Ringkasan Rilis (Release Overview)

Versi **v0.2** membawa lompatan besar pada aspek simulasi geopolitik dan perang modern dengan memperkenalkan **Rantai Pasok Industri Militer (Model Opsi A: Persenjataan & Amunisi/Rudal)**, antrian rekrutmen dan konstruksi fasilitas, kecerdasan buatan musuh mandiri (Enemy AI), sistem kabut perang dinamis (Fog of War) dengan sensor radar/jet, serta peremajaan visual sprite kendaraan pixel art modern dengan partikel tembakan mesiu.

---

## 🚀 Fitur Baru & Peningkatan (Changelog Versi 0.2)

### 1. Rantai Pasok Industri Militer & Logistik Tempur (Step 8 & 9)
- Penambahan dua komoditas strategis nasional:
  - 🔫 **Persenjataan Militer (Arms)**: Komoditas jadi hasil olahan pabrik senjata untuk melatih divisi baru.
  - 🚀 **Amunisi & Rudal (Munitions)**: Komoditas tempur habis pakai yang dikonsumsi per jam saat pasukan bertempur.
- **TopBar HUD**: Indikator stok dan laju harian `Arms` dan `Munitions` terpasang secara langsung di bilah komando atas.
- **Konsumsi Amunisi Tempur Real-Time (`Combat Supply`)**:
  - Infanteri: 1.5 Amunisi / jam tempur.
  - Tank MBT: 4.0 Amunisi / jam tempur.
  - Armada Kapal: 6.0 Rudal/Amunisi / jam tempur.
  - Skuadron Udara: 8.0 Rudal/Amunisi / jam tempur.
- **Krisis Logistik Tempur (`Supply Outage`)**: Pasukan yang kehabisan cadangan amunisi nasional menderita penalti ofensif -50% Attack dan keruntuhan moral +50%.

### 2. Sistem Rekrutmen & Antrian Manufaktur (`ProductionManager`)
- Modul [ProductionManager](file:///d:/03%20ProjectGame/true-nation/src/economy/production_manager.gd) mengelola antrian pelatihan divisi militer secara presisi per jam (*hourly tick*).
- Dialog pemilihan divisi militer [RecruitmentDialog](file:///d:/03%20ProjectGame/true-nation/src/ui/recruitment_dialog.tscn) terintegrasi pada tombol "🎖️ Rekrut Divisi" di drawer provinsi.
- Tombol pembatalan pesanan berfitur refund dana dan material sebesar 80%.

### 3. Infrastruktur Provinsi & Pabrik Militer (`BuildingManager`)
- 7 tipe fasilitas dan pabrik strategis dalam bentuk Resource terpisah di `src/data/buildings/`:
  - 🔫 **Pabrik Senjata Militer (Arms Factory)**: Memproses 5 baja & $30 kas menjadi `+20 Persenjataan/hari`.
  - 🚀 **Pabrik Amunisi & Rudal (Munitions Plant)**: Memproses 2 baja, 4 minyak & $40 kas menjadi `+25 Amunisi/hari`.
  - ⚙️ **Industri Baja Tambang (Steel Foundry)**: Menambah ekstraksi bijih besi `+15 Baja/hari`.
  - 🛢️ **Kilang Minyak Bumi (Oil Refinery)**: Menambah output pemurnian minyak `+10 Minyak/hari`.
  - ⚓ **Pangkalan Angkatan Laut (Naval Dockyard)**: Syarat utama perakitan armada kapal perang di wilayah pesisir.
  - 🛫 **Pangkalan Angkatan Udara (Airbase)**: Syarat perakitan jet tempur & memberikan sensor radar udara.
  - 🏰 **Benteng Perbatasan (Fortification)**: Memberikan reduksi damage garnisun sebesar `+35% Defense`.
- Modul [BuildingManager](file:///d:/03%20ProjectGame/true-nation/src/economy/building_manager.gd) dan dialog pembangunan [ConstructionDialog](file:///d:/03%20ProjectGame/true-nation/src/ui/construction_dialog.tscn).
- Widget melayang [ProductionQueuePanel](file:///d:/03%20ProjectGame/true-nation/src/ui/production_queue_panel.tscn) menampilkan progres pelatihan divisi dan konstruksi fasilitas secara simultan.

### 4. Kecerdasan Buatan Musuh Mandiri (`AIManager`) (Step 10)
- Kontroler AI non-pemain berbasis Finite-State Machine (FSM) yang aktif setiap detak harian (*daily tick*):
  - **Evaluasi Strategis**: Menakar rasio kekuatan pasukan dan logistik amunisi.
  - **Rekrutmen Mandiri**: Otomatis melatih divisi tank atau infanteri baru jika pasukannya menyusut.
  - **Ekspansi Wilayah Netral**: Menavigasi dan menganeksasi wilayah netral (Sumatera Timur).
  - **Invasi & Counter-Attack**: Melancarkan serangan balas terkoordinasi jika stok amunisi mencukupi.
  - **Garnisun Perbatasan**: Menjaga provinsi perbatasan yang rawan diserang pemain.
  - **BFS Pathfinding**: Navigasi multi-hop antar-pulau melalui jalur darat dan selat laut secara otonom.

### 5. Kabut Perang (Fog of War) & Pengintaian Taktis (Step 11)
- Modul [FogOfWarManager](file:///d:/03%20ProjectGame/true-nation/src/map/fog_of_war_manager.gd) dengan 3 status visibilitas visual:
  - `VISIBLE`: Terang penuh (teritori pemain, lokasi unit kawan, dan radius sensor radar/jet).
  - `FOGGED`: Tertutup kabut remang-remang (pernah dijelajahi, unit musuh tersembunyi).
  - `UNKNOWN`: Gelap gulita (belum pernah diintai).
- **Pengintaian Udara**: Skuadron jet tempur membuka kabut perang hingga 1 hop provinsi tetangga.
- **Kamuflase Tempur**: Unit musuh di luar jangkauan sensor disembunyikan secara visual (`unit.visible = false`).

### 6. Integrasi Sprite Top-Down Militer Modern (28 Varian Bersih) (Step 12)
- Visual top-down RTS modern yang bersih dengan transparansi penuh dari `Modern Military Unit Sprite Sheet`:
  - 🪖 **Tentara Modern (7 Varian)**: Rifleman (default), Rifleman Bergerak, Sniper Ghillie, Machine Gunner, Medic, Engineer, AT Specialist.
  - 🚜 **Tank & Kendaraan Lapis Baja (7 Varian)**: Main Battle Tank (default), Light Tank, IFV Bradley, APC 8x8, Artileri 155mm, MLRS Rocket Launcher, Recon Vehicle (Humvee).
  - ✈️ **Pesawat & Helikopter (7 Varian)**: Fighter Jet F-16 (default), Multirole Jet Su-30, Attack Aircraft A-10, Transport C-130, Helikopter Serbu AH-64, Drone Pengintai UAV, Pesawat Radar AWACS.
  - 🚢 **Armada Tempur Laut (7 Varian)**: Fregat Patroli (default), Destroyer Peluru Kendali, Korvet Cepat, Kapal Pendarat Amfibi (LSD), Kapal Induk Supercarrier, Kapal Selam Tempur, Kapal Patroli Pantai.
- Skala sprite otomatis proporsional (`scale = Vector2(0.28, 0.28)`) di atas kartu divisi dan peta taktis.
- Dynamic Unit Loader pada [unit.gd](file:///d:/03%20ProjectGame/true-nation/src/military/unit.gd) yang otomatis memuat tekstur spesifik berdasarkan `UnitData.UnitType`.
- Animasi mengambang idle (*gentle float*) untuk seluruh sprite di atas peta.
- Garis pandu rute beranimasi (*Marching Line*) dari posisi unit menuju provinsi target.
- Efek partikel tembakan meriam (*muzzle flash sparks*) dan asap mesiu (*smoke puff*) saat bertempur.
- Banner notifikasi pop-up elegan [NotificationBanner](file:///d:/03%20ProjectGame/true-nation/src/ui/notification_banner.tscn) di HUD atas saat wilayah direbut, divisi selesai dilatih, atau terjadi krisis amunisi.

---

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
