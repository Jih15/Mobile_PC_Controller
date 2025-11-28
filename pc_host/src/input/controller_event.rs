use serde::Deserialize;

#[derive(Debug, Deserialize)]
#[serde(tag = "type")]

pub enum ControllerEvent {
    // Gyro Steering -1..1
    Gyro {
        value: f32,
    },

    // Vertical Slider (Throttle)
    Throttle {
        value: f32,
    },

    // Vertical Slider (Brake)
    Brake {
        value: f32,
    },

    // JoyStick
    JoyStick {
        stick: String,
        x: f32,
        y: f32,
    },

    // Button
    Button {
        key: String,
        pressed: bool
    }
}