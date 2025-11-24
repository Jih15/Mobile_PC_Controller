use tokio::net::TcpListener;
use tokio_tungstenite::accept_async;
use futures_util::StreamExt;

use crate::control::command::Command;
use crate::input::input_handler::execute_input;

pub async fn start_control_socket(){
    let listener = TcpListener::bind("0.0.0.0:5001").await.unwrap();
    println!("[CONTROL] WebSocket Server running on ws://0.0.0.0:5001");

    while let Ok((stream, _)) = listener.accept().await {
        println!("[CONTROL] Mobile connected!");

        tokio::spawn(async move{
            let ws_stream = accept_async(stream).await.unwrap();
            let (_, read) = ws_stream.split();

            read.for_each(|msg| async {
                if let Ok(msg) = msg {
                    if msg.is_text(){
                        let text = msg.to_text().unwrap();

                        if let Ok(command) = serde_json::from_str::<Command>(text){
                            execute_input(command);
                        } else {
                            println!("[CONTROL] Invalid JSON: {}", text);
                        }
                    }
                }
            })
        }).await;
    }
}