# 🗺️ Master Roadmap — True Nation Versi 0.3
> **Fokus Rilis: Teater Kepulauan Nusantara, Tekstur Samudra Taktis, Polish Unit Perang, Sistem Desain Vektor C4ISR & Eliminasi Penuh AI Slop UI**  
> **Target Mesin:** Godot Engine 4.3 - 4.7+ (Forward+ / GL Compatibility)  
> **Tanggal Perencanaan:** 19 Oktober 2026  
> **Status Dokumen:** 📋 DOKUMEN RESMI (Disetujui untuk Eksekusi)  
> **Prasyarat:** Versi 0.2.1 (`v0.2.1`) Telah Dirilis Penuh  

---

## 🎯 Visi & Sasaran Versi 0.3

Pada Versi 0.2.1, seluruh mekanika taktis (rantai pasok senjata/amunisi, 8 roster unit modern, AI konstruksi mandiri, persistensi JSON Save/Load, dan audio prosedural) telah berfungsi secara stabil dan terverifikasi tanpa error pada engine Godot 4.7.2.

Namun, prototipe visual saat ini masih memiliki tiga kelemahan mendasar:
1. **Peta Wilayah Mainan (Toy Map)**: Masih menggunakan 7 poligon kotak sederhana tanpa tekstur alam nyata.
2. **Unit Perang Masih Sederhana & Menumpuk (*Unit Clumping*)**:
   - Token unit masih memakai emoji teks (`🪖`) di badge atas peta.
   - Pasukan yang berada di provinsi yang sama saling bertumpuk di titik koordinat yang persis sama sehingga sulit diklik dan dilihat.
   - Jalur gerak (*marching line*) dan animasi tempur masih polos tanpa efek taktis modern.
3. **Tampilan "AI Slop" & Bug Layout**:
   - Menggunakan literal emoji teks (`🪙`, `⚙️`, `🛢️`, `👥`, `🔫`, `🚀`, `💾`, `📂`, `⚔️`) pada label dan tombol yang menghasilkan tampilan inkonsisten, rendering kotak kosong (*tofu*), dan kesan prototipe generik tak profesional.
   - Panel abu-abu default Godot tanpa tema visual yang kohesif.
   - Text clipping, margin tidak rapi, dan tombol aksi yang belum terstandarisasi.
   - Latar belakang laut berupa warna flat biru polos tanpa tekstur taktis samudra.

**Sasaran Versi 0.3** adalah mentransformasi *True Nation* menjadi sebuah game grand strategy berkelas militer profesional (*C4ISR Modern War Room*) dengan teater kepulauan Nusantara yang megah, tekstur samudra yang hidup, serta visual unit perang yang taktis dan rapi.

---

## 🏗️ Struktur Tahapan Pengembangan (6 Sprint)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          ROADMAP MASTER VERSI 0.3                               │
├──────────────────────────────────────┬──────────────────────────────────────────┤
│ SPRINT 1: Tactical Vector Design     │ • Buat icon SVG militer resolusi tinggi  │
│           & Icon System (Anti-Slop)  │ • Hapus 100% emoji string di UI          │
│                                      │ • Bangun Godot Tactical Dark Theme       │
├──────────────────────────────────────┼──────────────────────────────────────────┤
│ SPRINT 2: UI/UX Refactor & Bug Fixes │ • TopBar responsif anti-clipping         │
│           (Dossier, Popups, Ticker)  │ • Redesain Dossier Provinsi & Unit       │
│                                      │ • Standarisasi Dialog Rekrut & Bangun    │
│                                      │ • Ticker notifikasi militer elegan       │
├──────────────────────────────────────┼──────────────────────────────────────────┤
│ SPRINT 3: Polish Unit Perang         │ • Token militer taktis (NATO/Tactical)   │
│           & Formasi Anti-Clumping    │ • Formasi sebar otomatis di provinsi     │
│                                      │ • Garis lintasan beranimasi & Waypoint   │
│                                      │ • Efek visual tembakan & mundur taktis   │
├──────────────────────────────────────┼──────────────────────────────────────────┤
│ SPRINT 4: Peta Kepulauan Nusantara   │ • Tekstur samudra seamless & batimetri   │
│           & Tekstur Samudra Taktis   │ • 35+ Provinsi realistis seluruh RI      │
│                                      │ • Selat & Zona Laut Chokepoint strategis │
├──────────────────────────────────────┼──────────────────────────────────────────┤
│ SPRINT 5: Poligon Geografis          │ • Penyesuaian poligon pulau Nusantara    │
│           & Visual Perbatasan Taktis │ • Labeling nama di centroid daratan      │
│                                      │ • Shading teritorial & rute perkapalan   │
├──────────────────────────────────────┼──────────────────────────────────────────┤
│ SPRINT 6: Integrasi Sistem & Neraca  │ • AI Pathfinding maritim antar-pulau     │
│           (AI, Fog of War, Save/Load)│ • Fog of War sensor radar kepulauan      │
│                                      │ • Skalabilitas Save/Load JSON 35+ prov   │
└──────────────────────────────────────┴──────────────────────────────────────────┘
```

---

## 🎨 SPRINT 1: Sistem Desain Vektor Kustom & Eliminasi Penuh AI Slop

### Masalah yang Dihilangkan (Anti-Slop Clean-up)
- **Hapus Seluruh Emoji Teks di Seluruh UI**: Karakter emoji seperti `🪙`, `⚙️`, `🛢️`, `👥`, `🔫`, `🚀`, `💾`, `📂`, `🎖️`, `🎯`, `⚔️` dihapus secara permanen dari kode GDScript dan file `.tscn`.
- **Ganti dengan Vector SVG Murni**: Ditempatkan di `assets/sprites/ui/`:
  - `icon_money.svg`: Lambang kas & perbendaharaan negara (emblem perisai militer emas).
  - `icon_steel.svg`: Balok ingot baja industri & roda gigi mekanik presisi.
  - `icon_fuel.svg`: Tangki bahan bakar minyak & droplet hidrokarbon oranye taktis.
  - `icon_manpower.svg`: Insignia personel prajurit & kekuatan infanteri.
  - `icon_arms.svg`: Siluet senapan serbu tempur modern (persenjataan siap pakai).
  - `icon_munitions.svg`: Siluet amunisi artileri berat & hulu ledak roket.
  - `icon_save.svg`: Simbol media penyimpanan taktis terenkripsi.
  - `icon_load.svg`: Simbol pengambilan arsip dokumen operasi tempur.
  - `icon_pause.svg`, `icon_play.svg`, `icon_fast_forward.svg`: Tombol kontrol waktu geometris tegas.
  - `icon_battle.svg`: Tanda silang bidik (*tactical reticle*) untuk medan pertempuran aktif.
  - `icon_building_factory.svg`, `icon_building_fort.svg`, `icon_building_airbase.svg`, `icon_building_dockyard.svg`: Ikon fasilitas teritorial.

### Sistem Tema Taktis (`tactical_theme.tres`)
- **Palet Warna C4ISR**:
  - Background Utama: Dark Slate Glass (`#0b0f17` dengan alpha 94%).
  - Panel Sekunder / Cards: Deep Navy Slate (`#131a26`).
  - Garis Tepi (Borders): Steel Slate (`#222f44`) dengan aksen tipis 1px.
  - Aksen Taktis: Cyber Cyan (`#38bdf8`) dan Emerald Tactical (`#22c55e`).
  - Peringatan Krisis: Warning Amber (`#f59e0b`) dan Combat Red (`#ef4444`).
- **Standardisasi Layout**:
  - Sudut melengkung halus konsisten (radius 4px - 6px, bukan kapsul pil berlebihan).
  - Padding internal seragam pada container (8px - 14px).
  - Hirarki font yang jelas: Header (15-16px bold), Body Label (12-13px), Monospace Stat (12px tabular figures).

---

## 🖥️ SPRINT 2: Pembenahan Komprehensif UI/UX & Bug Layout

### 1. TopBar HUD Responsif
- Membagi bilah atas menjadi 4 zona fleksibel tanpa kemungkinan text overflow:
  1. **Faksi & Identitas**: Bendera nasional, nama negara, status kedaulatan.
  2. **Indikator Ekonomi**: Kas, Baja, Minyak, Manpower (Ikon SVG + Angka + Delta harian).
  3. **Indikator Militer**: Persenjataan (Arms) & Amunisi (Munitions).
  4. **Pusat Komando Kanan**: Tombol Simpan Taktis, Muat Arsip, Kalender Tanggal, dan Kontrol Kecepatan Waktu.
- Tooltip neraca ekonomi yang terintegrasi dengan StyleBox gelap dan kontras teks tinggi.

### 2. Dossier Provinsi (`ProvincePanel`)
- Panel slide-in modern dari sisi kiri layar:
  - Header: Nama Provinsi, Badge Faksi Penguasa, Ikon Tipe Medan (Urban, Dataran, Pegunungan, Pesisir, Laut).
  - Tab Statistik: Populasi sipil, Pertahanan benteng (+%), Hasil komoditas harian.
  - Fasilitas Terpasang: Kotak slot bangunan dengan ikon SVG fasilitas dan tombol tambah.
  - Komando Garnisun: Tombol "Pilih Semua Pasukan" dan daftar divisi yang sedang bertugas di wilayah tersebut.

### 3. Dossier Unit Militer (`UnitPanel`)
- Kartu inspeksi divisi dengan visual sprite terisolasi dan indikator status:
  - Bar Kekuatan Personel (*Strength*) & Bar Moral/Organisasi (*Organization*).
  - Statistik Serangan Taktis: Soft Attack, Hard Attack, Defense, Kecepatan Jelajah (km/jam), Konsumsi Amunisi/jam.
  - Tombol Komando Operasi: Batal Gerak (*Halt*), Mundur Taktis (*Retreat*).

### 4. Dialog Modal Rekrutmen & Konstruksi
- Modal dialog dengan latar belakang redup (*scrim overlay*):
  - Kartu pilihan unit/bangunan tersusun dalam grid yang rapi dengan indikator syarat (misal: "Memerlukan Pangkalan Udara").
  - Menampilkan estimasi waktu pengerjaan (hari) dan rincian kebutuhan material secara transparan.
  - Tombol penutup (`×`) yang elegan di pojok kanan atas.

### 5. Ticker Notifikasi Militer (`NotificationBanner`)
- Menggantikan pop-up ceria dengan banner situasi intelijen militer (*tactical SITREP ticker*):
  - Beraksen garis indikator warna status operasi di sisi kiri:
    - Biru Taktis: Divisi selesai dilatih / fasilitas rampung.
    - Kuning Waspada: Krisis pasokan amunisi / armada bergerak.
    - Merah Pertempuran: Wilayah diserang musuh / invasi perbatasan.

---

## 🪖 SPRINT 3: Polish Visual & Taktis Unit Perang (Unit Tokens, Anti-Clumping & FX)

### 1. Desain Token Militer Taktis (Tactical Unit Counters)
- **Eliminasi Emoji Token**: Menghapus `text = "🪖"` pada badge unit [unit.tscn](file:///d:/03%20ProjectGame/true-nation/src/military/unit.tscn#L78-L83) dan menggantinya dengan lambang/simbol taktis standar militer berdasarkan matra:
  - Infanteri: Simbol silang taktis infanteri (`X`) / helm baja vektor.
  - Kavaleri / MBT: Siluet sabuk roda rantai / laras tank.
  - Artileri / MLRS: Lambang hulu ledak atau roda meriam artileri.
  - Udara (Jet, Helikopter, UAV): Sayap delta / rotor helikopter.
  - Laut (Fregat, Destroyer, Submarine): Siluet lambung kapal / periskop kapal selam.
- **Badge Status Terpadu**:
  - Bar Organisasi/Moral (cyan) dan Bar Kekuatan/HP (hijau/merah) dibuat lebih ramping dan presisi.
  - Border seleksi unit dibuat lebih elegan dengan penanda sudut taktis (*corner brackets*) menggantikan kotak kuning polos.

### 2. Formasi Sebar Otomatis Anti-Tumpuk (*Anti-Clumping Formation*)
- **Masalah Saat Ini**: Seluruh divisi yang berada di provinsi yang sama diletakkan di titik pusat koordinat yang persis sama, membuat unit saling menumpuk tak terlihat.
- **Solusi**:
  - Implementasi fungsi formasi garnisun pada `MilitaryManager`: saat lebih dari 1 unit berada di provinsi yang sama, posisi visual unit dihitung dengan offset formasi teratur (misal: segitiga taktis untuk 3 unit, formasi 2x2 untuk 4 unit).
  - Saat unit dipilih, unit tersebut terangkat ke foreground (*z_index boost*).

### 3. Polish Pergerakan, Marching Line & Waypoints
- Garis rute lintasan (*MarchingLine*) dipercantik dengan garis putus-putus taktis (*dashed/dotted line*) beranimasi menuju target provinsi.
- Menambahkan penanda titik tujuan (*target arrival reticle*) halus di provinsi target.
- Interpolasi kecepatan akselerasi dan deselerasi gerak yang lebih natural.

### 4. Efek Tempur & Audio Polish
- Sinkronisasi animasi tembakan meriam (*muzzle flash*) dan partikel asap dengan suara dentuman artileri dan tembakan senapan.
- Indikator visual saat moral unit hancur (*tactical retreat alert*) dengan ikon mundur taktis berkedip.

---

## 🌊 SPRINT 4: Peta Kepulauan Nusantara & Tekstur Samudra Taktis

### 1. Tekstur Samudra Taktis (*Seamless Tactical Ocean Texture*)
- **Kebutuhan Pengguna**: Laut tidak boleh berwarna polos datar, melainkan memiliki tekstur taktis samudra.
- **Implementasi Aset**:
  - Dibuat aset tekstur seamless di `assets/sprites/map/ocean_texture.png`:
    - Menampilkan tekstur air bertema peta taktis angkatan laut (*nautical bathymetric chart / tactical depth grid / oceanic contours*).
    - Memadukan gradasi kedalaman laut dangkal (*coastal shelf*) dan laut dalam (*deep trench*).
  - Diaplikasikan menggunakan node `TextureRect` berfitur `texture_repeat = TextureRepeat.ENABLED` atau shader air taktis pada seluruh canvas peta samudra.

### 2. Struktur Wilayah Nusantara (35+ Provinsi Strategis)
Pembagian wilayah kepulauan Indonesia secara geopolitik dan militer:

#### Wilayah Sumatera
1. `prov_aceh`: Banda Aceh & Selat Malaka Utara (Minyak & Pesisir)
2. `prov_sumut`: Medan & Danau Toba (Perkebunan, Populasi & Industri)
3. `prov_riau`: Pekanbaru & Dumai (Lumbung Minyak Bumi Strategis)
4. `prov_sumbar`: Padang & Bukittinggi (Dataran Tinggi & Pesisir Barat)
5. `prov_sumsel`: Palembang (Minyak Bumi, Industri Batubara)
6. `prov_lampung`: Bandar Lampung (Pintu Gerbang Selat Sunda)

#### Wilayah Jawa
7. `prov_banten`: Banten & Cilegon (Industri Baja Berat Krakatau)
8. `prov_batavia`: DKI Jakarta (Pusat Keuangan, Ibu Kota, Populasi Tinggi)
9. `prov_jabar`: Bandung & Priangan (Industri Pertahanan & Manpower)
10. `prov_jateng`: Semarang & Solo (Pertanian, Manpower Tinggi)
11. `prov_jogja`: D.I. Yogyakarta (Pusat Budaya & Pendidikan)
12. `prov_jatim`: Surabaya (Galangan Kapal Angkatan Laut, Baja, Populasi)

#### Wilayah Kalimantan
13. `prov_kalbar`: Pontianak (Batas Darat Serawak, Bauksit)
14. `prov_kalteng`: Palangkaraya (Hutan Tropis, Wilayah Penyangga)
15. `prov_kalsel`: Banjarmasin (Tambang Batubara & Pesisir Selatan)
16. `prov_kaltim`: Balikpapan & Samarinda (Kilang Minyak Terbesar, IKN)
17. `prov_kaltara`: Tarakan (Pangkalan Terdepan Laut Natuna/Sulawesi)

#### Wilayah Sulawesi
18. `prov_sulsel`: Makassar (Pelabuhan Hub Indonesia Timur)
19. `prov_sulteng`: Palu & Morowali (Kawasan Industri Nikel & Baja)
20. `prov_sultra`: Kendari (Tambang Nikel Strategis)
21. `prov_sulut`: Manado & Bitung (Pangkalan Laut Samudra Pasifik)

#### Wilayah Bali & Nusa Tenggara
22. `prov_bali`: Denpasar (Pesisir Pariwisata & Jalur Selat Lombok)
23. `prov_ntb`: Mataram & Sumbawa (Kepulauan Transisi)
24. `prov_ntt`: Kupang & Timor (Perbatasan Terluar Selatan)

#### Wilayah Maluku & Papua
25. `prov_maluku`: Ambon (Kepulauan Rempah & Pangkalan Laut Dalam)
26. `prov_malut`: Ternate & Halmahera (Nikel Kepulauan)
27. `prov_papua_barat`: Sorong & Manokwari (Minyak & Pintu Masuk Papua)
28. `prov_papua`: Jayapura (Ibu Kota Timur & Perbatasan Darat)
29. `prov_papua_selatan`: Merauke (Dataran Luas Perbatasan Selatan)

#### Zona Laut & Selat Strategis (Maritime Chokepoints)
30. `sea_malaka`: Selat Malaka (Jalur Pelayaran Tersibuk Dunia)
31. `sea_natuna`: Laut Natuna Utara (Wilayah Kedaulatan Terdepan)
32. `sea_sunda`: Selat Sunda (Penghubung Jawa & Sumatera)
33. `sea_karimata`: Selat Karimata (Penghubung Sumatera & Kalimantan)
34. `sea_jawa`: Laut Jawa (Zona Perairan Inti Kepulauan)
35. `sea_makassar`: Selat Makassar (Jalur Pelayaran ALKI II)
36. `sea_flores`: Laut Flores (Penghubung Sulawesi & Bali-Nusra)
37. `sea_banda`: Laut Banda (Zona Laut Dalam Maluku)

---

## 📐 SPRINT 5: Poligon Geografis & Visual Peta Taktis

1. **Poligon Realistis**: Membentuk koordinat poligon pulau-pulau besar dan kepulauan Indonesia secara proporsional.
2. **Kalkulasi Sentroid Otomatis**: Setiap provinsi menghitung titik tengah daratan visual (`_calculate_visual_centroid()`) untuk menempatkan:
   - Label nama provinsi.
   - Posisi pendaratan divisi militer (tidak tenggelam di laut).
   - Ikon benteng/pabrik yang sedang aktif.
3. **Penyelarasan Garis Batas & Jalur Koneksi**:
   - Garis batas darat antar-provinsi bertetangga.
   - Garis putus-putus rute penyeberangan selat (*strait ferry links*).
   - Jalur pelayaran laut bebas hambatan antar zona samudra.

---

## ⚙️ SPRINT 6: Integrasi Sistem, AI Maritim & Validasi Skalabilitas

1. **AI Pathfinding Kepulauan (`AIManager`)**:
   - Optimasi algoritma pencarian rute multi-hop melintasi kombinasi darat, selat, dan perairan bebas.
   - AI rival mampu membagi pasukannya untuk menjaga perbatasan darat sekaligus mengamankan pangkalan laut.
2. **Fog of War Berskala Nasional (`FogOfWarManager`)**:
   - Pembagian grid kabut perang efisien untuk 37 zona wilayah.
   - Pengintaian udara oleh jet tempur dan radar drone UAV melintasi selat antar-pulau.
3. **Validasi Persistensi JSON (`SaveManager`)**:
   - Pengujian penyimpanan dan pemulihan status 37 wilayah, lusinan fasilitas, dan banyak divisi unit secara instan.
4. **Verifikasi Mesin Godot Engine 4.7**:
   - Menjalankan uji console `--headless --quit-after 60` untuk memastikan performa tetap 60 FPS, memori bersih tanpa kebocoran, dan 0 parse error.

---

## 🏁 Kriteria Keberhasilan Rilis Versi 0.3

- [ ] **Bebas 100% dari Emoji**: Tidak ada satu pun emoji teks di UI maupun badge unit militer; semua digantikan oleh icon SVG berkualitas tinggi.
- [ ] **Desain C4ISR Profesional**: Theme militer seragam tanpa panel abu-abu polos bawaan Godot.
- [ ] **Unit Perang Taktis & Anti-Clumping**: Token unit militer rapi, formasi sebar saat di provinsi yang sama, marching line putus-putus beranimasi.
- [ ] **Tekstur Samudra Terpasang**: Latar belakang laut memiliki tekstur taktis maritim berulang yang dinamis.
- [ ] **Peta Nusantara 35+ Provinsi Aktif**: Seluruh kepulauan Indonesia dari Sabang sampai Merauke dapat dikendalikan, dipertahankan, dan diinvasi.
- [ ] **Engine Sehat**: Lulus pengujian `--headless` Godot 4.7.2 tanpa warning dan error.
