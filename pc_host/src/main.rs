mod network;
mod input;
mod controller;
mod utils;

use utils::logger::init_logger;
use network::websocket::start_websocket_server;

use crate::input::vigem_mapper;

#[tokio::main]
async fn main() {
    init_logger();
    log::info!("🚀 PC Host running...");

    vigem_mapper::init_vigem_and_start_flusher().await;

    if let Err(e) = start_websocket_server().await {
        log::error!("❌ WebSocket error: {}", e);
    }
}
