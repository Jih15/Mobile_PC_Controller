## logger.rs
Logging system saat menjalankan rust,
```rust
env_logger::builder()
    .filter_level(log::LevelFilter::Info)
    .init();
```
1. builder() membuat pengatur (builder) logger. Secara default ia membaca environment variable RUST_LOG.
2. .filter_level(Info) menentukan level minimum pesan yang ditampilkan.
3. .init() mendaftarkan logger ini sebagai logger global untuk seluruh program.

```
main() memanggil init_logger()
        ↓
Logger dibuat dan level diatur ke Info
        ↓
.init() mendaftarkannya sebagai logger global
        ↓
Saat kode memanggil info!("...") di mana saja:
  → cek level: lolos? → dicetak ke terminal (stderr)
  → debug!("...") → level terlalu rendah → dibuang
```

## config.rs

```rust
pub const WS_PORT: u16 = 9002;
```
Websocket port config