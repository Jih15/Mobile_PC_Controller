// src/network/websocket.rs
use tokio::net::TcpListener;
use tokio_tungstenite::accept_async;
use futures_util::{StreamExt };

use crate::input::controller_event::ControllerEvent;
use crate::input::vigem_mapper::{init_vigem_and_start_flusher, map_event_to_state};

pub async fn start_websocket_server() -> anyhow::Result<()> {
    // ensure ViGEm flusher started
    init_vigem_and_start_flusher().await;

    let listener = TcpListener::bind("0.0.0.0:9002").await?;
    log::info!("🌐 WebSocket listening on ws://0.0.0.0:9002");

    while let Ok((stream, addr)) = listener.accept().await {
        tokio::spawn(async move {
            let ws_stream = match accept_async(stream).await {
                Ok(ws) => ws,
                Err(e) => {
                    log::error!("WS accept error: {}", e);
                    return;
                }
            };

            log::info!("📱 Flutter controller connected: {}", addr);

            let (_write, mut read) = ws_stream.split();

            while let Some(Ok(msg)) = read.next().await {
                if msg.is_text() {
                    let text = msg.to_text().unwrap();

                    // log::info!("WS RAW : {}", text);

                    match serde_json::from_str::<ControllerEvent>(&text) {
                        Ok(event) => {
                            // write into shared state (async)
                            map_event_to_state(event).await;
                        }
                        Err(e) => {
                            log::warn!("Invalid JSON from client: {} | {}", text, e);
                        }
                    }
                }
            }

            log::info!("📴 Flutter controller disconnected: {}", addr);
        });
    }

    Ok(())
}
