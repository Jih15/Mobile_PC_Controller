use anyhow::Result;
use tokio_tungstenite::accept_async;
use tokio::net::TcpListener;
use futures_util::{StreamExt};

use crate::input::input_handler::process_input_event;
use crate::utils::config::WS_PORT;

use enigo::{Enigo, Settings};

pub async fn start_websocket_server() -> Result<()> {
    let addr = format!("0.0.0.0:{}", WS_PORT);
    let listener = TcpListener::bind(&addr).await?;
    log::info!("WebSocket listening on ws://{}", addr);

    // Enigo instance dipakai bersama handler
    let settings = Settings::default();
    let mut enigo = Enigo::new(&settings)?;

    loop {
        let (stream, _) = listener.accept().await?;
        let mut ws = accept_async(stream).await?;

        log::info!("Client connected!");

        while let Some(msg) = ws.next().await {
            let msg = msg?;

            if msg.is_text() {
                let json = msg.to_text()?;
                let _ = process_input_event(json, &mut enigo).await;
            }
        }
    }
}
