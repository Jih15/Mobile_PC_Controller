use serde::de::value;


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
    pub deadzone: f32, // 0..1
    pub auto_center_rate: f32, // per second decay toward 0
    pub response_curve: ResponseCurve
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
            smoothing_alpha: 0.25, 
            deadzone: 0.05, 
            auto_center_rate: 4.0, 
            response_curve: ResponseCurve::Linear, 
        }
    }

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

    fn apply_response_curve(&self, v: f32)-> f32 {
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

    
}