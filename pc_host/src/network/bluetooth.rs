use std::time::Duration;

use anyhow::{Result, Context};
use tokio::runtime::Handle;

use crate::input::{controller_event::ControllerEvent, vigem_mapper::map_event_to_state};

pub async fn start_bluetooth_listener(maybe_port: Option<String>)->Result<()> {
    let port_name = detect_port(maybe_port).context("No serial port found")?;
    log::info!("Opening serial port: {}", &port_name);

    let handle = Handle::current();

    tokio::task::spawn_blocking(move || {
        if let Err(e) = blocking_serial_loop(&port_name, handle) {
            log::error!("Bluetooth loop error: {}", e);
        } 
    });

    Ok(())
}

fn blocking_serial_loop(port_name: &str, handle:Handle)->Result<()> {
    let mut port = serialport::new(port_name, 115200)
        .timeout(Duration::from_millis(100))
        .open()
        .with_context(|| format!("Couldn't open port {}", port_name))?;

    log::info!("Serial port {} opened!", port_name);

    let mut buffer: Vec<u8> = vec![];
    let mut read_buf = [0u8; 256];

    loop {
        match port.read(&mut read_buf) {
            Ok(n) if n > 0 => {
                buffer.extend_from_slice(&read_buf[..n]);
                while let Some(pos) = buffer.iter().position(|&b| b == b'\n') {
                    let line_bytes = buffer.drain(..=pos).collect::<Vec<u8>>();
                    let line = String::from_utf8_lossy(&line_bytes).trim().to_string();
                    if line.is_empty() { continue; }

                    match serde_json::from_str::<ControllerEvent>(&line) {
                        Ok(ev) => {handle.spawn(async move {map_event_to_state(ev).await}); }
                        Err(e) => { log::warn!("Bad JSON from BT: {} | {}", line, e); }
                    }
                }
            }
            Err(e) if e.kind() == std::io::ErrorKind::TimedOut => {}
            Err(e) => {
                log::error!("Serial read error: {}", e);
                std::thread::sleep(Duration::from_millis(300));
            }
            _ => {}

        }
    }
}

fn detect_port(maybe: Option<String>)->Option<String> {
    if let Some(p) = maybe { return Some(p); }

    let ports = serialport::available_ports().ok()?;
    for p in &ports {
        let name = p.port_name.to_lowercase();
        let t = format!("{:?}", p.port_type).to_lowercase();
        if name.contains("bluetooth") || name.contains("rfcomm") || name.starts_with("com") || t.contains("bluetooth") {
            log::info!("Auto detected port: {}", p.port_name);
            return Some(p.port_name.clone());
        }
    } 
    ports.first().map(|p| p.port_name.clone())
}