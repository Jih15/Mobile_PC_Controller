mod input;
mod network;
mod utils;

use utils::logger::init_logger;
use network::websocket::start_websocket_server;

#[tokio::main]
async fn main() {
    init_logger();

    log::info!("📡 PC Host starting...");

    if let Err(e) = start_websocket_server().await {
        log::error!("❌ Server error: {}", e);
    }
}
