use tokio::net::TcpListener;
use tokio::io::{AsyncReadExt};

use crate::input::input_handler::{InputHandler, InputCommand};

pub async fn start_tcp_server(addr: &str) {
    let listener = TcpListener::bind(addr).await.unwrap();
    println!("TCP Server listening at {}", addr);

    loop {
        let (mut socket, _) = listener.accept().await.unwrap();
        println!("[TCP] Client connected");

        tokio::spawn(async move {
            let mut input = InputHandler::new();
            let mut buffer = vec![0u8; 2048];

            loop {
                let n = match socket.read(&mut buffer).await {
                    Ok(n) if n == 0 => {
                        println!("[TCP] Client disconnected");
                        return;
                    }
                    Ok(n) => n,
                    Err(_) => return,
                };

                let json = String::from_utf8_lossy(&buffer[..n]);

                match serde_json::from_str::<InputCommand>(&json) {
                    Ok(cmd) => input.execute(cmd),
                    Err(e) => println!("[ERROR] Invalid JSON: {}", e),
                }
            }
        });
    }
}
