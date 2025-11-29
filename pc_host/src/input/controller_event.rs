// src/input/controller_event.rs
use serde::Deserialize;

#[derive(Debug, Deserialize)]
#[serde(tag = "type")]
pub enum ControllerEvent {
    Gyro { value: f32 },
    Throttle { value: f32 },
    Brake { value: f32 },
    Joystick { stick: String, x: f32, y: f32 },
    Button { key: String, pressed: bool },
}
