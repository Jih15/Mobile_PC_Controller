use vigem_client::{Client, TargetId, XGamepad, XButtons};

use once_cell::sync::Lazy;
use tokio::sync::Mutex;

use crate::{controller::controller_event::ControllerEvent, input::controller_event::ControllerEvent};

static GAMEPAD: Lazy<Mutex<XGamepad>> = Lazy::new(|| Mutex::new(XGamepad::new()));

static CLIENT: Lazy<Client> = Lazy::new(|| {
    let client = Client::connect().expect("ViGEm Client Connection Failed");
    client
});

static TARGET: Lazy<TargetId> = Lazy::new(|| {
    let target = TargetId::XBOX360_WIRED;
    CLIENT.target_create(target).expect("Failed to create target");
    CLIENT.target_add(&target).expect("Failed to add target");
    target
});

pub fn map_event_to_vigem(event: ControllerEvent) {
    tokio::spawn(async move {
        let mut pad = GAMEPAD.lock().await;

        match event {
            ControllerEvent::Gyro { value } => {
                pad.thumb_lx((value * 32767.0) as i16);
            }
        
            ControllerEvent::Throttle { value } => {
                pad.set_right_trigger((value * 255.0) as u8);
            }

            ControllerEvent::Brake { value } => {
                pad.set_left_trigger((value * 255.0) as u8);
            }

            ControllerEvent::Joystick { stick, x, y } => {
                let sx = (x * 32767.0) as i16;
                let sy = (y * 32767.0) as i16;

                if stick == "left" {
                    pad.set_thumb_lx(sx);
                    pad.set_thumb_ly(sy);
                } else {
                    pad.set_thumb_rx(sx);
                    pad.set_thumb_ry(sy);
                }
            }

            ControllerEvent::Button { key, pressed } => {
                match key.as_str() {
                    "A" => pad.set_button(XButton::A, pressed),
                    "B" => pad.set_button(XButton::B, pressed),
                    "X" => pad.set_button(XButton::X, pressed),
                    "Y" => pad.set_button(XButton::Y, pressed),

                    "LB" => pad.set_button(XButton::LEFT_SHOULDER, pressed),
                    "RB" => pad.set_button(XButton::RIGHT_SHOULDER, pressed),

                    "UP" => pad.set_button(XButton::DPAD_UP, pressed),
                    "DOWN" => pad.set_button(XButton::DPAD_DOWN, pressed),
                    "LEFT" => pad.set_button(XButton::DPAD_LEFT, pressed),
                    "RIGHT" => pad.set_button(XButton::DPAD_RIGHT, pressed),

                    _ => log::warn!("Unknown button: {}", key),
                }
            }
        }

        CLIENT.target_x360_update(&TARGET, &pad).unwrap();
    })
}