# True Nation — Master Roadmap Versi 0.2
> **Fokus Rilis: Dynamic Industry, Recruitment Queue, Strategic AI & Reconnaissance**  
> Target Mesin: Godot Engine 4.7+ (Forward+ / GL Compatibility)  
> Tanggal Perencanaan: 19 Oktober 2026

---

## 🎯 Visi & Sasaran Versi 0.2

Pada rilis fondasi **v0.1**, game telah berhasil menjalankan simulasi waktu berkecepatan dinamis (*Real-Time with Pause*), navigasi peta 2D, topbar ekonomi 4 sumber daya, unit tri-matra (AD, AL, AU), serta sistem pertempuran dan perebutan wilayah otomatis.

Tujuan utama dari **Versi 0.2** adalah mengubah simulasi pasif menjadi **permainan strategi yang aktif dan dinamis (*Active Grand Strategy Loop*)**:
1. **Loop Ekonomi & Militer Tertutup**: Pemain dapat membelanjakan surplus uang, baja, minyak, dan tenaga manusia untuk merekrut pasukan baru dan membangun industri.
2. **Kecerdasan Buatan (Enemy AI)**: Faksi lawan tidak lagi pasif menunggu, melainkan aktif berpatroli, mempertahankan wilayah, merebut provinsi netral, dan melancarkan serangan balasan (*counter-attack*).
3. **Intelijen Tempur (Fog of War)**: Wilayah di luar jangkauan pandang unit atau radar akan tertutup kabut perang.
4. **Peningkatan Visual Sprite**: Mengintegrasikan aset kendaraan pixel art asli dari sprite sheet modern.

---

## 🗺️ Rincian Tahapan Pengembangan (Langkah 8 – Langkah 12)

```
┌────────────────────────────────────────────────────────────────────────┐
│                      ROADMAP VERSI 0.2: TRUE NATION                    │
├─────────────────┬──────────────────┬─────────────────┬─────────────────┤
│   Langkah 8     │    Langkah 9     │   Langkah 10    │   Langkah 11    │
│  Rekrutmen Unit │ Pembangunan Prov │     AI Musuh    │   Fog of War    │
│  & Antrian Prod │ (Pabrik, Pangkalan)│  (Patroli/Serang)│  & Pengintaian  │
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

Saat ini unit militer di-spawn secara statis saat permainan dimulai. Di Langkah 8, pemain dapat melatih dan memproduksi divisi baru secara berkala.

#### 1. Mekanisme & Logika Desain
- **Antrian Produksi (`ProductionQueue`)**:
  - Dikelola oleh kelas baru `ProductionManager` (`src/economy/production_manager.gd`).
  - Menyimpan daftar pesanan produksi aktif (`Array[ProductionOrder]`).
  - Setiap order memiliki:
    - `unit_data: UnitData` (tipe divisi yang diproduksi).
    - `target_province: Province` (titik kumpul / pangkalan perakitan).
    - `days_required: int` (durasi pelatihan/perakitan).
    - `days_elapsed: float` (progres waktu berjalan).
- **Biaya & Waktu Produksi (Tabel Balancing Awal)**:
  | Unit | Uang ($) | Baja (Steel) | Minyak (Fuel) | Manpower | Durasi (Hari) | Syarat Khusus |
  |---|---|---|---|---|---|---|
  | **Divisi Infanteri** | 250 | 15 | 0 | 1,000 | 5 Hari | Provinsi Darat |
  | **Divisi Tank MBT** | 600 | 80 | 45 | 400 | 12 Hari | Provinsi Darat |
  | **Armada Fregat** | 1,200 | 150 | 60 | 600 | 20 Hari | Pesisir / Galangan Kapal |
  | **Skuadron Jet F-16**| 1,500 | 90 | 110 | 250 | 15 Hari | Pangkalan Udara |

#### 2. Antarmuka (UI) Rekrutmen
- Penambahan Tab/Tombol **"Rekrut Pasukan"** pada `ProvincePanel` saat pemain memilih provinsi miliknya.
- Dialog pemilihan unit dengan rincian biaya, durasi, dan tombol "Mulai Produksi".
- Panel kecil di sisi kiri layar menampilkan daftar antrian produksi aktif beserta progress bar persentase.
- Saat produksi mencapai 100%, unit secara otomatis di-instansiasi di koordinat ibu kota provinsi tersebut dan siap digerakkan.

---

### 🏗️ Langkah 9: Sistem Pembangunan Infrastruktur Provinsi

Mengubah provinsi dari penghasil sumber daya statis menjadi basis pembangunan strategis yang dapat dikembangkan.

#### 1. Jenis-Jenis Bangunan (`BuildingData`)
1. **Pabrik Industri Baja (`Steel Factory`)**:
   - Biaya: $500, 30 Baja. Waktu: 10 Hari.
   - Efek: Menambah output baja harian provinsi sebesar `+15 Baja/hari`.
2. **Kilang Minyak (`Oil Refinery`)**:
   - Biaya: $750, 50 Baja. Waktu: 14 Hari.
   - Efek: Menambah pasokan bahan bakar minyak sebesar `+8 Fuel/hari`.
3. **Pangkalan Angkatan Laut (`Naval Dockyard`)**:
   - Biaya: $1,000, 100 Baja. Waktu: 18 Hari.
   - Syarat: Hanya di provinsi bertipe `COASTAL`.
   - Efek: Membuka opsi produksi armada kapal perang dan mempercepat laju reparasi kapal yang bersandar (+2% HP/hari).
4. **Pangkalan Angkatan Udara (`Airbase`)**:
   - Biaya: $800, 60 Baja. Waktu: 12 Hari.
   - Efek: Membuka opsi produksi jet tempur dan meningkatkan kecepatan jelajah udara di atas provinsi tersebut.
5. **Benteng Garis Depan (`Fortification`)**:
   - Biaya: $400, 40 Baja. Waktu: 8 Hari.
   - Efek: Memberikan bonus pertahanan `+35% Defense` bagi seluruh unit pertahanan yang bertempur di provinsi tersebut.

#### 2. Batasan & Integrasi
- Setiap provinsi memiliki maksimal **3 slot pembangunan** (dapat diperluas berdasarkan populasi).
- Bangunan yang sedang dibangun memiliki bar kemajuan harian di tab provinsi.

---

### 🤖 Langkah 10: Sistem Kecerdasan Buatan Lawan (Enemy AI System)

Mengimplementasikan modul `AIManager` (`src/ai/ai_manager.gd`) yang mengontrol negara rival (*Krasnovian Federation*) secara cerdas tanpa intervensi pemain.

#### 1. Finit-State Machine (FSM) AI
Setiap faksi non-pemain akan mengevaluasi strategi setiap `daily_tick` dengan 4 mode perilaku:
1. **Mode Evaluasi (Assessment)**:
   - Menghitung cadangan sumber daya dan total divisi militer yang dimiliki vs ancaman perbatasan pemain.
2. **Mode Ekspansi (Expansion)**:
   - Jika terdapat provinsi netral yang belum dikuasai dan tidak dijaga, AI mengirimkan divisi infanteri/tank terdekat untuk menganeksasi wilayah tersebut.
3. **Mode Bertahan (Defense/Garrison)**:
   - Jika ada pasukan musuh di provinsi perbatasan, AI memposisikan minimal 1 divisi pertahanan di garis depan.
4. **Mode Serangan Balas / Invasi (Offensive/Counter-Attack)**:
   - Jika kekuatan tempur AI lebih besar dari pertahanan wilayah target, AI menggerakkan armada/divisi untuk menyerbu provinsi pemain.
5. **Mode Rekrutmen Otomatis**:
   - Jika memiliki saldo uang dan baja yang cukup serta jumlah unit di bawah kuota minimum, AI otomatis memasukkan pesanan rekrutmen ke antrian.

---

### 🌫️ Langkah 11: Sistem Kabut Perang (Fog of War) & Pengintaian

Menciptakan ketegangan taktis dengan menyembunyikan kekuatan dan pergerakan musuh di wilayah yang tidak terpantau.

#### 1. Mekanisme Visibilitas
- **Status Provinsi**:
  - `VISIBLE` (Terang penuh): Provinsi milik pemain, atau provinsi tempat unit pemain berada. Seluruh pergerakan dan jumlah pasukan musuh terlihat jelas.
  - `FOGGED` (Tertutup kabut remang-remang): Provinsi yang pernah dikunjungi/berbatasan namun tidak ada unit yang mengawasi. Tampilan medan terlihat, namun unit musuh di dalamnya tersembunyi.
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
- Notifikasi banner pop-up elegan saat wilayah berhasil direbut atau saat pertempuran besar pecah.

---

## 📅 Urutan Eksekusi Bertahap (Sprint Breakdown)

```markdown
- [ ] **Sprint 1 (Langkah 8)**: ProductionManager, antrian rekrutmen, dan UI produksi pasukan.
- [ ] **Sprint 2 (Langkah 9)**: Data bangunan, slot infrastruktur provinsi, dan kalkulasi output bonus.
- [ ] **Sprint 3 (Langkah 10)**: AI Controller untuk faksi rival (patroli, ekspansi, & counter-attack).
- [ ] **Sprint 4 (Langkah 11)**: Sistem Fog of War 2D (Shader/Polygon Mask) & jarak pandang recon.
- [ ] **Sprint 5 (Langkah 12)**: Implementasi sprite pixel art kendaraan, animasi gerak, & efek tempur.
- [ ] **Sprint 6 (Release v0.2)**: Balancing sumber daya, pengujian komprehensif, git commit, & tagging v0.2.
```

---

## 🛡️ Standar Kualitas & Arsitektur
- **Bebas Kompilasi Error**: Setiap skrip baru harus divalidasi dengan Godot CLI headless console (`Godot_v4.7.2-stable_win64_console.exe`).
- **Singleton Safety**: Seluruh akses antar-manajer (`TimeManager`, `EventBus`, `EconomyManager`, `MilitaryManager`) harus melalui `get_node_or_null()` guna mencegah kendala cache pada editor GDScript.
- **Data-Driven**: Seluruh biaya unit dan bangunan disimpan dalam Godot Resource (`.tres`) terpisah untuk kemudahan tuning dan modding di masa depan.
