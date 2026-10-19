# 🗺️ Master Roadmap - True Nation Versi 0.2.1

**Milestone:** Polish, Tactical Unit Roster, AI Construction & Quality of Life (QoL)  
**Target Rilis:** Versi 0.2.1  
**Status Dokumen:** Rencana Strategis Siap Eksekusi  
**Prasyarat:** Versi 0.2 (`v0.2`) Telah Dirilis Penuh  

---

## 🎯 Visi & Tujuan Versi 0.2.1

Versi **v0.2.1** didedikasikan untuk mematangkan mekanika taktis, memperkaya variasi gameplay dengan memanfaatkan 28 sprite militer modern yang telah diekstrak, memberikan kepintaran konstruksi pada AI musuh, serta menghadirkan fondasi *Save & Load* dan Audio sebelum melangkah ke ekspansi peta kepulauan Nusantara raksasa di **Versi 0.3**.

---

## 📅 Rencana Tahapan Eksekusi (Sprint Breakdown v0.2.1)

### 🔹 Sprint 1: Orientasi & Rotasi Halus Arah Hadap Pasukan (Unit Facing Direction)
- **Tujuan**: Menghilangkan kekakuan visual di mana sprite unit selalu menghadap arah statis.
- **Implementasi**:
  - Matra Udara (Jet Tempur, Pembom, Helikopter): Rotasi haluan mengikuti vektor gerak `lerp_angle(rotation, target_angle, delta * 12.0)`.
  - Matra Laut (Kapal Perang, Fregat, Kapal Selam): Rotasi badan kapal searah garis pelayaran laut.
  - Matra Darat (Tank, Infanteri): Pembalikan arah horizontal (`flip_h`) atau penyesuaian sudut moncong tank saat melaju ke barat vs timur.

### 🔹 Sprint 2: Ekspansi Roster Rekrutmen Pasukan (Memanfaatkan 28 Sprite Unit)
- **Tujuan**: Membuka variasi divisi baru pada [RecruitmentDialog](file:///d:/03%20ProjectGame/true-nation/src/ui/recruitment_dialog.tscn) dan `src/data/units/`.
- **Unit Tambahan**:
  1. 💥 **Artileri Medan / MLRS (Artillery Division)**: Serangan *soft attack* tinggi dan reduksi pertahanan benteng lawan.
  2. 🚁 **Helikopter Serbu (Attack Helicopter Wing)**: Kecepatan tinggi, anti-tank (*hard attack* tinggi), fleksibilitas lintas darat dan selat laut tanpa butuh galangan kapal.
  3. 📡 **Drone Pengintai (UAV Drone Recon)**: Biaya produksi murah, konsumsi bahan bakar/amunisi sangat rendah, jangkauan sensor pengintai kabut perang (*Fog of War*) sangat luas.
  4. 🌊 **Kapal Selam Tempur (Submarine Fleet)**: Siluman bawah air dengan kemampuan infiltrasi jalur laut musuh.

### 🔹 Sprint 3: Kecerdasan Buatan (AI) Konstruksi Fasilitas Mandiri
- **Tujuan**: Faksi AI rival tidak hanya mampu melatih pasukan dan menyerang, tetapi juga mengelola industri dan pertahanan wilayahnya.
- **Implementasi pada [AIManager](file:///d:/03%20ProjectGame/true-nation/src/ai/ai_manager.gd)**:
  - Cek Stok Amunisi AI: Jika stok amunisi < 100 dan kapasitas pabrik belum maksimal, picu `BuildingManager.start_construction()` untuk **Pabrik Amunisi**.
  - Cek Ancaman Perbatasan: Jika provinsi AI berbatasan langsung dengan provinsi pemain dan hubungan bersitegang/berperang, AI mendirikan **Benteng Perbatasan (*Fortification*)** (+35% defense).
  - Pembangunan Pangkalan: AI mendirikan Airbase atau Naval Dockyard untuk membuka rekrutmen armada laut dan skuadron udara.

### 🔹 Sprint 4: Tooltip Rincian Neraca Ekonomi & Seleksi Korps Gabungan (Multi-Select)
- **Tujuan**: Memberikan visibilitas finansial/logistik yang transparan dan kenyamanan kendali banyak divisi.
- **Implementasi**:
  - **Tooltip Interaktif TopBar**: Saat hover pada Uang, Baja, Minyak, Senjata, atau Amunisi, muncul rincian:
    - *Pendapatan Harian*: Sumber dari wilayah & pabrik aktif.
    - *Pengeluaran Harian*: Upkeep divisi dan konsumsi logistik perang.
    - *Surplus / Defisit Bersih*.
  - **Seleksi Cepat Pasukan**: Tombol "Pilih Semua Pasukan di Provinsi Ini" pada drawer provinsi untuk menggerakkan seluruh garnisun secara serentak ke provinsi target.

### 🔹 Sprint 5: Sistem Audio & Atmosfer Medan Tempur (Sound FX)
- **Tujuan**: Menghadirkan respon taktil audio militer yang imersif.
- **Implementasi**:
  - Modul singleton `AudioManager` (`res://src/audio/audio_manager.gd`).
  - Suara klik taktis UI komando militer (*radio squelch / tactical blip*).
  - Suara dentuman meriam tank dan tembakan senapan saat status tempur aktif (`is_in_combat = true`).
  - Sirine peringatan saat wilayah diserang atau cadangan amunisi habis (*supply outage*).

### 🔹 Sprint 6: Sistem Simpan & Muat Game (Save & Load Manager)
- **Tujuan**: Fondasi persistensi data permainan sebelum melompat ke peta raksasa v0.3.
- **Implementasi**:
  - Modul `SaveManager` (`res://src/save/save_manager.gd`) berbasis format JSON aman (`user://savegame.json`).
  - Menyimpan status:
    - Jam, tanggal, bulan, tahun game (`TimeManager`).
    - Kas negara dan cadangan komoditas (`EconomyManager`).
    - Kepemilikan provinsi & daftar fasilitas aktif (`BuildingManager` & `Province`).
    - Posisi, sisa kekuatan, dan moral seluruh divisi militer (`MilitaryManager`).
  - Tombol UI "Simpan Game" dan "Muat Game" pada menu utama atau bilah jeda.

---

## 🏁 Kriteria Kesiapan Masuk ke Versi 0.3

Setelah seluruh 6 Sprint pada Versi 0.2.1 di atas selesai:
1. Pasukan memiliki manuver arah hadap alami.
2. AI memiliki daya tahan industri mandiri melalui konstruksi pabrik & benteng.
3. Roster pasukan memiliki variasi peran taktis lengkap (darat, artileri, udara, helikopter, drone, kapal selam).
4. Game memiliki sistem audio dan save/load yang kokoh.
5. **Game siap 100% untuk ekspansi Peta Nusantara Realistis (Ratusan Provinsi) di Versi 0.3!**
