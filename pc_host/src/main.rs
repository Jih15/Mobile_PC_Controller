mod network;
mod utils;
mod input;
mod controller;

use utils::logger::init_logger;
use network::websocket::start_websocket_server;

#[tokio::main]
async fn main(){
    init_logger();

    log::info!("PC Host Running...");

    if let Err(e) = start_websocket_server().await {
        log::error!("Websocket Error: {}", e);
    }
}
