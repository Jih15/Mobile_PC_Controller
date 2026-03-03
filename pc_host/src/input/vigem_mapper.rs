use std::{sync::Arc, time::Duration};

use futures::lock::Mutex;
use once_cell::sync::Lazy;
use tokio::time::interval;
use vigem_client::{Client, TargetId, XButtons, XGamepad, Xbox360Wired};

use crate::{controller::{self, state::SHARED_STATE}, input::controller_event::ControllerEvent};

static VIGEM: Lazy<Arc<Mutex<Option<VigemContext>>>> = Lazy::new(||Arc::new(Mutex::new(None)));

struct VigemContext {
    controller: Xbox360Wired<Arc<Client>>,
}

pub async fn init_vigem_and_start_flusher() {
    let mut global = VIGEM.lock().await;

    if global.is_some(){
        log::warn!("ViGEm already initialized, skipping..");
        return ;
    }

    match Client::connect() {
        Ok(native_client) => {
            let client = Arc::new(native_client);
            let mut controller = Xbox360Wired::new(client.clone(), TargetId::XBOX360_WIRED);

            if let Err(e) = controller.plugin() {
                log::error!("Failed to plugin X360 controller: {}", e);
                return;
            }

            controller.wait_ready().unwrap();
            *global = Some(VigemContext { controller });
            log::info!("✅ ViGEm Client Connected + X360 Plugged In!");
        }
        Err(e) => {
            log::error!("ViGEmClient connect failed: {}", e);
            return;
        }
    }

    tokio::spawn(async {
        let mut ticker = interval(Duration::from_millis(8));

        loop {
            ticker.tick().await;

            // Tick: apply smoothing, deadzone, auto-center
            {
                let mut s = SHARED_STATE.lock().await;
                s.tick(0.008);
            }

            // Snapshot hasil filtered
            let snap = {
                let s = SHARED_STATE.lock().await;
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
            let Some(ctx) = global.as_mut() else { continue };

            let mut gamepad = XGamepad {
                left_trigger:  (snap.4 * 255.0).clamp(0.0, 255.0) as u8,
                right_trigger: (snap.5 * 255.0).clamp(0.0, 255.0) as u8,
                thumb_lx: (snap.0 * 32767.0).clamp(-32768.0, 32767.0) as i16,
                thumb_ly: (snap.1 * 32767.0).clamp(-32768.0, 32767.0) as i16,
                thumb_rx: (snap.2 * 32767.0).clamp(-32768.0, 32767.0) as i16,
                thumb_ry: (snap.3 * 32767.0).clamp(-32768.0, 32767.0) as i16,
                buttons: XButtons { raw: 0 },
            };

            for (key, &pressed) in snap.6.iter() {
                if !pressed { continue; }
                match key.to_ascii_uppercase().as_str() {
                    "A"      => gamepad.buttons.raw |= XButtons::A,
                    "B"      => gamepad.buttons.raw |= XButtons::B,
                    "X"      => gamepad.buttons.raw |= XButtons::X,
                    "Y"      => gamepad.buttons.raw |= XButtons::Y,
                    "UP"     => gamepad.buttons.raw |= XButtons::UP,
                    "DOWN"   => gamepad.buttons.raw |= XButtons::DOWN,
                    "LEFT"   => gamepad.buttons.raw |= XButtons::LEFT,
                    "RIGHT"  => gamepad.buttons.raw |= XButtons::RIGHT,
                    "LB"     => gamepad.buttons.raw |= XButtons::LB,
                    "RB"     => gamepad.buttons.raw |= XButtons::RB,
                    "LTHUMB" => gamepad.buttons.raw |= XButtons::LTHUMB,
                    "RTHUMB" => gamepad.buttons.raw |= XButtons::RTHUMB,
                    "START"  => gamepad.buttons.raw |= XButtons::START,
                    "BACK"   => gamepad.buttons.raw |= XButtons::BACK,
                    other    => log::warn!("Unknown button: {}", other),
                }
            }

            if let Err(e) = ctx.controller.update(&gamepad) {
                log::warn!("ViGEm update failed: {}", e);
            }
        }
    });
}

pub async fn map_event_to_state(event: ControllerEvent) {
    let mut s = SHARED_STATE.lock().await;

    match event {
        ControllerEvent::Gamepad { lx, ly, rx, ry, lt, rt, buttons } => {
            s.set_raw_axis("left_x", lx);
            s.set_raw_axis("left_y", ly);
            s.set_raw_axis("right_x", rx);
            s.set_raw_axis("right_y", ry);
            s.set_raw_axis("lt", lt);
            s.set_raw_axis("rt", rt);

            s.buttons.clear();
            for (key, pressed) in buttons {
                s.set_button(&key, pressed);
            }
        }
    }
}