## Controller State
Dokumentasi: ControllerState (pengolah input controller)
### 1. Tujuan
Modul ini menyimpan kondisi terkini controller (stick, trigger, tombol) dan menghaluskan nilai stick dan trigger sebelum dipakai. Input mentah dari HP biasanya kasar: bergetar sedikit, berhenti mendadak, atau balik ke tengah dengan patah. Modul ini memperbaikinya lewat empat tahap: deadzone → auto-center → smoothing → response curve.

Kemungkinan pemakaiannya (bagian lain belum saya lihat): handler pesan menulis nilai mentah ke state ini, lalu loop berkala memanggil tick() dan membaca hasilnya.

### 2. Asal code
| Atribut                                             | Fungsi                     |
| --------------------------------------------------- | -------------------------- |
| `HashMap, f32, derive(...), clamp, signum, powf`    | Bawaan Rust (std)          |
| ```tokio::sync::Mutex```                            | Crate tokio (fitur sync)   |
| ```once_cell::unsync::Lazy```                       | Crate once_cell            | 

```toml
toml
[dependencies]
tokio = { version = "1", features = ["sync"] }
once_cell = "1"
```
### 3. Penjelasan per bagian
#### 3.1 ResponseCurve

```rust
pub enum ResponseCurve {
    Linear,
    Exponential(f32),
}
```

Pilihan “kurva sensitivitas” stick. Exponential(f32) membawa angka pangkat.

Kurva	Rumus	Efek (input 0.5)
Linear	v	0.5 (apa adanya)
Exponential(2.0)	v² (tanda dipertahankan)	0.25, gerakan kecil jadi lebih halus untuk membidik
Exponential(0.5)	√v	0.71, lebih sensitif

Clone, Copy membuat enum ini bisa disalin murah (isinya hanya satu f32).

3.2 AxisState
Field	Arti
raw	Nilai mentah terakhir yang diterima
filtered	Nilai hasil pengolahan

new() memulai keduanya dari 0.0.

3.3 ControllerState
Field	Arti
left_x/y, right_x/y	Empat sumbu stick (-1..1)
left_trigger, right_trigger	Dua trigger (0..1)
buttons	Nama tombol → ditekan atau tidak
smoothing_alpha	Kekuatan smoothing (bawaan 0.25)
deadzone	Zona mati di tengah stick (bawaan 0.05)
auto_center_rate	Kecepatan kembali ke 0 per detik (bawaan 4.0)
response_curve	Kurva sensitivitas (bawaan Linear)

Komentar terbalik: tertulis 0 = no smoothing, 1 = hold, padahal rumusnya (3.5) membuat 1.0 = tanpa smoothing dan 0.0 = nilai tertahan. Perbaiki komentarnya agar tidak membingungkan.

3.4 Penulis data
rust
pub fn set_raw_axis(&mut self, axis: &str, value: f32)

Menerima nama sumbu dan nilai, lalu menyimpannya ke raw.

Stick di-clamp(-1.0, 1.0), trigger dipaksa 0..1.
Nama yang tidak dikenal jatuh ke _ => {}, yaitu diam-diam diabaikan (lihat 5.3).
rust
pub fn set_button(&mut self, key: &str, pressed: bool)

insert ke HashMap. Jika tombol sudah ada, nilainya ditimpa.

3.5 Tiga fungsi pembantu (privat)

apply_deadzone membuang getaran kecil di tengah stick dan menskalakan ulang sisanya agar tetap penuh sampai 1.0.

Contoh dengan deadzone = 0.05:

Input	Output
0.03	0.0 (dibuang)
0.5	(0.5−0.05)/0.95 ≈ 0.474
1.0	1.0
-0.5	-0.474 (tanda dipertahankan lewat signum)

apply_response_curve menerapkan ResponseCurve (tabel 3.1). Pangkat dikenakan pada besarnya (abs), lalu tandanya dikembalikan.

low_pass_step adalah smoothing:

hasil = a × raw + (1 − a) × nilai_sebelumnya

Dengan a = 0.25 dan input tetap 1.0, hasilnya naik bertahap: 0.25 → 0.44 → 0.58 → 0.68 → ... (sekitar 0.94 setelah 10 tick). Ini yang membuat gerakan terasa “licin”.

3.6 tick(dt)

dt adalah selisih waktu sejak tick sebelumnya (detik). Alur untuk setiap stick:

raw
 ↓ apply_deadzone       → buang getaran, skala ulang
 ↓ auto-center          → jika stick dilepas (hasil deadzone 0) tapi filtered ≠ 0,
 ↓                         tarik target ke 0 sebesar auto_center_rate × dt
 ↓ low_pass_step        → haluskan terhadap nilai sebelumnya
 ↓ apply_response_curve → bentuk sensitivitas
filtered (disimpan)

Contoh auto-center: dt = 0.016 → penurunan 4.0 × 0.016 = 0.064 per tick, jadi dari 1.0 ke 0 butuh sekitar 0.25 detik.

Trigger lebih sederhana: hanya deadzone (tanpa skala ulang), smoothing, dan curve. Tidak ada auto-center.

Kenapa closure menerima state sebagai parameter? Kalau closure menangkap self langsung, ia meminjam self sementara hasilnya mau ditulis ke self.left_x.filtered, dan itu bentrok dengan aturan peminjaman Rust. Dengan memberi state: &ControllerState sebagai argumen, peminjaman hanya berlangsung saat pemanggilan, lalu selesai sebelum penugasan nilai. Bagian ini sudah benar dan bisa dikompilasi. Fungsi biasa (fn) sebenarnya lebih rapi daripada closure di sini.

3.7 SHARED_STATE
rust
pub static SHARED_STATE: Lazy<Mutex<ControllerState>> = ...

Satu state global yang dipakai bersama oleh banyak task.

static: hidup selama program berjalan, bisa diakses dari mana saja.
Lazy: dibuat saat pertama dipakai. Perlu karena HashMap::new() tidak bisa dievaluasi saat kompilasi.
Mutex: hanya satu pihak boleh mengubah state pada satu waktu.
tokio Mutex: dikunci dengan SHARED_STATE.lock().await.
4. Alur data (perkiraan)
Pesan controller masuk
      ↓
lock → set_raw_axis() / set_button()     ← tulis nilai mentah
      ↓
Loop berkala (misalnya tiap 16 ms)
      ↓
lock → tick(dt)                          ← olah semua sumbu
      ↓
baca filtered / buttons → kirim ke gamepad virtual