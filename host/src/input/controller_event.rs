use std::collections::HashMap;
use serde::Deserialize;

#[derive(Debug, Deserialize)]
#[serde(tag="type")]
pub enum ControllerEvent {
    Gamepad {
        lx: f32,
        ly: f32,
        rx: f32,
        ry: f32,
        lt: f32,
        rt: f32,
        buttons: HashMap<String, bool>
    }
}