use std::net::SocketAddr;
use tokio::net::TcpListener;
use futures::{StreamExt, SinkExt};
use tokio_tungstenite::{accept_async, tungstenite::protocol::Message};
use log::{info, warn, error};

use enigo::{Enigo, Settings};
use crate::input::input_handler::process_input_event;

pub async fn start_websocket_server(addr: &str) -> anyhow::Result<()> {
    let listener = TcpListener::bind(addr).await?;
    info!("WebSocket Server running at ws://{}", addr);

    while let Ok((stream, addr)) = listener.accept().await {
        tokio::spawn(async move {
            if let Err(e) = handle_client(stream, addr).await {
                error!("Client handler error: {:?}", e);
            }
        });
    }

    Ok(())
}

async fn handle_client(stream: tokio::net::TcpStream, addr: SocketAddr) -> anyhow::Result<()> {
    info!("Client connected: {}", addr);

    let ws_stream = accept_async(stream).await?;
    let (mut write, mut read) = ws_stream.split();

    let mut enigo = Enigo::new(&Settings::default())
        .expect("Failed to init Enigo");

    let _ = write.send(Message::Text(r#"{"type":"welcome"}"#.into())).await;

    while let Some(msg) = read.next().await {
        match msg {
            Ok(Message::Text(text)) => {
                info!("Received: {}", text);

                if let Err(e) = process_input_event(&text, &mut enigo).await {
                    error!("Failed to process input: {:?}", e);
                }
            }

            Ok(Message::Binary(_)) => warn!("Binary message ignored"),

            Ok(Message::Close(_)) => {
                info!("Client disconnected: {}", addr);
                break;
            }

            Err(e) => {
                error!("WebSocket error: {:?}", e);
                break;
            }

            _ => {}
        }
    }

    Ok(())
}
