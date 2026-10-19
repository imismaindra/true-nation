# True Nation — Master Roadmap Versi 0.2
> **Fokus Rilis: Rantai Pasok Militer, Rekrutmen Berbasis Senjata/Amunisi, AI Taktis & Kabut Perang**  
> Target Mesin: Godot Engine 4.7+ (Forward+ / GL Compatibility)  
> Tanggal Perencanaan: 19 Oktober 2026

---

## 🎯 Visi & Sasaran Versi 0.2

Pada rilis fondasi **v0.1**, game telah berhasil menjalankan simulasi waktu berkecepatan dinamis (*Real-Time with Pause*), navigasi peta 2D, topbar ekonomi dasar, unit tri-matra (AD, AL, AU), serta sistem pertempuran dan perebutan wilayah otomatis.

Pada **Versi 0.2**, kita mengadopsi **Model Logistik Makro & Industri Militer (Opsi A: Persenjataan & Amunisi/Rudal)** guna memberikan kedalaman taktik perang modern yang realistis tanpa membebani pemain dengan mikromanajemen berlebihan:
1. **Rantai Pasok Industri Militer (Military Supply Chain)**:
   - Sumber daya mentah (Baja, Minyak, Uang, Manpower) diproses oleh pabrik khusus menjadi barang militer jadi:
     - 🔫 **Persenjataan Militer (*Military Arms/Equipment*)**: Dibutuhkan untuk melatih dan merakit divisi baru.
     - 🚀 **Amunisi & Rudal (*Munitions & Missiles*)**: Dibutuhkan sebagai bekal tempur berkelanjutan saat pasukan bertukar tembakan.
2. **Krisis Logistik Tempur (*Supply Depletion*)**: Pasukan yang bertempur tanpa pasokan amunisi/rudal akan menderita penalti ofensif berat (-50% Attack).
3. **Kecerdasan Buatan (Enemy AI)**: Faksi lawan tidak lagi pasif menunggu, melainkan aktif berpatroli, mempertahankan perbatasan, merebut wilayah netral, dan melancarkan serangan balasan (*counter-attack*).
4. **Intelijen Tempur (Fog of War)**: Wilayah di luar jangkauan sensor dan radar tertutup kabut perang.
5. **Peningkatan Visual Sprite**: Mengintegrasikan aset kendaraan pixel art asli dari sprite sheet modern.

---

## 🗺️ Arsitektur Sumber Daya & Rantai Industri (Versi 0.2)

```
[Sumber Daya Primer] ───► [Pabrik Pengolah] ───────► [Komoditas Militer] ───► [Pemanfaatan]
  💵 Kas Negara        ┌─► 🏭 Pabrik Senjata ──────► 🔫 Persenjataan (Arms) ──► Rekrutmen Divisi Baru
  ⚙️ Logam Baja ───────┤
  🛢️ Minyak Bumi ─────┴─► 🏭 Pabrik Amunisi/Rudal ─► 🚀 Amunisi & Rudal ────► Konsumsi Bertempur (Hourly)
  👥 Manpower ───────────────────────────────────────────────────────────────► Personel Divisi
```

---

## 🗺️ Rincian Tahapan Pengembangan (Langkah 8 – Langkah 12)

```
┌────────────────────────────────────────────────────────────────────────┐
│                      ROADMAP VERSI 0.2: TRUE NATION                    │
├─────────────────┬──────────────────┬─────────────────┬─────────────────┤
│   Langkah 8     │    Langkah 9     │   Langkah 10    │   Langkah 11    │
│  Rekrutmen Unit │ Pembangunan Prov │     AI Musuh    │   Fog of War    │
│  & Antrian Prod │ (Pabrik Senjata, │  (Patroli/Serang│  & Pengintaian  │
│  (Biaya Senjata)│  Kilang, Pangkalan│  & Amunisi AI)  │  (Radar/Sensor) │
└────────┬────────┴────────┬─────────┴────────┬────────┴────────┬────────┘
         │                 │                  │                 │
         └─────────────────┴─────────┬────────┴─────────────────┘
                                     │
                                 Langkah 12
                             Integrasi Pixel Art
                           & Efek Visual Partikel
```

---

### 📦 Langkah 8: Sistem Rekrutmen & Antrian Produksi Militer

Di Langkah 8, pemain melatih divisi baru menggunakan kombinasi tenaga manusia (Manpower), anggaran (Kas), serta komoditas **Persenjataan** dan **Bekal Amunisi Awal**.

#### 1. Mekanisme & Logika Desain
- **Antrian Produksi (`ProductionQueue`)**:
  - Dikelola oleh kelas baru `ProductionManager` (`src/economy/production_manager.gd`).
  - Menyimpan daftar pesanan produksi aktif (`Array[ProductionOrder]`).
  - Setiap order memiliki:
    - `unit_data: UnitData` (tipe divisi yang diproduksi).
    - `target_province: Province` (titik kumpul / pangkalan perakitan).
    - `days_required: int` (durasi pelatihan/perakitan).
    - `days_elapsed: float` (progres waktu berjalan).
- **Tabel Biaya & Durasi Rekrutmen (Model Opsi A)**:
  | Unit Militer | Kas ($) | Baja | Minyak | Manpower | 🔫 Senjata | 🚀 Amunisi Awal | Durasi | Syarat Fasilitas |
  |---|---|---|---|---|---|---|---|---|
  | **Divisi Infanteri** | 250 | 0 | 0 | 1,000 | **120** | **30** | 5 Hari | Provinsi Darat |
  | **Divisi Tank MBT** | 600 | 40 | 35 | 400 | **280** | **80** | 12 Hari | Provinsi Darat |
  | **Armada Fregat** | 1,200 | 100 | 50 | 600 | **350** | **150** | 20 Hari | Pesisir + Pangkalan Laut |
  | **Skuadron Jet F-16**| 1,500 | 60 | 90 | 250 | **400** | **180** | 15 Hari | Pangkalan Udara |

#### 2. Antarmuka (UI) Rekrutmen & TopBar
- **TopBar HUD**: Ditambahkan dua indikator baru:
  - 🔫 **Arms**: Jumlah stok persenjataan siap pakai & delta harian (`+15/hari`).
  - 🚀 **Munitions**: Jumlah cadangan amunisi/rudal nasional & delta harian (`+20/hari`).
- **Drawer Provinsi (`ProvincePanel`)**:
  - Tab "Rekrut Pasukan" yang menampilkan kartu unit, biaya material, syarat pangkalan, dan tombol konfirmasi "Mulai Rekrut".
- **Panel Status Antrian**:
  - Widget bar progres melayang di sisi kiri layar menampilkan divisi yang sedang dilatih (contoh: `[🪖 Infanteri] Jawa Timur - 60%`).
  - Begitu selesai, divisi otomatis ditempatkan di peta pada ibukota provinsi terkait.

---

### 🏗️ Langkah 9: Sistem Pembangunan Infrastruktur Provinsi & Pabrik Militer

Mengembangkan fasilitas strategis untuk memproses bahan mentah menjadi komoditas tempur.

#### 1. Jenis-Jenis Bangunan (`BuildingData`)
1. **Pabrik Senjata Militer (`Arms Factory`)**:
   - Biaya Bangun: $600, 40 Baja. Waktu: 12 Hari.
   - Efek: Mengonsumsi 5 Baja mentah & $30 kas per hari untuk memproduksi **`+20 Persenjataan/hari`**.
2. **Pabrik Amunisi & Rudal (`Munitions Plant`)**:
   - Biaya Bangun: $700, 30 Baja, 25 Minyak. Waktu: 14 Hari.
   - Efek: Mengonsumsi 4 Minyak, 2 Baja & $40 kas per hari untuk memproduksi **`+25 Amunisi/hari`**.
3. **Pabrik Industri Baja Tambang (`Steel Foundry`)**:
   - Biaya Bangun: $500, 20 Baja. Waktu: 10 Hari.
   - Efek: Menambah ekstraksi bijih besi mentah sebesar **`+15 Baja/hari`**.
4. **Kilang Minyak Bumi (`Oil Refinery`)**:
   - Biaya Bangun: $750, 45 Baja. Waktu: 14 Hari.
   - Efek: Menambah output pemurnian minyak sebesar **`+10 Minyak/hari`**.
5. **Pangkalan Angkatan Laut (`Naval Dockyard`)**:
   - Biaya Bangun: $1,000, 100 Baja. Waktu: 18 Hari (Hanya di pesisir `COASTAL`).
   - Efek: Membuka syarat perakitan armada kapal perang & reparasi kapal bersandar (+2% HP/hari).
6. **Pangkalan Angkatan Udara (`Airbase`)**:
   - Biaya Bangun: $800, 60 Baja. Waktu: 12 Hari.
   - Efek: Membuka syarat perakitan jet tempur & mempercepat kecepatan terbang pesawat di zona sekitarnya.
7. **Benteng Perbatasan (`Fortification`)**:
   - Biaya Bangun: $400, 35 Baja. Waktu: 8 Hari.
   - Efek: Memberikan bonus pertahanan **`+35% Defense`** bagi seluruh garnisun di wilayah tersebut.

#### 2. Logika Konsumsi Tempur Real-Time (`Combat Supply`)
- Di `combat_system.gd`: Setiap jam pertempuran (`hourly_tick`), pihak penyerang dan pihak bertahan mengonsumsi amunisi/rudal dari gudang nasional:
  - *Divisi Infanteri*: 1.5 Amunisi / jam tempur.
  - *Divisi Tank*: 4.0 Amunisi / jam tempur.
  - *Armada Kapal*: 6.0 Rudal/Amunisi / jam tempur.
  - *Skuadron Udara*: 8.0 Rudal/Amunisi / jam tempur.
- **Krisis Amunisi (*Supply Outage*)**:
  - Jika cadangan Amunisi nasional menyentuh angka `0`, unit yang bertempur menerima status penalti: **Daya Serang -50%** dan **Moral cepat runtuh**.

---

### 🤖 Langkah 10: Sistem Kecerdasan Buatan Lawan (Enemy AI System)

Mengimplementasikan modul `AIManager` (`src/ai/ai_manager.gd`) yang mengontrol negara rival (*Krasnovian Federation*) secara cerdas tanpa intervensi pemain.

#### 1. Finit-State Machine (FSM) AI
Setiap faksi non-pemain akan mengevaluasi strategi setiap `daily_tick` dengan 5 mode perilaku:
1. **Mode Evaluasi (Assessment)**:
   - Menghitung rasio cadangan amunisi, persenjataan, kas, dan jumlah pasukan vs ancaman pemain di perbatasan.
2. **Mode Ekspansi (Expansion)**:
   - Jika terdapat provinsi netral yang belum dikuasai dan tidak dijaga (*Sumatera Timur*), AI mengirimkan divisi infanteri/tank terdekat untuk menganeksasinya.
3. **Mode Bertahan (Defense/Garrison)**:
   - Menjaga minimal 1 divisi di setiap provinsi yang berbatasan langsung dengan teritori pemain.
4. **Mode Serangan Balas / Invasi (Offensive/Counter-Attack)**:
   - Jika kekuatan tempur dan stok amunisinya mencukupi, AI melancarkan serangan terkoordinasi untuk merebut kembali wilayahnya yang hilang.
5. **Mode Rekrutmen & Produksi Mandiri**:
   - AI membelanjakan persenjataan dan amunisinya untuk melatih divisi baru jika jumlah pasukannya menyusut akibat perang.

---

### 🌫️ Langkah 11: Sistem Kabut Perang (Fog of War) & Pengintaian

Menciptakan ketegangan taktis dengan menyembunyikan kekuatan dan pergerakan musuh di wilayah yang tidak terpantau.

#### 1. Mekanisme Visibilitas
- **Status Provinsi**:
  - `VISIBLE` (Terang penuh): Provinsi sendiri atau diawasi oleh unit kawan (seluruh pergerakan musuh terlihat jelas).
  - `FOGGED` (Tertutup kabut remang-remang): Pernah dikunjungi tetapi tidak ada unit kawan (bentuk medan terlihat, pasukan musuh tersembunyi).
  - `UNKNOWN` (Gelap gulita): Wilayah jauh yang belum pernah diintai.
- **Sensor Pengintaian**:
  - Jet tempur memiliki radius pandang udara yang luas (membuka kabut di 1 hop provinsi tetangga).
  - Pangkalan militer memberikan garis pandang radar perbatasan.

---

### 🎨 Langkah 12: Integrasi Visual Sprite Pixel Art & Efek Tempur

Mengubah tampilan prototipe geometris menjadi sajian visual game perang retro modern yang memukau.

#### 1. Integrasi Sprite Sheet
- Memotong dan mengonfigurasi sprite sheet kendaraan pixel art modern:
  - Kendaraan tempur darat (Infanteri camo, Main Battle Tank, APC/IFV).
  - Armada kapal perang permukaan (Fregat patroli, Destroyer, Kapal Selam).
  - Jet tempur bersayap delta dan helikopter serang.
- Mengganti penanda kotak badge dengan animasi idle sprite unit di atas peta.

#### 2. Efek Partikel & Audio Sederhana
- Efek partikel asap mesiu dan kilatan tembakan meriam (*muzzle flash*) saat marker ⚔️ aktif.
- Garis putus-putus beranimasi (*marching line*) yang menunjukkan arah gerak unit di peta saat dipilih.
- Notifikasi banner pop-up elegan saat wilayah berhasil direbut atau saat amunisi menipis.

---

## 📅 Urutan Eksekusi Bertahap (Sprint Breakdown)

```markdown
- [ ] **Sprint 1 (Langkah 8)**: Tambah metrik Persenjataan & Amunisi di TopBar, modul ProductionManager, antrian rekrutmen, dan UI rekrutmen pasukan di drawer provinsi.
- [ ] **Sprint 2 (Langkah 9)**: Data Pabrik Senjata & Pabrik Amunisi, slot infrastruktur provinsi, serta konsumsi amunisi per jam di CombatSystem.
- [ ] **Sprint 3 (Langkah 10)**: AI Controller untuk faksi rival (evaluasi amunisi, patroli, ekspansi, & counter-attack).
- [ ] **Sprint 4 (Langkah 11)**: Sistem Fog of War 2D (Shader/Polygon Mask) & jarak pandang sensor radar/jet.
- [ ] **Sprint 5 (Langkah 12)**: Implementasi sprite pixel art kendaraan, animasi gerak, & efek partikel pertempuran.
- [ ] **Sprint 6 (Release v0.2)**: Balancing biaya senjata/amunisi, pengujian komprehensif, git commit, & tagging v0.2.
```

---

## 🛡️ Standar Kualitas & Arsitektur
- **Bebas Kompilasi Error**: Setiap skrip baru harus divalidasi dengan Godot CLI headless console (`Godot_v4.7.2-stable_win64_console.exe`).
- **Singleton Safety**: Seluruh akses antar-manajer (`TimeManager`, `EventBus`, `EconomyManager`, `MilitaryManager`, `ProductionManager`) wajib menggunakan `get_node_or_null()`.
- **Data-Driven**: Seluruh biaya unit, persenjataan, amunisi, dan bangunan disimpan dalam Godot Resource (`.tres`) terpisah untuk kemudahan tuning dan modding di masa depan.

---

## 🔭 Visi Versi 0.3: The Great World Map & Global Factions
Sesuai kesepakatan desain, **pembentukan peta dunia skala penuh (*Realistic World Map*) dialokasikan sebagai milestone utama di Versi 0.3**:
- **Tujuan Versi 0.2**: Menyelesaikan dan mematangkan seluruh loop gameplay (Rantai Industri, Rekrutmen Pasukan, Konsumsi Amunisi, Pabrik, dan AI Musuh) di laboratorium 7 provinsi saat ini hingga seimbang dan bebas bug.
- **Fitur Utama Versi 0.3**:
  1. **Peta Skala Besar / Regional Nusantara & Dunia**: Mengonversi garis pantai geografis nyata menjadi puluhan hingga ratusan provinsi dan selat strategis (Selat Malaka, Laut Natuna, Selat Sunda, dsb).
  2. **Metode Peta**: Implementasi Vektor Geografis Riil / Map Color ID ala Paradox untuk manajemen ratusan provinsi secara efisien.
  3. **Faksi Internasional**: Pembagian negara-negara berdaulat dengan aliansi geopolitik, perbatasan historis, dan pangkalan militer dunia nyata.

