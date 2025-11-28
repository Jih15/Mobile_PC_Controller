use crate::controller::state::SHARED_STATE;
use crate::input::controller_event::ControllerEvent;

use once_cell::sync::Lazy;
use tokio::sync::Mutex;
use tokio::time::{interval, Duration};

use vigem_client::{
    Client,
    Xbox360Wired,
    XButtons,
    XGamepad,
    TargetId,
};

use std::sync::Arc;

static VIGEM: Lazy<Arc<Mutex<Option<VigemContext>>>> = Lazy::new(|| {
    Arc::new(Mutex::new(None))
});

struct VigemContext {
    // client: Arc<Client>,
    controller: Xbox360Wired<Arc<Client>>,
}

pub async fn init_vigem_and_start_flusher() {
    {
        let mut global = VIGEM.lock().await;

        if global.is_none() {
            match Client::connect() {
                Ok(native_client) => {
                    let client = Arc::new(native_client);

                    let mut controller = Xbox360Wired::new(
                        client.clone(),
                        TargetId::XBOX360_WIRED
                    );

                    if let Err(e) = controller.plugin() {
                        log::error!("Failed to plugin X360 controller: {}", e);
                        return;
                    }

                    controller.wait_ready().unwrap();

                    *global = Some(VigemContext {
                        // client,
                        controller,
                    });

                    log::info!("ViGEm Client Connected + X360 Plugged In!");
                }

                Err(e) => {
                    log::error!("ViGEmClient connect failed: {}", e);
                    return;
                }
            }
        }

    }

    tokio::spawn(async {
        let mut ticker = interval(Duration::from_millis(16));

        loop {
            ticker.tick().await;

            let snapshot = {
                let s = SHARED_STATE.lock().await;
                // log::info!("Snapshot button state: {:?}", s.buttons);
                (
                    s.left_x.filtered,
                    s.left_y.filtered,
                    s.right_x.filtered,
                    s.right_y.filtered,
                    s.left_trigger.filtered,
                    s.right_trigger.filtered,
                    s.buttons.clone(),
                )
            };

            let mut global = VIGEM.lock().await;
            if global.is_none() { continue; }
            let ctx = global.as_mut().unwrap();

            let mut gamepad = XGamepad {
                left_trigger: (snapshot.4 * 255.0) as u8,
                right_trigger: (snapshot.5 * 255.0) as u8,

                thumb_lx: (snapshot.0 * 32767.0) as i16,
                thumb_ly: (snapshot.1 * 32767.0) as i16,
                thumb_rx: (snapshot.2 * 32767.0) as i16,
                thumb_ry: (snapshot.3 * 32767.0) as i16,

                buttons: XButtons { raw: 0 },
            };


            // apply buttons
            for (key, pressed) in snapshot.6.iter() {
                if !pressed { continue; }

                let k = key.to_ascii_uppercase();

                match k.as_str() {
                    "A" => gamepad.buttons.raw |= XButtons::A,
                    "B" => gamepad.buttons.raw |= XButtons::B,
                    "X" => gamepad.buttons.raw |= XButtons::X,
                    "Y" => gamepad.buttons.raw |= XButtons::Y,

                    "LB" => gamepad.buttons.raw |= XButtons::LB,
                    "RB" => gamepad.buttons.raw |= XButtons::RB,

                    "START" => gamepad.buttons.raw |= XButtons::START,
                    "BACK" => gamepad.buttons.raw |= XButtons::BACK,

                    other => log::warn!("Unknown button key: {}", other),
                }
            }


            if let Err(e) = ctx.controller.update(&gamepad) {
                log::warn!("ViGEm update failed: {}", e);
            }
        }
    });
}

/// Menerima event dari WebSocket
pub async fn map_event_to_state(event: ControllerEvent) {
    log::info!("Mapping event: {:?}", event);

    let mut s = SHARED_STATE.lock().await;


    match event {
        ControllerEvent::Gyro { value } => {
            s.set_raw_axis("left_x", value);
        }

        ControllerEvent::Throttle { value } => {
            s.set_raw_axis("rt", value);
        }

        ControllerEvent::Brake { value } => {
            s.set_raw_axis("lt", value);
        }

        ControllerEvent::Joystick { stick, x, y } => {
            if stick == "left" {
                s.set_raw_axis("left_x", x);
                s.set_raw_axis("left_y", y);
            } else {
                s.set_raw_axis("right_x", x);
                s.set_raw_axis("right_y", y);
            }
        }

        ControllerEvent::Button { key, pressed } => {
            log::info!("Button event: {} = {}", key, pressed);
            s.set_button(&key, pressed);
        }
    }
}
