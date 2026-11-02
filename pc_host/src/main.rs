// src/main.rs

#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod network;
mod input;
mod controller;
mod utils;
mod tray;

use std::sync::Arc;
use std::sync::atomic::{AtomicBool, Ordering};
use utils::logger::init_logger;

fn main() {
    init_logger();

    // ── Fix Windows timer resolution ──────────────────────────────────────
    // Default Windows timer = 15.6ms → tokio interval(8ms) jadi ~15ms
    // timeBeginPeriod(1) → set ke 1ms, sama seperti saat jalan di VS Code
    // WAJIB dipanggil sebelum tokio runtime dibuat
    #[cfg(target_os = "windows")]
    unsafe {
        use windows::Win32::Media::timeBeginPeriod;
        let result = timeBeginPeriod(1);
        if result == 0 {
            log::info!("✅ Windows timer resolution set to 1ms");
        } else {
            log::warn!("⚠️  timeBeginPeriod failed: {}", result);
        }
    }

    log::info!("🚀 PC Host starting...");

    let shutdown_flag  = Arc::new(AtomicBool::new(false));
    let shutdown_clone = shutdown_flag.clone();

    // Tokio runtime di background thread
    std::thread::spawn(move || {
        tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .expect("Failed to build tokio runtime")
            .block_on(async_main(shutdown_clone));
    });

    // Tray blocking loop di main thread (Windows requirement)
    tray::run_tray(shutdown_flag);

    // Cleanup timer saat keluar
    #[cfg(target_os = "windows")]
    unsafe {
        use windows::Win32::Media::timeEndPeriod;
        timeEndPeriod(1);
    }

    log::info!("👋 PC Host exited");
    std::process::exit(0);
}

async fn async_main(shutdown_flag: Arc<AtomicBool>) {
    use network::websocket::start_websocket_server;
    use network::bluetooth;
    use input::vigem_mapper;

    vigem_mapper::init_vigem_and_start_flusher().await;

    tokio::spawn(async {
        if let Err(e) = start_websocket_server().await {
            log::error!("❌ WebSocket error: {}", e);
        }
    });

    tokio::spawn(async {
        if let Err(e) = bluetooth::start_bluetooth_listener(None).await {
            log::error!("❌ Bluetooth error: {}", e);
        }
    });

    loop {
        tokio::time::sleep(std::time::Duration::from_millis(500)).await;
        if shutdown_flag.load(Ordering::SeqCst) {
            log::info!("🛑 Shutdown signal received");
            break;
        }
    }
}