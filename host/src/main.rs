use std::sync::{Arc, atomic::{AtomicBool, Ordering}};

use crate::utils::logger::init_logger;


mod utils;
mod input;
mod controller;
mod network;
mod tray;

fn main() {
    init_logger();

    #[cfg(target_os = "windows")]
    unsafe {
        use windows::Win32::Media::timeBeginPeriod;
        let result = timeBeginPeriod(1);
        if result == 0 {
            log::info!("Windows timer resolution set to 1ms");
        } else {
            log::warn!("timeBeginPeriod failed: {}", result);
        }
    }

    log::info!("PC Host Starting...");

    let shutdown_flag = Arc::new(AtomicBool::new(false));
    let shutdown_clone = shutdown_flag.clone();

    std::thread::spawn(move || {
        tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .expect("Failed to build tokio runtime")
            .block_on(async_main(shutdown_clone));
    });

    tray::run_tray(shutdown_flag);

    #[cfg(target_os = "windows")]
    unsafe {
        use windows::Win32::Media::timeEndPeriod;
        timeEndPeriod(1);
    }

    log::info!("PC Host Exited");
    std::process::exit(0);

}

async fn async_main(shutdown_flag: Arc<AtomicBool>) {
    use network::websocket::start_websocket_server;
    use input::vigem_mapper;

    vigem_mapper::init_vigem_and_start_flusher().await;

    tokio::spawn(async {
        if let Err(e) = start_websocket_server().await {
            log::error!("Websocket error: {}", e);
        }
    });

    loop {
        tokio::time::sleep(std::time::Duration::from_millis(500)).await;
        if shutdown_flag.load(Ordering::SeqCst) {
            log::info!("Shutdown signal received");
            break;
        }
    }
}