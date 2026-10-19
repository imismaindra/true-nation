# Release Notes - True Nation v0.3.2

**Release Date:** 20 Oktober 2026  
**Version:** `v0.3.2`  
**Milestone:** Complete Professional UI & Layout Redesign, Procedural 2D Tactical Ocean Shader, Coastal Shelf Halos, & Theater Navigation Bar  
**Compatibility:** Godot Engine 4.3 - 4.7.2+ (Forward+ & Compatibility)

---

## 🌟 Ringkasan Pembaruan Taktis (Professional UI & Ocean Redesign v0.3.2)

Versi **v0.3.2** berfokus penuh pada perombakan estetika samudra (*Ocean Graphics Overhaul*) dan redesain tata letak antarmuka pengguna (*Professional UI & Layout Redesign*), mengubah visual game menjadi standar game grand strategy / simulasi militer modern:

1. **Shader Samudra 2D Prosedural Real-Time (`ocean_water.gdshader`)**:
   - Menghapus sepenuhnya tekstur statis `ocean_texture.png` yang berulang dan bernoda gelap.
   - Mengimplementasikan shader CanvasItem GLSL prosedural dengan harmoni gelombang laut bertingkat (*multi-harmonic ocean swells*) yang mengalir lembut secara dinamis.
   - Dilengkapi model kedalaman batimetri (Paparan Dangkal Sunda/Sahul vs Palung Samudra Hindia & Pasifik), garis kisi kartografis peta laut (*Nautical Chart Lat/Long Grid*) dengan *crosshair* navigasi, serta Garis Khatulistiwa (*Equator*) bergaris putus-putus taktis.

2. **Paparan Dangkal Pesisir Pantai (*Coastal Shelf Halos*)**:
   - Menambahkan lapisan paparan dangkal pesisir (*Coastal Shelf Line2D*) di sekeliling seluruh pulau di [province.tscn](file:///d:/03%20ProjectGame/true-nation/src/map/province.tscn) dan [province.gd](file:///d:/03%20ProjectGame/true-nation/src/map/province.gd).
   - Menghadirkan transisi air dangkal berona *cyan-azure* yang membaurkan daratan dengan samudra secara organik layaknya citra satelit dan peta maritim profesional.

3. **Redesain Total TopBar Komando Militer**:
   - Di [top_bar.tscn](file:///d:/03%20ProjectGame/true-nation/src/ui/top_bar.tscn), TopBar ditransformasikan menjadi pita komando penuh (*Full-Width Command Ribbon*) docked di sisi atas layar dengan material *military glassmorphism* gelap dan border aksen cyan bercahaya.
   - Header Faksi: Nama "REPUBLIK NUSANTARA" dengan lencana bendera logam dan takarir "KOMANDO STRATEGIS | SIAGA 1".
   - Chip Sumber Daya Modular: Setiap indikator logistik (Dana Kas, Baja, Minyak, Tenaga Tempur, Industri Senjata, Amunisi) ditempatkan dalam modul *card panel* individual yang rapi dengan ikon SVG tajam dan indikator laju pertumbuhan.
   - Integrasi Kronometer & Kontrol Kecepatan Waktu NATO (`06:00 | 1 Jan 2026`, tombol Pause, 1x, 2x, 3x, 5x).

4. **Bilah Navigasi Cepat & Mode Teater (`MapModeBar`)**:
   - Menambahkan bilah navigasi taktis di sudut kanan atas layar [map_mode_bar.tscn](file:///d:/03%20ProjectGame/true-nation/src/ui/map_mode_bar.tscn):
     - `[ 🏛️ Batavia ]`: Melompatkan kamera secara instan ke Ibu Kota Batavia di Pulau Jawa.
     - `[ ⛶ Peta Penuh ]`: Mengembalikan tampilan panorama seluruh kepulauan Indonesia (Sabang s/d Merauke).
     - `[ 📡 C4ISR ]`: Sinkronisasi radar dan sensor pemindai kabut perang.

5. **Penyempurnaan Tema Antarmuka & Panel Interaktif**:
   - Di [tactical_theme.tres](file:///d:/03%20ProjectGame/true-nation/assets/ui/tactical_theme.tres), seluruh stylebox panel, tombol, dan progress bar diperbarui dengan nuansa *dark cyber-command*, border 1px berkilau, dan efek interaksi klik yang tegas.
   - Menambahkan ikon SVG pada tombol aksi panel wilayah ([ProvincePanel](file:///d:/03%20ProjectGame/true-nation/src/ui/province_panel.tscn)) dan divisi militer ([UnitPanel](file:///d:/03%20ProjectGame/true-nation/src/ui/unit_panel.tscn)).

---

# Release Notes - True Nation v0.3.1

**Release Date:** 19 Oktober 2026  
**Version:** `v0.3.1`  
**Milestone:** Visual Overhaul, Archipelago Geometry Reshaping, Transparent Sea Zones, Elimination of Black Box Shading, and Complete UI Overlapping Fixes  
**Compatibility:** Godot Engine 4.3 - 4.7.2+ (Forward+ & Compatibility)

---

## 🌟 Ringkasan Pembaruan Taktis (Hotfix & Visual Polish v0.3.1)

Versi **v0.3.1** dirilis secara khusus sebagai evaluasi kritis terhadap kualitas visual dan kenyamanan bermain (*player experience & aesthetic audit*). Versi ini memperbaiki secara radikal kelemahan grafis dan bug tumpang-tindih UI yang sebelumnya membuat game terlihat seperti prototipe mentah:

1. **Eliminasi Total "Black Box Shading" (Fog of War Realistis)**:
   - Menghapus pewarnaan 95% hitam pekat pada provinsi `UNKNOWN` di [province.gd](file:///d:/03%20ProjectGame/true-nation/src/map/province.gd).
   - Menggantikannya dengan sistem *C4ISR Tactical Radar Shading*: daratan kepulauan, garis pantai, dan perbatasan teritori negara tetap tampak indah dan jelas di atas peta, sementara wilayah tanpa sensor hanya diteduhkan secara taktis.

2. **Transparansi Penuh Zona Maritim (Tekstur Samudra Alami)**:
   - Menghapus poligon balok pekat pada 8 zona laut ALKI.
   - Zona maritim kini 100% tembus pandang dengan batas taktis tipis dan tipografi nautikal elegan, membiarkan tekstur batimetri samudra (`ocean_texture.png`) mengalir bebas dan megah di seluruh laut Indonesia.

3. **Rekonstruksi Poligon Geografis Nusantara yang Organik & Nyata**:
   - Mendesain ulang seluruh koordinat poligon 37 provinsi di [world_map.tscn](file:///d:/03%20ProjectGame/true-nation/src/map/world_map.tscn) menggantikan balok-balok kaku sebelumnya:
     - **Sumatera**: Bentuk pulau diagonal anggun dari puncak Sabang/Aceh hingga Teluk Lampung.
     - **Jawa**: Kepulauan Jawa yang ramping dan berlekuk alami (Banten, Teluk Batavia, Dataran Priangan, Pantai Utara Jawa Tengah, Yogyakarta, hingga semenanjung Banyuwangi).
     - **Sulawesi**: Siluet ikonik huruf "K" dengan 4 semenanjung terpisah (Sulsel, Sultra, Sulteng, Sulut).
     - **Kalimantan**: Bentuk segitiga membulat pulau Borneo yang khas dan proporsional.
     - **Papua**: Siluet "Kepala Burung" (Papua Barat) dan bentang daratan luas Jayapura - Merauke.
     - **Bali & Nusa Tenggara**: Busur kepulauan selatan yang presisi.

4. **Pembersihan Jaring Laba-laba Garis Koneksi**:
   - Menonaktifkan garis `Line2D` statis darat secara bawaan (`show_connection_lines = false`). Peta bersih dari kekacauan wireframe, sementara pergerakan unit tetap dipandu oleh garis mars beranimasi (*marching line*).

5. **Eliminasi Tumpang Tindih UI Total**:
   - `ProvincePanel`, `UnitPanel`, `RecruitmentDialog`, dan `ConstructionDialog` kini tersimpan dengan `visible = false` secara bawaan di scene `.tscn` dan `main.tscn`. Layar game saat dibuka bersih tanpa tumpukan jendela kosong.
   - Menambahkan penutupan instan dengan tombol `ESC` pada seluruh panel dan dialog modal.
   - Menjamin sifat eksklusif: membuka dialog rekrutmen otomatis menutup dialog pembangunan fasilitas, mencegah saling menimpa di tengah layar.

6. **TopBar & Resolusi Standar Layar (1280x720)**:
   - Resolusi layar diset ke 1280x720 di `project.godot`.
   - Padding dan lebar minimum label faksi diperbaiki sehingga nama "Republik Nusantara" tidak terpotong di tepi kiri.

7. **Kamera Awal Taktis**:
   - RTS Camera dimulai pada posisi sentral Jawa & perairan sekitarnya dengan `zoom = 0.65`, menyajikan pemandangan pulau-pulau inti yang siap dikendalikan.

---

# Release Notes - True Nation v0.3

**Release Date:** 19 Oktober 2026  
**Version:** `v0.3`  
**Milestone:** Nusantara Archipelago Theater, Tactical Ocean Texture, Unit Polish & Anti-Clumping, C4ISR Vector Design & Complete Anti-Slop UI Elimination  
**Compatibility:** Godot Engine 4.3 - 4.7.2+ (Forward+ & Compatibility)

---

## 🌟 Ringkasan Rilis (Release Overview v0.3)

Versi **v0.3** menandai revolusi visual dan geopolitik terbesar bagi *True Nation*. Seluruh prototipe visual awal ditransformasikan menjadi ruang komando militer profesional berkelas internasional (**C4ISR Modern War Room**), mencakup seluruh kepulauan Indonesia dari Sabang sampai Merauke:

1. **Eliminasi Total 100% "AI Slop" & Sistem Vektor SVG Kustom**:
   - Seluruh karakter literal emoji teks (`🪙`, `⚙️`, `🛢️`, `👥`, `🔫`, `🚀`, `💾`, `📂`, `🎖️`, `🎯`, `⚔️`, `🪖`) telah dihapus secara permanen dari UI, skrip, dan scene.
   - Digantikan oleh 25+ file ikon SVG vektor resolusi tinggi (`assets/sprites/ui/`) untuk komoditas ekonomi, fasilitas teritorial, tombol kontrol waktu, berkas operasi simpan/muat, dan lambang taktis NATO.
   - Pemasangan tema global **C4ISR Tactical Dark Theme** (`assets/ui/tactical_theme.tres`) dengan palet warna Deep Navy Slate, garis tepi baja presisi, dan aksen Cyber Cyan & Emerald Tactical.

2. **Teater Kepulauan Nusantara (37 Provinsi Strategis)**:
   - Pemugaran peta dari 7 poligon mainan menjadi **37 wilayah geopolitik komprehensif**:
     - 6 Provinsi Sumatera (Aceh, Sumut, Riau, Sumbar, Sumsel, Lampung)
     - 6 Provinsi Jawa (Banten, Batavia, Jabar, Jateng, Jogja, Jatim)
     - 3 Provinsi Bali & Nusa Tenggara (Bali, NTB, NTT)
     - 5 Provinsi Kalimantan (Kalbar, Kalteng, Kalsel, Kaltim, Kaltara)
     - 4 Provinsi Sulawesi (Sulsel, Sulteng, Sultra, Sulut)
     - 5 Wilayah Maluku & Papua (Malut, Maluku, Papua Barat, Papua, Papua Selatan)
     - 8 Titik Cekik Maritim & Selat Strategis ALKI (Selat Malaka, Laut Natuna, Selat Sunda, Selat Karimata, Laut Jawa, Selat Makassar, Laut Flores, Laut Banda).

3. **Tekstur Samudra Taktis (*Seamless Bathymetric Ocean Texture*)**:
   - Latar belakang laut tidak lagi biru polos datar, melainkan menggunakan tekstur batimetri maritim berulang (`assets/sprites/map/ocean_texture.png`) yang menggambarkan kedalaman laut dangkal (*continental shelf*) dan palung samudra dalam.

4. **Kalkulasi Sentroid Daratan Visual Presisi**:
   - Algoritma Green's Theorem terpadu dengan fallback pole-of-inaccessibility (`_calculate_visual_centroid()`) pada [province.gd](file:///d:/03%20ProjectGame/true-nation/src/map/province.gd), memastikan penempatan nama provinsi, lencana fasilitas, dan garnisun militer selalu berada kokoh di atas daratan kering tanpa meleset ke laut.

5. **Polish Unit Perang & Formasi Anti-Clumping**:
   - Simbol taktis modern (*Tactical NATO Icons*) pada badge unit.
   - **Formasi Sebar Otomatis**: Saat lebih dari 1 divisi berada di provinsi yang sama, unit secara cerdas mengatur formasi offset taktis (linear berjarak, segitiga, atau formasi 2x2) sehingga tidak lagi saling menumpuk.
   - Border seleksi sudut taktis (*Cyber Cyan corner brackets*).
   - Efek visual peringatan mundur taktis (*Retreat Alert Flash*) ketika organisasi divisi jatuh di bawah 15%.
   - Tombol perintah langsung **Batal Gerak (Halt)** dan **Mundur Taktis (Retreat)** pada panel unit.

6. **Refaktor UI/UX Dossier & Military SITREP Ticker**:
   - TopBar responsif dengan indikator SVG, delta harian, dan tooltip neraca ekonomi terintegrasi.
   - Dossier Provinsi & Unit dengan layout militer terstruktur, bar status presisi, dan tombol aksi standar.
   - Ticker notifikasi intelijen tempur (`NotificationBanner`) dengan garis aksen status berwarna dinamis.

7. **Verifikasi Penuh Engine Godot 4.7.2**:
   - Diuji langsung pada console headless Godot 4.7.2: 0 parse error, 0 compile warnings, simulasi multi-frame berjalan stabil pada 60 FPS.

---

# Release Notes - True Nation v0.2.1

**Release Date:** 19 Oktober 2026  
**Version:** `v0.2.1`  
**Milestone:** Polish, Tactical Unit Roster, AI Autonomous Construction, Audio, Save/Load & Quality of Life (QoL)  
**Compatibility:** Godot Engine 4.3 - 4.7.2+ (Forward+ & Compatibility)

---

## 🌟 Ringkasan Rilis (Release Overview v0.2.1)

Versi **v0.2.1** hadir sebagai pematangan menyeluruh (*polish, tactical expansion, & stability hardening*) sebelum melangkah ke Peta Raksasa Kepulauan Nusantara di Versi 0.3. Pembaruan ini mengimplementasikan penuh seluruh **6 Sprint Master Roadmap v0.2.1** serta penyempurnaan parser GDScript 4 untuk Godot 4.7.2:

1. **Orientasi & Rotasi Halus Pasukan (Unit Facing Direction)**: Rotasi dinamis haluan jet tempur, helikopter, dan kapal perang, serta pembalikan moncong tank dan infanteri secara presisi mengikuti arah vektor gerak.
2. **Ekspansi Roster Militer Modern (4 Divisi Baru)**: Penambahan Artileri Medan / MLRS, Helikopter Serbu, Drone Pengintai UAV, dan Kapal Selam Tempur memanfaatkan lembar 28 sprite militer modern dengan mekanik khusus (reduksi benteng, radar 2-hop, dan kamuflase bawah air).
3. **Kecerdasan Buatan (AI) Konstruksi Fasilitas**: AI rival mampu mendeteksi krisis logistik dan secara mandiri membangun Pabrik Amunisi, Benteng Perbatasan (+35% Defense), Pangkalan Udara, dan Galangan Kapal.
4. **Tooltip Neraca Ekonomi & Seleksi Korps Gabungan (Multi-Select)**: Visibilitas rinci pendapatan vs pengeluaran komoditas pada TopBar HUD dan tombol gerak serentak seluruh garnisun provinsi.
5. **Sistem Tata Suara Atmosfer Tempur (Audio Manager Prosedural)**: Modul audio singleton 16-bit mandiri tanpa dependensi file eksternal (*radio chirp, tactical click, movement order tone, cannon blast, automatic rifle burst, war alert siren*).
6. **Sistem Simpan & Muat Permainan (Save & Load Manager)**: Persistensi data lengkap berbasis JSON (`user://savegame.json`) dengan tombol UI dan shortcut F5 (Save) / F9 (Load).

---

## 🚀 Rincian Fitur Baru & Peningkatan (Changelog Versi 0.2.1)

### 1. Orientasi & Arah Hadap Pasukan Dinamis (Sprint 1)
- **Matra Udara (Jet & Helikopter)**: Haluan pesawat berputar mulus (`lerp_angle`) mengikuti sudut vektor lintasan terbang menuju target.
- **Matra Laut (Kapal Perang & Kapal Selam)**: Haluan badan kapal berputar otomatis searah garis pelayaran laut.
- **Matra Darat (Tank & Infanteri)**: Deteksi otomatis arah pergerakan barat vs timur dengan pembalikan horizontal (`flip_h`) dan kemiringan moncong saat mendaki atau bermanuver.

### 2. Ekspansi Roster Militer Modern (Sprint 2)
Penambahan 4 tipe unit strategis baru di `src/data/units/` dan terintegrasi pada dialog rekrutmen:
- 💥 **Artileri Medan & MLRS (`artillery_division.tres`)**:
  - Soft Attack tinggi (24.0) untuk menghancurkan konsentrasi infanteri.
  - Mekanik khusus pengepungan: Mereduksi efektivitas benteng pertahanan lawan (*fortification siege reduction*).
- 🚁 **Helikopter Serbu (`attack_helicopter_wing.tres`)**:
  - Hard Attack tinggi (22.0) sebagai pemburu armada kendaraan lapis baja.
  - Fleksibilitas pergerakan lintas matra (darat & selat sempit) dengan kecepatan jelajah 110 km/jam.
- 📡 **Drone Pengintai UAV (`recon_drone_wing.tres`)**:
  - Biaya rekrutmen dan konsumsi logistik sangat murah.
  - Sensor radar canggih: Membuka kabut perang (*Fog of War*) hingga 2 hop provinsi di sekitarnya.
- 🌊 **Kapal Selam Tempur (`submarine_fleet.tres`)**:
  - Armada siluman matra laut yang tersembunyi dari radar kapal permukaan di luar zona pertempuran langsung.

### 3. Kemandirian Konstruksi AI Rival (Sprint 3)
- Modul [AIManager](file:///d:/03%20ProjectGame/true-nation/src/ai/ai_manager.gd) kini memiliki nalar industrial:
  - **Manajemen Krisis Amunisi**: Jika stok amunisi < 100, AI segera mengalokasikan kas dan baja untuk mendirikan Pabrik Amunisi.
  - **Benteng Perbatasan**: Provinsi AI yang berbatasan langsung dengan teritori pemain secara otomatis dibentengi (+35% bonus pertahanan).
  - **Infrastruktur Militer**: Otomatis mendirikan Pangkalan Udara dan Galangan Kapal di wilayah pesisir untuk membuka rekrutmen armada laut dan udara.

### 4. Transparansi Ekonomi & Kendali Pasukan Gabungan (Sprint 4)
- **Hover Tooltips TopBar HUD**:
  - Mengarahkan kursor ke Uang, Baja, Minyak, Manpower, Senjata, atau Amunisi menampilkan jendela rincian pendapatan harian, input pabrik, pemeliharaan divisi, dan saldo surplus/defisit bersih.
- **Multi-Unit Selection & Group Move**:
  - Penambahan tombol **"🎯 Pilih Semua Pasukan di Sini"** pada panel provinsi.
  - Seluruh divisi yang dipilih dapat diperintahkan serentak dengan satu klik kanan menuju provinsi tujuan.

### 5. Sintesis Audio Prosedural 16-Bit (Sprint 5)
- Singleton [AudioManager](file:///d:/03%20ProjectGame/true-nation/src/audio/audio_manager.gd) terpasang di `project.godot`:
  - Menggunakan pembangkit gelombang audio sintetis (*sine, square, frequency sweep, white noise filter*) untuk menghasilkan sampel `AudioStreamWAV` berkualitas tinggi secara runtime tanpa bloat aset file audio eksternal.
  - Efek suara taktis: Klik UI, penerimaan order komando gerak, dentuman artileri/meriam tank, rentetan senapan mesin, dan sirine darurat saat wilayah diserang.

### 6. Persistensi Penuh Save & Load JSON (Sprint 6)
- Singleton [SaveManager](file:///d:/03%20ProjectGame/true-nation/src/save/save_manager.gd) terpasang di `project.godot`:
  - Menyimpan status komprehensif ke `user://savegame.json` meliputi: waktu permainan (jam, hari, bulan, tahun, status pause/speed), komoditas & pendapatan kedua negara, kepemilikan provinsi & seluruh fasilitas aktif, serta daftar unit militer (posisi, HP, moral, dan progres rute gerak).
  - Tombol aksi cepat **"💾 Simpan"** dan **"📂 Muat"** di TopBar HUD serta shortcut instan keyboard **F5 (Quick Save)** dan **F9 (Quick Load)**.

### 7. Penguatan Parser Engine & Stabilitas Kode (Bug Fixes)
- Menghilangkan fungsi duplikat `has_building` pada [province.gd](file:///d:/03%20ProjectGame/true-nation/src/map/province.gd) yang sebelumnya memicu parse error `Province`.
- Menghilangkan variabel redeclaration di scope fungsi yang sama pada [unit.gd](file:///d:/03%20ProjectGame/true-nation/src/military/unit.gd), [combat_system.gd](file:///d:/03%20ProjectGame/true-nation/src/military/combat_system.gd), [ai_manager.gd](file:///d:/03%20ProjectGame/true-nation/src/ai/ai_manager.gd), dan [save_manager.gd](file:///d:/03%20ProjectGame/true-nation/src/save/save_manager.gd).
- Menambahkan implementasi helper `_format_number` pada [top_bar.gd](file:///d:/03%20ProjectGame/true-nation/src/ui/top_bar.gd).
- Diverifikasi langsung pada console engine **Godot 4.7.2-stable**: 0 parse errors, 0 runtime crashes.

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
