// src/main.rs
//
// Arsitektur thread:
// ┌─ main thread  ──────────────────────────────────────────────┐
// │  tray icon event loop (Windows WAJIB di main thread)        │
// └─────────────────────────────────────────────────────────────┘
// ┌─ background thread ─────────────────────────────────────────┐
// │  tokio runtime → WebSocket + Bluetooth + ViGEm flusher      │
// └─────────────────────────────────────────────────────────────┘
//
// Release build: tidak ada console window (#![windows_subsystem])
// Debug build:   console tetap muncul untuk log

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
    log::info!("🚀 PC Host starting...");

    // Shared flag: tray Quit → set true → tokio loop berhenti
    let shutdown_flag  = Arc::new(AtomicBool::new(false));
    let shutdown_clone = shutdown_flag.clone();

    // Tokio runtime jalan di background thread
    std::thread::spawn(move || {
        tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .expect("Failed to build tokio runtime")
            .block_on(async_main(shutdown_clone));
    });

    // Tray icon blocking loop — harus di main thread
    tray::run_tray(shutdown_flag);

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

    // Poll shutdown flag setiap 500ms
    loop {
        tokio::time::sleep(std::time::Duration::from_millis(500)).await;
        if shutdown_flag.load(Ordering::SeqCst) {
            log::info!("🛑 Shutdown signal received, stopping...");
            break;
        }
    }
}