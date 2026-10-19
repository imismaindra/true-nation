# TRUE NATION - Game Design & Technical Architecture Document
**Genre**: 2D Grand Strategy / War Game (Real-Time with Pause)  
**Engine**: Godot Engine 4 (GL Compatibility / Jolt Physics)  
**Status**: Fase 1 - Fondasi Proyek  
**Tanggal Mulai**: 19 Oktober 2026  

---

## 1. Visi & Konsep Permainan
**True Nation** adalah game simulasi perang dan strategi peta berskala nasional/global dengan tempo **Real-Time with Pause**. Pemain mengelola negara dari aspek geopolitik, industri ekonomi, hingga komando militer matra darat, laut, dan udara dalam merebut serta mempertahankan kedaulatan teritorial.

### Fitur Kunci:
1. **Real-Time with Pause**: Waktu berjalan dinamis berdasarkan detak jam/hari (*tick system*). Pemain dapat menghentikan waktu kapan saja (*Spacebar*) untuk merancang manuver, atau mempercepat waktu (*1x, 2x, 5x*).
2. **Tri-Matra Terintegrasi (Darat, Laut, Udara)**: Sistem militer komprehensif di mana setiap matra memiliki domain geografis dan peran spesifik.
3. **Logistik & Ekonomi Berkelanjutan**: Unit membutuhkan suplai bahan bakar (*Fuel*), amunisi/material (*Steel*), biaya pemeliharaan (*Upkeep*), dan cadangan tenaga kerja (*Manpower*).
4. **Peta Wilayah Interaktif (2D Top-Down)**: Wilayah berbasis provinsi/zona teritorial yang saling terhubung melalui graf (*Adjacency Graph*).

---

## 2. Sistem Inti (Core Systems)

### 2.1. Sistem Waktu (Game Clock & Tick Engine)
Waktu diatur oleh `TimeManager` (Autoload Singleton):
*   **Hourly Tick (Tiap Jam Game)**:
    *   Progres pergerakan unit antar provinsi dihitung.
    *   Pertempuran aktif menghitung *damage* terhadap *Strength* (HP) dan *Organization* (Moral).
*   **Daily Tick (Tiap Hari Game / 24 Jam)**:
    *   Kalkulasi pajak/kas negara.
    *   Produksi industri dan konsumsi bahan bakar (*Fuel*).
    *   Pertumbuhan populasi dan *Manpower*.
*   **Kontrol Kecepatan**:
    *   `0`: PAUSE
    *   `1`: 1 Jam = 1.0 detik
    *   `2`: 1 Jam = 0.5 detik
    *   `3`: 1 Jam = 0.2 detik

### 2.2. Sistem Ekonomi & Sumber Daya
Setiap negara mengelola 4 pilar sumber daya:
1.  **Uang / Kas Negara (Treasury)**: Digunakan untuk rekrutmen, riset, dan *upkeep* militer.
2.  **Baja & Material Industri (Steel/Production)**: Digunakan untuk memproduksi persenjataan berat (Tank, Pesawat, Kapal).
3.  **Bahan Bakar Minyak (Fuel)**: Pasokan vital armada kendaraan bermotor, pesawat, dan kapal perang.
4.  **Tenaga Kerja (Manpower)**: Populasi yang siap direkrut menjadi tentara.

### 2.3. Pembangunan Fasilitas (Province Infrastructure)
Tiap provinsi dapat dibangun infrastruktur khusus:
*   **Pusat Industri / Pabrik**: Meningkatkan kapasitas produksi material per hari.
*   **Barak Militer (Barracks)**: Pusat rekrutmen divisi darat.
*   **Pangkalan Udara (Airbase)**: Tempat pangkalan skuadron jet/drone dan memperluas radius misi udara.
*   **Pelabuhan & Galangan (Naval Shipyard)**: Tempat bersandar dan produksi armada kapal perang (khusus provinsi pesisir).
*   **Benteng & Bunker**: Memberikan bonus pertahanan terhadap invasi darat dan pengeboman.

---

## 3. Roster & Spesifikasi Unit (Berdasarkan Lembar Aset)

### 3.1. Angkatan Darat (AD)
*Pengontrol teritori daratan dan penakluk kota.*

| Unit | Peran Taktis | Keunggulan | Biaya Utama |
| :--- | :--- | :--- | :--- |
| **Infanteri (Rifleman, Medic, Sniper, AT, Engineer)** | Pasukan garis depan & penjaga wilayah | Biaya murah, pertahanan kokoh di kota & hutan | Manpower, Kas |
| **Light Tank (Scorpion / LAV-25)** | Pengintai cepat & penyerang garis samping (*Flanking*) | Sangat cepat, membuka kabut perang | Baja, Sedikit BBM |
| **IFV / APC (BMP-2, Bradley, 8x8)** | Pengangkut infanteri mekanis | Melindungi infanteri bergerak secepat tank | Baja, BBM |
| **Main Battle Tank (MBT - Leopard 2, Abrams)** | Penembus pertahanan utama | Daya serang dan ketahanan tinggi | Baja Tinggi, BBM Tinggi |
| **Self-Propelled Artillery (155mm)** | Bantuan tembakan jarak jauh | Menembak lintas provinsi tanpa kontak langsung | Baja, Amunisi, BBM |

### 3.2. Angkatan Udara (AU)
*Supremasi udara, pengintaian, dan serangan strategis.*

| Unit | Peran Taktis | Misi Operasional | Biaya Utama |
| :--- | :--- | :--- | :--- |
| **Fighter Jet (F-16 / Rafale)** | Pencegat & Penguasa Langit | *Air Superiority* (Melumpuhkan pesawat lawan) | BBM Tinggi, Baja |
| **Multirole Fighter (Su-30 / F-15)** | Fleksibel udara-ke-udara dan udara-ke-darat | *Air Superiority* + *CAS* | BBM Sangat Tinggi, Baja |
| **Attack Aircraft (A-10)** | Penghancur armada darat | *Close Air Support* (Bonus damage ke tank lawan) | BBM, Baja |
| **Transport Aircraft (C-130)** | Mobilitas pasukan lintas benua | Penerjunan Pasukan Payung (*Paratroopers*) | BBM, Kas |
| **Helicopter (AH-64 / Black Hawk)** | Mobilitas taktis & serang darat cepat | Serangan cepat darat & evakuasi | BBM, Baja |
| **Drone / UAV (MQ-9)** | Intelijen & serangan presisi hemat biaya | Membuka *Fog of War* tanpa risiko pilot gugur | BBM Rendah, Baja |

### 3.3. Angkatan Laut (AL)
*Penguasa jalur perairan, pengawal logistik, dan proyeksi kekuatan laut.*

| Unit | Peran Taktis | Keunggulan | Biaya Utama |
| :--- | :--- | :--- | :--- |
| **Corvette** | Kapal patroli perairan pesisir | Cepat, murah, pertahanan ranjau & infiltrasi | Baja, BBM |
| **Frigate** | Pengawal konvoi logistik | Pertahanan anti-kapal selam & anti-udara | Baja, BBM |
| **Destroyer** | Kapal tempur garis depan laut | Daya hancur tinggi terhadap armada musuh | Baja Tinggi, BBM |
| **Landing Ship Dock (LSD)** | Kapal angkut amfibi | Membawa infanteri & tank untuk invasi pantai | Baja, Manpower |
| **Aircraft Carrier** | Pangkalan udara terapung | Membawa skuadron pesawat jet ke samudera | Paling Mahal (Semua Resource) |

---

## 4. Arsitektur Folder Proyek (Godot 4)

```text
res://
├── assets/
│   ├── sprites/
│   │   ├── units/
│   │   │   ├── army/            # Sprites unit darat
│   │   │   ├── navy/            # Sprites kapal laut
│   │   │   └── air/             # Sprites pesawat udara
│   │   ├── map/                 # Tekstur medan, ikon provinsi
│   │   └── ui/                  # Ikon HUD, tombol, panel
│   └── fonts/                   # Font antarmuka
├── docs/                        # Dokumentasi desain & catatan pengembangan
├── src/
│   ├── autoload/
│   │   ├── time_manager.gd      # Kontrol waktu, pause, hourly/daily ticks
│   │   └── event_bus.gd         # Global signal event dispatcher
│   ├── core/
│   │   ├── country.gd           # Data negara/faksi
│   │   ├── game_manager.gd      # State loop utama
│   │   └── game_state.gd        # Data penyimpanan sesi
│   ├── economy/
│   │   ├── economy_manager.gd   # Kalkulasi pemasukan & konsumsi harian
│   │   └── building_data.gd     # Resource definisi tipe bangunan
│   ├── map/
│   │   ├── map_manager.gd       # Graph koneksi antar provinsi, pathfinding
│   │   ├── province.gd          # Logika dan data per provinsi
│   │   └── rts_camera_2d.gd     # Kontrol kamera WASD, drag, zoom
│   ├── military/
│   │   ├── unit_data.gd         # Resource data statistik unit
│   │   ├── unit.gd              # Controller node unit di peta
│   │   └── combat_system.gd     # Logika kalkulasi pertempuran per tick
│   └── ui/
│       ├── hud.tscn             # Bar atas (Uang, Baja, Minyak, Manpower, Waktu)
│       ├── time_controls.tscn   # Tombol Pause, 1x, 2x, 3x
│       ├── province_panel.tscn  # Panel inspeksi provinsi & tombol bangun
│       └── unit_panel.tscn      # Panel detail unit terpilih
```

---

## 5. Roadmap Pengembangan & Status

- [x] **Langkah 1: Setup Fondasi Struktur & Folder Proyek** *(SELESAI - 19 Okt 2026)*
  - Pembuatan struktur direktori lengkap: `src/` (`autoload`, `core`, `economy`, `map`, `military`, `ui`), `assets/` (`sprites`, `fonts`), dan `docs/`.
  - Implementasi `EventBus` (`src/autoload/event_bus.gd`) dan registrasi otomatis di `project.godot`.
  - Pembuatan fondasi class & data model:
    - `Country` (`src/core/country.gd`): Mengatur data negara, kas, baja, BBM, dan manpower.
    - `UnitData` (`src/military/unit_data.gd`): Spesifikasi unit matra darat, laut, dan udara lengkap sesuai lembar aset.
    - `BuildingData` (`src/economy/building_data.gd`): Spesifikasi pabrik, pangkalan udara, pelabuhan, benteng, dsb.
    - `Province` (`src/map/province.gd`): Entitas wilayah dan node interaksi graf teritorial.
- [x] **Langkah 2: TimeManager & Kontrol Waktu (Real-Time with Pause)** *(SELESAI - 19 Okt 2026)*
  - Implementasi Singleton `TimeManager` (`src/autoload/time_manager.gd`) dengan sinyal `hourly_tick`, `daily_tick`, `monthly_tick`.
  - Registrasi `TimeManager` di `project.godot` di bawah section `[autoload]`.
  - Kontrol kecepatan: PAUSED (0x), NORMAL (1x), FAST (2x), VERY_FAST (3x), SUPER_FAST (5x).
  - Shortcut keyboard global: `Space` (Toggle Pause), `1` (1x), `2` (2x), `3` (3x), `4/5` (5x).
  - Komponen UI Jam & Kontrol Waktu: `src/ui/time_controls.gd` dan `src/ui/time_controls.tscn` (Label Jam, Tanggal, tombol interaktif dengan highlight warna aktif).
- [x] **Langkah 3: Kamera RTS 2D (Pan & Zoom)** *(SELESAI - 19 Okt 2026)*
  - Implementasi `RTSCamera2D` (`src/map/rts_camera_2d.gd` & `src/map/rts_camera_2d.tscn`).
  - Kontrol navigasi: Keyboard Pan (`WASD` & Arrow Keys) dengan penyesuaian kecepatan otomatis terhadap level zoom.
  - Mouse Drag Pan (Middle Click Drag).
  - Smooth Zoom ke posisi kursor (*Zoom towards mouse*) dengan lerp interpolasi halus.
  - Batas area peta (*Camera Boundary Clamping*) untuk mencegah kamera keluar ke ruang kosong.
- [x] **Langkah 4: Prototype Peta Wilayah Interaktif** *(SELESAI - 19 Okt 2026)*
  - Implementasi komponen poligon interaktif `Province` (`src/map/province.gd` & `src/map/province.tscn`):
    - Visualisasi poligon dinamis berbasis warna negara penguasa / zona laut.
    - Garis perbatasan (`Line2D`) dengan respon visual saat hover (putih) dan seleksi (kuning emas).
    - Centroid label penamaan wilayah terpusat otomatis.
  - Implementasi `MapManager` (`src/map/map_manager.gd`):
    - Pengelolaan daftar provinsi dan graf jalur koneksi rute militer (`Connections`).
    - Jalur visual darat (emas transparan) dan laut (biru transparan).
    - Logika seleksi tunggal dan deseleksi via klik kanan.
  - Pembuatan Scene `WorldMap` (`src/map/world_map.tscn`) dengan 7 wilayah strategis (Batavia, Jatim, Laut Jawa, Selat Karimata, Borneo Selatan, Borneo Barat, Sumatera Timur).
  - Tiga Faksi Negara: Republik Nusantara (Pemain/Biru), Koalisi Utara (Rival/Merah), Persemakmuran Maritim (Netral/Hijau).
  - Panel Inspeksi Wilayah (`src/ui/province_panel.gd` & `src/ui/province_panel.tscn`):
    - Menampilkan nama, tipe medan, bendera & negara pengontrol, output harian (uang, baja, BBM), dan jumlah populasi.
- [x] **Langkah 5: HUD Atas & Sistem Ekonomi Awal** *(SELESAI - 19 Okt 2026)*
  - Implementasi `EconomyManager` (`src/economy/economy_manager.gd`):
    - Mengkalkulasi pendapatan harian agregat (kas negara, baja, bahan bakar minyak, dan pertumbuhan manpower) dari seluruh provinsi yang dikuasai negara pemain.
    - Sinkronisasi otomatis dengan detak harian `TimeManager.daily_tick`.
  - Implementasi HUD Atas `TopBar` (`src/ui/top_bar.gd` & `src/ui/top_bar.tscn`):
    - Bilah komando terintegrasi di bagian atas layar:
      - Profil negara (bendera & nama faksi).
      - Indikator Kas Negara (dengan format singkatan K/M dan laju harian `+85/hari` berwarna hijau dinamis).
      - Indikator Baja/Industri (`+27/hari`).
      - Indikator Bahan Bakar Minyak (`+7/hari`).
      - Indikator Cadangan Manpower (`+430/hari`).
      - Jam, kalender dinamis, dan tombol pengatur kecepatan waktu (`TimeControls`).
  - Integrasi node `EconomyManager` dan `TopBar` ke dalam `src/main.tscn`.
- [x] **Langkah 6: Sistem Unit Darat & Pergerakan Nyata** *(SELESAI - 19 Okt 2026)*
  - Pembuatan preset resource unit:
    - `src/data/units/infantry_division.tres` (Divisi Infanteri Mekanis - Pertahanan tinggi, murah).
    - `src/data/units/tank_division.tres` (Resimen Kavaleri Tank MBT - Kecepatan tinggi, daya serang tembus keras).
  - Implementasi `MilitaryUnit` (`src/military/unit.gd` & `src/military/unit.tscn`):
    - Badge divisi gaya militer modern dengan ikon tipe unit (🪖 Infanteri, 🚜 Tank MBT), bendera faksi, dan bar moral tempur (*Organization*).
    - Bar pergerakan (*Movement Progress Bar*) yang aktif saat unit bergerak.
    - Cincin seleksi unit (*Selection Ring*) berwarna emas.
    - Integrasi pergerakan real-time berkecepatan dinamis yang terhubung ke detak per jam `TimeManager.hourly_tick`.
    - Interpolasi pergerakan visual halus (*smooth lerp*) antar titik tengah provinsi bertetangga.
    - Mekanisme perebutan teritorial (*Territory Capture*): Saat unit tiba di wilayah musuh/netral, kepemilikan provinsi otomatis berpindah ke negara pemilik unit dan visual teritorial diperbarui seketika.
  - Implementasi `MilitaryManager` (`src/military/military_manager.gd` & `src/military/military_manager.tscn`):
    - Spawning unit darat awal (Infanteri di Batavia, Tank MBT di Jatim, dan Infanteri Rival di Borneo).
    - Seleksi unit via Klik Kiri.
    - Perintah gerak via Klik Kanan ke provinsi target terhubung via graf.
    - Batal seleksi via Klik Kiri/Kanan pada ruang kosong.
  - Panel Inspeksi Unit `UnitPanel` (`src/ui/unit_panel.gd` & `src/ui/unit_panel.tscn`):
    - Menampilkan nama divisi, bendera faksi, status operasional real-time (misal: `▶ Bergerak ke Jawa Timur (45%)` atau `⏸ Siaga`), bar kekuatan (*Strength*) & moral (*Organization*), serta rincian statistik tempur (*Soft Attack*, *Hard Attack*, *Defense*, *Speed*).
  - Integrasi penuh ke dalam `src/main.tscn`.
- [x] **Langkah 7: Sistem Matra Laut, Udara & Pertempuran** *(SELESAI - 19 Okt 2026)*
  - Pembuatan preset resource matra laut dan udara:
    - `src/data/units/frigate_fleet.tres` (Armada Fregat - Domain: SEA, Naval Attack 25, Anti-Air 16, patroli laut lepas).
    - `src/data/units/fighter_wing.tres` (Skuadron Jet Tempur F-16 - Domain: AIR, Air Superiority 30, Soft Attack 18, mobilitas tinggi).
  - Implementasi Aturan Domain Matra di `MilitaryUnit` (`src/military/unit.gd`):
    - **Matra Darat (`Domain.LAND`)**: Hanya dapat melintasi provinsi daratan, dilarang masuk zona perairan laut tanpa kapal angkut.
    - **Matra Laut (`Domain.SEA`)**: Hanya dapat beroperasi di zona perairan laut (`is_sea_zone()`) dan pangkalan pesisir pantai.
    - **Matra Udara (`Domain.AIR`)**: Bebas terbang melintasi darat maupun laut untuk patroli dan intersepsi.
    - Ikon matra spesifik dinamis pada badge: 🚢 (Laut), ✈️ (Udara), 🪖 (Infanteri), 🚜 (Tank/Armor).
  - Implementasi Sistem Tempur `CombatSystem` (`src/military/combat_system.gd`):
    - Deteksi otomatis kontak musuh: Pertempuran pecah saat unit penyerang tiba di wilayah yang dijaga pasukan musuh.
    - Marker visual tempur dinamis ⚔️ di atas provinsi yang sedang bergolak.
    - Resolusi pertempuran real-time per jam (*Hourly Tick*): Menghitung *Soft Attack* & *Hard Attack* vs *Defense*.
    - Pengurangan Moral (*Organization*) dan Kekuatan Personel (*Strength*).
    - Mekanisme mundur (*Retreat*): Saat moral habis, divisi secara cerdas mundur ke wilayah sekutu/aman terdekat.
    - Penentuan pemenang otomatis: Wilayah jatuh ke tangan penyerang jika seluruh garnisun musuh berhasil dipukul mundur.
  - Pembaruan `UnitPanel` (`src/ui/unit_panel.gd`):
    - Status visual tempur dinamis (`⚔️ TERLIBAT PERTEMPURAN SENJATA!`).
    - Bar kesehatan dan moral terupdate secara live di setiap putaran tembak.

---

## 6. Log Eksekusi & Riwayat Perubahan
* **19 Oktober 2026**:
  * Dokumen Game Design & Arsitektur Teknis (`docs/GAME_DESIGN_DOCUMENT.md`) berhasil disusun.
  * Eksekusi **Langkah 1** selesai:
    * Folder `assets/sprites/units/` (army, navy, air) & `assets/sprites/map`, `ui`, `fonts` telah disiapkan.
    * Autoload `EventBus` terdaftar di konfigurasi Godot engine (`project.godot`).
    * Class model inti `Country`, `UnitData`, `BuildingData`, dan `Province` telah dibuat.
  * Eksekusi **Langkah 2** selesai:
    * Autoload `TimeManager` (`src/autoload/time_manager.gd`) selesai dibuat dan didaftarkan ke `project.godot`.
    * Sistem tick jam, hari, bulan, dan tahun dengan kalkulasi tahun kabisat (*leap year*).
    * Integrasi shortcut keyboard (`Space`, `1`, `2`, `3`, `5`).
    * Scene UI `time_controls.tscn` beserta skrip `time_controls.gd` untuk tampilan waktu dan tombol kecepatan.
  * Eksekusi **Langkah 3** selesai:
    * Skrip `src/map/rts_camera_2d.gd` dan scene `src/map/rts_camera_2d.tscn` berhasil diimplementasikan.
    * Fitur pan responsif via WASD dan drag mouse tengah.
    * Zoom presisi mengarah ke kursor mouse dengan batas min/max zoom dan batas peta (*clamping*).
  * **Perbaikan Bug Autoload & Integrasi Scene Utama**:
    * Memperbaiki error `Identifier not found: EventBus` di `time_manager.gd` dengan memisahkan sinyal waktu langsung ke `TimeManager` sebagai *single source of truth*.
    * Membuat scene integrasi `src/main.tscn` dan mendaftarkannya sebagai `main_scene` di `project.godot`.
  * Eksekusi **Langkah 4** selesai:
    * Membuat Resource Faksi: `player_country.tres`, `rival_country.tres`, dan `neutral_country.tres`.
    * Mengembangkan `province.gd` & `province.tscn` dengan sistem poligon dinamis, hover highlight, dan border outline.
    * Mengembangkan `map_manager.gd` & `world_map.tscn` dengan 7 wilayah terhubung jalur graf rute darat & laut.
    * Mengembangkan `province_panel.gd` & `province_panel.tscn` untuk inspeksi ekonomi dan kepemilikan wilayah saat diklik.
    * Mengintegrasikan `WorldMap` dan `ProvincePanel` ke `main.tscn`.
    * Memperbaiki path hierarki node `@onready` di `province_panel.gd` dan memvalidasi scene berhasil berjalan 100% tanpa error via Godot Engine CLI.
  * Eksekusi **Langkah 5** selesai:
    * Mengembangkan `economy_manager.gd` untuk mengkalkulasi agregat output harian dari provinsi milik pemain.
    * Mengembangkan `top_bar.gd` dan `top_bar.tscn` sebagai bilah komando atas yang menampilkan saldo kas, baja, minyak, manpower, dan kontrol waktu.
    * Mengintegrasikan `EconomyManager` dan `TopBar` ke dalam `main.tscn`.
    * Memperbarui resolusi node `TimeManager` via `get_node_or_null("/root/TimeManager")` di seluruh script antarmuka agar kebal terhadap *cache delay* pada Language Server editor.
    * Berhasil divalidasi via Godot Engine CLI tanpa ada error.
  * Eksekusi **Langkah 6** selesai:
    * Membuat preset resource unit: `infantry_division.tres` dan `tank_division.tres`.
    * Mengembangkan `unit.gd` & `unit.tscn` dengan visual badge NATO, bar moral & progress gerak, serta pergerakan per jam *hourly tick*.
    * Mengembangkan `military_manager.gd` & `military_manager.tscn` untuk seleksi unit dan perintah gerak klik kanan.
    * Mengembangkan `unit_panel.gd` & `unit_panel.tscn` untuk status pergerakan dan statistik tempur unit terpilih.
    * Mengintegrasikan mekanisme perebutan wilayah (*capture territory*) secara otomatis saat unit tiba di target.
    * Berhasil divalidasi via Godot Engine CLI tanpa ada error.
  * Eksekusi **Langkah 7** selesai:
    * Membuat preset unit laut `frigate_fleet.tres` dan udara `fighter_wing.tres`.
    * Mengimplementasikan aturan domain matra (darat vs laut vs udara) pada navigasi dan pergerakan unit.
    * Mengembangkan `combat_system.gd` untuk resolusi pertempuran real-time per jam, penyerapan damage, sistem moral pukul mundur (*retreat*), dan marker tempur ⚔️.
    * Mengintegrasikan `CombatSystem` ke `main.tscn`.
    * Berhasil divalidasi via Godot Engine CLI tanpa ada error.
  * **Rilis Tag v0.1**:
    * Pembersihan seluruh error dan warning debugger Godot.
    * Dokumentasi `README.md` dan `RELEASE_NOTES.md` selesai.
    * Commit dan tagging `v0.1` berhasil dipush ke GitHub.

---

## 7. Rencana Pengembangan Versi 0.2: Rantai Industri Militer, AI & Intelijen Tempur
Rencana komprehensif, arsitektur data, dan rincian sprint untuk Versi 0.2 telah didokumentasikan secara detail di dokumen terpisah:
👉 **[ROADMAP_V0.2.md](file:///d:/03%20ProjectGame/true-nation/docs/ROADMAP_V0.2.md)**

### Mengadopsi Model Rantai Pasok Militer (Opsi A: Persenjataan & Amunisi/Rudal):
Menambahkan 2 komoditas manufaktur militer di atas 4 sumber daya primer:
- 🔫 **Persenjataan Militer (*Military Arms/Equipment*)**: Diproduksi oleh Pabrik Senjata dari Baja & Kas. Diperlukan untuk melatih divisi baru.
- 🚀 **Amunisi & Rudal (*Munitions & Missiles*)**: Diproduksi oleh Pabrik Amunisi dari Minyak, Baja & Kas. Dikonsumsi setiap jam pertempuran oleh unit darat, laut, dan udara. Jika stok habis, serangan unit turun drastis (-50% Attack).

### Ringkasan Milestone Versi 0.2:
- [ ] **Langkah 8: Sistem Rekrutmen & Antrian Produksi Militer**
  - Pembuatan modul `ProductionManager` dan struct `ProductionOrder`.
  - Integrasi indikator 🔫 Arms dan 🚀 Munitions di TopBar HUD.
  - Antarmuka rekrutmen pasukan di drawer provinsi (`ProvincePanel`) dengan biaya Kas, Manpower, Persenjataan, dan Bekal Amunisi Awal.
  - Spawning otomatis divisi baru di ibukota/pangkalan saat selesai.
- [ ] **Langkah 9: Sistem Pembangunan Infrastruktur Provinsi & Pabrik Militer**
  - Implementasi fasilitas: Pabrik Senjata (+Senjata/hari), Pabrik Amunisi (+Amunisi/hari), Tambang Baja, Kilang Minyak, Pangkalan Udara, Galangan Kapal, dan Benteng (+Defense).
  - Mekanisme konsumsi amunisi per jam di `combat_system.gd` dan status penalti krisis amunisi.
  - Sistem batas slot bangunan per provinsi.
- [ ] **Langkah 10: Sistem Kecerdasan Buatan Lawan (Enemy AI)**
  - Modul `AIManager` pengendali faksi rival (*Krasnovian Federation*).
  - Siklus FSM: Evaluasi stok amunisi & rasio kekuatan, patroli perbatasan, aneksasi provinsi netral, counter-attack, dan rekrutmen mandiri.
- [ ] **Langkah 11: Sistem Kabut Perang (Fog of War) & Pengintaian**
  - Status visibilitas provinsi (`VISIBLE`, `FOGGED`, `UNKNOWN`).
  - Radius pandang sensor jet tempur patroli udara dan pangkalan radar.
- [ ] **Langkah 12: Integrasi Visual Sprite Pixel Art & Efek Tempur**
  - Pemotongan dan integrasi sprite sheet pixel art kendaraan modern (Tank, Jet, Kapal Perang, Infanteri).
  - Garis lintasan gerak beranimasi (*marching path lines*) dan partikel tembakan pada marker ⚔️.
