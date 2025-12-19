mod network;
mod input;
mod controller;
mod utils;

use utils::logger::init_logger;
use network::websocket::start_websocket_server;
use network::bluetooth;

use crate::input::vigem_mapper;

#[tokio::main]
async fn main() {
    init_logger();
    log::info!("🚀 PC Host running...");

    // start ViGEm flusher
    vigem_mapper::init_vigem_and_start_flusher().await;

    // start websocket in background
    tokio::spawn(async {
        if let Err(e) = start_websocket_server().await {
            log::error!("❌ WebSocket error: {}", e);
        }
    });

    // start bluetooth listener (auto-detect port if None)
    tokio::spawn(async {
        if let Err(e) = bluetooth::start_bluetooth_listener(None).await {
            log::error!("❌ Bluetooth listener error: {}", e);
        }
    });

    // keep main alive (or join tasks properly)
    // simplest: sleep forever (or implement graceful shutdown)
    loop {
        tokio::time::sleep(std::time::Duration::from_secs(60)).await;
    }
}
