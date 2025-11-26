mod network;
mod utils;
mod input;

use utils::logger::init_logger;
use network::websocket::start_websocket_server;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    init_logger();

    log::info!("📡 PC Host starting...");

    let addr = "0.0.0.0:9001";
    start_websocket_server(addr).await?;

    Ok(())
}
