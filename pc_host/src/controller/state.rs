// src/controller/state.rs
use tokio::sync::Mutex;
use once_cell::sync::Lazy;

#[derive(Clone, Copy, Debug)]
pub enum ResponseCurve {
    Linear,
    Exponential(f32),
}

#[derive(Debug)]
pub struct AxisState {
    pub raw: f32,    
    pub filtered: f32, 
}

impl AxisState {
    pub fn new() -> Self {
        Self { raw: 0.0, filtered: 0.0 }
    }
}

#[derive(Debug)]
pub struct ControllerState {
    // sticks: -1..1
    pub left_x: AxisState,
    pub left_y: AxisState,
    pub right_x: AxisState,
    pub right_y: AxisState,

    // triggers: 0..1
    pub left_trigger: AxisState,
    pub right_trigger: AxisState,

    // buttons: simple map of names -> pressed
    pub buttons: std::collections::HashMap<String, bool>,

    // filter params
    pub smoothing_alpha: f32, // 0..1 (0 = no smoothing, 1 = hold)
    pub deadzone: f32,        // 0..1
    pub auto_center_rate: f32, // per second decay toward 0 for axes that should return
    pub response_curve: ResponseCurve,
}

impl ControllerState {
    pub fn new() -> Self {
        Self {
            left_x: AxisState::new(),
            left_y: AxisState::new(),
            right_x: AxisState::new(),
            right_y: AxisState::new(),
            left_trigger: AxisState::new(),
            right_trigger: AxisState::new(),
            buttons: std::collections::HashMap::new(),
            smoothing_alpha: 0.25, // default low-pass (smaller = smoother)
            deadzone: 0.05,
            auto_center_rate: 4.0, // decay per second
            response_curve: ResponseCurve::Linear,
        }
    }

    /// Update raw value for an axis (value range expected by caller)
    pub fn set_raw_axis(&mut self, axis: &str, value: f32) {
        let v = value.clamp(-1.0, 1.0);
        match axis {
            "left_x" => self.left_x.raw = v,
            "left_y" => self.left_y.raw = v,
            "right_x" => self.right_x.raw = v,
            "right_y" => self.right_y.raw = v,
            "lt" => self.left_trigger.raw = (value.max(0.0)).clamp(0.0, 1.0),
            "rt" => self.right_trigger.raw = (value.max(0.0)).clamp(0.0, 1.0),
            _ => {}
        }
    }

    pub fn set_button(&mut self, key: &str, pressed: bool) {
        self.buttons.insert(key.to_string(), pressed);
    }

    /// Apply deadzone
    fn apply_deadzone(&self, v: f32) -> f32 {
        let dz = self.deadzone;
        if dz <= 0.0 { return v; }
        if v.abs() < dz { 0.0 } else {
            // re-scale so remaining range maps to 0..1
            let sign = v.signum();
            let rem = (v.abs() - dz) / (1.0 - dz);
            sign * rem.clamp(0.0, 1.0)
        }
    }

    /// Apply response curve: linear or exponential (preserve sign)
    fn apply_response_curve(&self, v: f32) -> f32 {
        match self.response_curve {
            ResponseCurve::Linear => v,
            ResponseCurve::Exponential(exp) if exp > 0.0 => {
                let sign = v.signum();
                let mag = v.abs();
                sign * mag.powf(exp)
            }
            _ => v,
        }
    }

    /// Single low-pass step: filtered = alpha * raw + (1-alpha) * filtered
    fn low_pass_step(&self, raw: f32, filtered: f32) -> f32 {
        let a = self.smoothing_alpha.clamp(0.0, 1.0);
        a * raw + (1.0 - a) * filtered
    }

    /// Apply updates per tick (dt in seconds). This applies deadzone, smoothing,
    /// auto-centering, and response curve in a stable order.
    pub fn tick(&mut self, dt: f32) {
        // helper closure for -1..1 axes
        let process_axis = |raw: f32, filtered: f32, state: &ControllerState| -> f32 {
            // 1. raw already set
            // 2. apply deadzone on raw
            let after_dead = state.apply_deadzone(raw);

            // 3. auto-center: if raw is zero and filtered not zero, decay filtered toward 0
            let mut target = after_dead;
            if after_dead == 0.0 && filtered != 0.0 && state.auto_center_rate > 0.0 {
                // move filtered toward zero by rate*dt
                let decay = state.auto_center_rate * dt;
                if filtered.abs() <= decay {
                    target = 0.0;
                } else {
                    target = filtered - filtered.signum() * decay;
                }
            }

            // 4. smoothing (low-pass)
            let smoothed = state.low_pass_step(target, filtered);

            // 5. response curve (after smoothing)
            state.apply_response_curve(smoothed)
        };

        // left stick
        self.left_x.filtered = process_axis(self.left_x.raw, self.left_x.filtered, self);
        self.left_y.filtered = process_axis(self.left_y.raw, self.left_y.filtered, self);
        self.right_x.filtered = process_axis(self.right_x.raw, self.right_x.filtered, self);
        self.right_y.filtered = process_axis(self.right_y.raw, self.right_y.filtered, self);

        // triggers: assume raw in 0..1 and deadzone scaled similarly
        let process_trigger = |raw: f32, filtered: f32, state: &ControllerState| -> f32 {
            // deadzone: tiny values to zero
            let after_dead = if raw.abs() < state.deadzone { 0.0 } else { raw };
            // smoothing
            let smoothed = state.low_pass_step(after_dead, filtered);
            // curve: for triggers maybe use exp as well but keep same function
            state.apply_response_curve(smoothed)
        };

        self.left_trigger.filtered = process_trigger(self.left_trigger.raw, self.left_trigger.filtered, self);
        self.right_trigger.filtered = process_trigger(self.right_trigger.raw, self.right_trigger.filtered, self);
    }
}

// Global shared state, accessible by websocket & vigem mapper
pub static SHARED_STATE: Lazy<Mutex<ControllerState>> = Lazy::new(|| {
    Mutex::new(ControllerState::new())
});
