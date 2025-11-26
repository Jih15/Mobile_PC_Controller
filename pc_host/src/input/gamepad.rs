use anyhow::Result;
use vigem_client::{Client, TargetId, Xbox360Wired, XGamepad, XButtons};

pub struct Gamepad {
    client: Client,
    controller: Xbox360Wired<Client>, // generic harus disertakan
    state: XGamepad,
}

impl Gamepad {
    pub fn new() -> Result<Self> {
        let client = Client::connect()?;

        // berbeda dengan versi lama!
        let controller = Xbox360Wired::new(client.clone(), TargetId::XBOX360_WIRED);

        controller.plugin()?; // sambungkan ke driver

        println!("🎮 Virtual Xbox360 Controller connected");

        Ok(Self {
            client,
            controller,
            state: XGamepad::default(),
        })
    }

    pub fn disconnect(&self) {
        let _ = self.controller.unplug();
    }

    // ----------------------
    // DIGITAL BUTTONS
    // ----------------------
    pub fn set_button(&mut self, button: XButtons, pressed: bool) -> Result<()> {
        if pressed {
            self.state.buttons |= button;
        } else {
            self.state.buttons &= !button;
        }
        self.controller.update(&self.state)?;
        Ok(())
    }

    // ----------------------
    // ANALOG STICKS
    // ----------------------
    pub fn set_left_stick(&mut self, x: i16, y: i16) -> Result<()> {
        self.state.thumb_lx = x;
        self.state.thumb_ly = y;
        self.controller.update(&self.state)?;
        Ok(())
    }

    pub fn set_right_stick(&mut self, x: i16, y: i16) -> Result<()> {
        self.state.thumb_rx = x;
        self.state.thumb_ry = y;
        self.controller.update(&self.state)?;
        Ok(())
    }

    // ----------------------
    // TRIGGERS 0–255
    // ----------------------
    pub fn set_left_trigger(&mut self, value: u8) -> Result<()> {
        self.state.left_trigger = value;
        self.controller.update(&self.state)?;
        Ok(())
    }

    pub fn set_right_trigger(&mut self, value: u8) -> Result<()> {
        self.state.right_trigger = value;
        self.controller.update(&self.state)?;
        Ok(())
    }
}

impl Drop for Gamepad {
    fn drop(&mut self) {
        let _ = self.controller.unplug();
    }
}
