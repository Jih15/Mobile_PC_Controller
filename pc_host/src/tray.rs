// src/tray.rs
//
// System tray icon untuk pc_host.
// Berjalan di main thread (requirement tray-icon di Windows).
// Komunikasi ke tokio runtime via channel.

use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;

use tray_icon::{
    menu::{Menu, MenuEvent, MenuItem, PredefinedMenuItem},
    TrayIcon, TrayIconBuilder, TrayIconEvent,
};
use winreg::{enums::HKEY_CURRENT_USER, RegKey};

const APP_NAME: &str = "PC Host Controller";
const REG_RUN_PATH: &str = r"Software\Microsoft\Windows\CurrentVersion\Run";

// ── Autostart helpers ────────────────────────────────────────────────────────

pub fn is_autostart_enabled() -> bool {
    let hkcu = RegKey::predef(HKEY_CURRENT_USER);
    let Ok(run_key) = hkcu.open_subkey(REG_RUN_PATH) else { return false };
    run_key.get_value::<String, _>(APP_NAME).is_ok()
}

pub fn set_autostart(enable: bool) {
    let hkcu = RegKey::predef(HKEY_CURRENT_USER);
    let Ok((run_key, _)) = hkcu.create_subkey(REG_RUN_PATH) else { return };

    if enable {
        // Path ke executable saat ini
        if let Ok(exe_path) = std::env::current_exe() {
            let path_str = exe_path.to_string_lossy().to_string();
            let _ = run_key.set_value(APP_NAME, &path_str);
            log::info!("✅ Autostart enabled: {}", path_str);
        }
    } else {
        let _ = run_key.delete_value(APP_NAME);
        log::info!("❌ Autostart disabled");
    }
}

// ── Tray setup + event loop ──────────────────────────────────────────────────

/// Dipanggil dari main thread setelah tokio runtime di-spawn.
/// Blocking — jalan terus sampai user pilih Quit.
pub fn run_tray(shutdown_flag: Arc<AtomicBool>) {
    // Load icon dari embedded bytes (buat icon sederhana 32x32 RGBA)
    let icon = load_icon();

    // ── Menu items ───────────────────────────────────────────────────────────
    let item_status    = MenuItem::new("🟢 PC Host Running", false, None);
    let item_autostart = MenuItem::new(
        autostart_label(),
        true,
        None,
    );
    let item_separator = PredefinedMenuItem::separator();
    let item_quit      = MenuItem::new("Quit", true, None);

    let menu = Menu::new();
    let _ = menu.append(&item_status);
    let _ = menu.append(&item_autostart);
    let _ = menu.append(&item_separator);
    let _ = menu.append(&item_quit);

    // ── Tray icon ────────────────────────────────────────────────────────────
    let _tray = TrayIconBuilder::new()
        .with_menu(Box::new(menu))
        .with_tooltip(APP_NAME)
        .with_icon(icon)
        .build()
        .expect("Failed to create tray icon");

    log::info!("🖥️  Tray icon created");

    // ── Event loop (Windows message pump) ───────────────────────────────────
    let menu_channel = MenuEvent::receiver();
    let _tray_channel = TrayIconEvent::receiver();

    let autostart_id  = item_autostart.id().clone();
    let quit_id       = item_quit.id().clone();

    loop {
        // Proses menu event
        if let Ok(event) = menu_channel.try_recv() {
            if event.id == quit_id {
                log::info!("👋 Quit requested from tray");
                shutdown_flag.store(true, Ordering::SeqCst);
                break;
            }

            if event.id == autostart_id {
                let current = is_autostart_enabled();
                set_autostart(!current);
                // Update label
                item_autostart.set_text(autostart_label());
            }
        }

        // Pump Windows messages (dibutuhkan agar tray merespons)
        #[cfg(target_os = "windows")]
        unsafe {
            use windows::Win32::UI::WindowsAndMessaging::{
                DispatchMessageW, PeekMessageW, TranslateMessage, MSG, PM_REMOVE,
            };
            let mut msg = MSG::default();
            while PeekMessageW(&mut msg, None, 0, 0, PM_REMOVE).as_bool() {
                let _ = TranslateMessage(&msg);
                DispatchMessageW(&msg);
            }
        }

        std::thread::sleep(std::time::Duration::from_millis(50));
    }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

fn autostart_label() -> &'static str {
    if is_autostart_enabled() {
        "✅ Run on startup (click to disable)"
    } else {
        "⬜ Run on startup (click to enable)"
    }
}

/// Icon sederhana: kotak biru 32x32
/// Ganti dengan file .ico sesuai branding kalau perlu
fn load_icon() -> tray_icon::Icon {
    const SIZE: usize = 32;
    let mut rgba = vec![0u8; SIZE * SIZE * 4];

    for y in 0..SIZE {
        for x in 0..SIZE {
            let i = (y * SIZE + x) * 4;
            // Warna biru tua dengan border putih tipis
            let border = x == 0 || x == SIZE - 1 || y == 0 || y == SIZE - 1;
            if border {
                rgba[i]     = 255; // R
                rgba[i + 1] = 255; // G
                rgba[i + 2] = 255; // B
                rgba[i + 3] = 255; // A
            } else {
                rgba[i]     = 30;  // R
                rgba[i + 1] = 100; // G
                rgba[i + 2] = 200; // B
                rgba[i + 3] = 255; // A
            }
        }
    }

    tray_icon::Icon::from_rgba(rgba, SIZE as u32, SIZE as u32)
        .expect("Failed to create icon")
}