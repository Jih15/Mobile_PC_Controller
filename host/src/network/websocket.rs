
use futures_util::{SinkExt, StreamExt};
use tokio::net::TcpListener;
use tokio_tungstenite::accept_async;
use crate::{input::{controller_event::ControllerEvent, vigem_mapper::map_event_to_state}, utils::config::WS_PORT};

pub async fn start_websocket_server()-> anyhow::Result<()> {
    let addr = format!("0.0.0.0:{}", WS_PORT);
    let listener = TcpListener::bind(&addr).await?;
    log::info!("Websocket listening on ws://{}", addr);

    while let Ok((stream, addr)) = listener.accept().await {
        tokio::spawn(async move {
            let ws = match accept_async(stream).await {
                Ok(ws) => ws,
                Err(e)=> {log::error!("WS Accept error {}: {}", addr, e); return ;}
            };

            log::info!("Flutter connected: {}", addr);

            let (mut write, mut read) = ws.split();
            let _ = write.send("connected".into()).await;

            while let Some(msg) = read.next().await {
                let msg = match msg {
                    Ok(m) => m,
                    Err(e) => {log::warn!("WS Read error {}: {}", addr, e); break;}
                };

                if msg.is_text() {
                    let text = msg.to_text().unwrap_or_default();
                    match serde_json::from_str::<ControllerEvent>(text) {
                        Ok(event) => {
                            map_event_to_state(event).await;
                        } 
                        Err(e)=> {
                            log::warn!("Invalid JSON from {}: {} | {}", addr, text, e );
                        }
                    }
                }
            }

            log::info!("Flutter disconnected: {}", addr);
        });
    }

    Ok(())
}