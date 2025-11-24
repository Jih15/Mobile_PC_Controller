use serde::Deserialize;
use anyhow::Result;

use enigo::{
    Enigo,
    Mouse, Keyboard, Button, Key, Direction, Coordinate
};

#[derive(Debug, Deserialize)]
pub struct InputEvent {
    pub event_type: String,     // "mouse", "key", "gyro"
    
    // mouse
    pub x: Option<i32>,
    pub y: Option<i32>,
    pub button: Option<String>,

    // keyboard
    pub key: Option<String>,
    pub pressed: Option<bool>,

    // gyro (optional)
    pub gyro_x: Option<f32>,
    pub gyro_y: Option<f32>,
    pub gyro_z: Option<f32>,
}

pub async fn process_input_event(json: &str, enigo: &mut Enigo) -> Result<()> {
    let event: InputEvent = serde_json::from_str(json)?;

    match event.event_type.as_str() {
        // ---------------------------------------
        // 🖱 MOUSE
        // ---------------------------------------
        "mouse_move" => {
            if let (Some(x), Some(y)) = (event.x, event.y) {
                let _ = enigo.move_mouse(x, y, Coordinate::Abs);
            }
        }

        "mouse_click" => {
            match event.button.as_deref() {
                Some("left") => {
                    let _ = enigo.button(Button::Left, Direction::Click);
                }
                Some("right") => {
                    let _ = enigo.button(Button::Right, Direction::Click);
                }
                _ => log::warn!("Unknown mouse button"),
            }
        }

        // ---------------------------------------
        // ⌨ KEYBOARD
        // ---------------------------------------
        "key" => {
            log::info!("KEY EVENT: key={:?}, pressed={:?}", event.key, event.pressed);

            if let Some(k) = event.key {
                if let Some(pressed) = event.pressed {
                    let key = Key::Unicode(k.chars().next().unwrap());

                    if pressed {
                        log::info!("Pressing key: {:?}", key);
                        let _ = enigo.key(key, Direction::Press);
                    } else {
                        log::info!("Releasing key: {:?}", key);
                        let _ = enigo.key(key, Direction::Release);
                    }
                }
            }
        }


        // ---------------------------------------
        // 📱 GYRO (opsional)
        // ---------------------------------------
        "gyro" => {
            log::info!(
                "Gyro: x={:?} y={:?} z={:?}",
                event.gyro_x, event.gyro_y, event.gyro_z
            );
        }

        _ => {
            log::warn!("Unknown event type: {}", event.event_type);
        }
    }

    Ok(())
}
