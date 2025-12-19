use std::io::Read;
use std::time::Duration;

use anyhow::{Result, Context};

use crate::input::controller_event::ControllerEvent;
use crate::input::vigem_mapper::map_event_to_state;

pub async fn start_bluetooth_listener(maybe_port: Option<String>) -> Result<()> {
    let port_name = detect_port(maybe_port).context("No serial port found")?;
    log::info!("🔌 Opening serial port: {}", &port_name);

    // Run blocking loop in separate thread
    let port_clone = port_name.clone();
    tokio::task::spawn_blocking(move || {
        if let Err(e) = blocking_serial_loop(&port_clone) {
            log::error!("Bluetooth loop error: {}", e);
        }
    });

    Ok(())
}

/// Blocking serial read loop
fn blocking_serial_loop(port_name: &str) -> Result<()> {
    // 🚀 NEW API:
    let mut port = serialport::new(port_name, 115200)
        .timeout(Duration::from_millis(100))
        .open()
        .with_context(|| format!("Couldn't open port {}", port_name))?;

    log::info!("Serial port {} opened", port_name);

    let mut buffer: Vec<u8> = vec![];
    let mut read_buf = [0u8; 256];

    loop {
        match port.read(&mut read_buf) {
            Ok(n) if n > 0 => {
                buffer.extend_from_slice(&read_buf[..n]);

                // Process line-by-line
                while let Some(pos) = buffer.iter().position(|&b| b == b'\n') {
                    let line = buffer.drain(..=pos).collect::<Vec<u8>>();
                    let line = String::from_utf8_lossy(&line).trim().to_string();

                    if line.is_empty() {
                        continue;
                    }

                    match serde_json::from_str::<ControllerEvent>(&line) {
                        Ok(ev) => {
                            tokio::spawn(async move {
                                map_event_to_state(ev).await;
                            });
                        }
                        Err(e) => {
                            log::warn!("Bad JSON from BT: {} | {}", line, e);
                        }
                    }
                }
            }

            // Timeouts are normal — bluetooth idle
            Err(err) if err.kind() == std::io::ErrorKind::TimedOut => {}

            // Other errors
            Err(err) => {
                log::error!("Serial read error: {}", err);
                std::thread::sleep(Duration::from_millis(300));
            }

            _ => {}
        }
    }
}

/// Auto-detect COM ports
fn detect_port(maybe: Option<String>) -> Option<String> {
    if let Some(p) = maybe {
        return Some(p);
    }

    let ports = serialport::available_ports().ok()?;

    for p in &ports {
        let name = p.port_name.to_lowercase();
        let t = format!("{:?}", p.port_type).to_lowercase();

        if name.contains("bluetooth")
            || name.contains("rfcomm")
            || name.starts_with("com")
            || t.contains("bluetooth")
        {
            return Some(p.port_name.clone());
        }
    }

    ports.first().map(|p| p.port_name.clone())
}
